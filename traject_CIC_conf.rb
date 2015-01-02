require 'normalize_agency.rb'

#Not strictly necessary, but it makes the work of CIC_leven easier with simplified json.

#     traject -c ./traject_CIC_conf.rb <CIC_source.ndj> -o <output>



# Set up a reader and a writer
# First we need to require the reader/writer we want

require 'traject'
require 'traject/ndj_reader'
require 'traject/line_writer'
require 'traject/macros/marc21_semantics'
extend  Traject::Macros::Marc21Semantics


# The add the appropriate settings
settings do
  provide "reader_class_name", "Traject::NDJReader"
  provide "marc_source.type", "NDJ"
  provide "writer_class_name", "Traject::LineWriter"
  #provide "output_file", @output_file 
  provide 'processing_thread_pool', 4
  
  # Right now, logging is going to $stderr. Uncomment
  # this line to send it to a file
  
  # provide 'log.file', 'traject.log'
  
end



# Log what version of jruby/java we're using

logger.info RUBY_DESCRIPTION


# index the id, title, and author

to_field "id", extract_marc("001", :first => true)
to_field "country", extract_marc("008[17]")
to_field "government", extract_marc("008[28]") 
to_field "title", extract_marc('245') do |record, accumulator|
  accumulator.map! {|v| normalize_agency(v)}
end
to_field "author", extract_marc('100abcd:110abcd:111abc') do | record, accumulator |
  accumulator.map! {|v| normalize_agency(v) }
end
to_field "corp_name", extract_marc('110') do |record, accumulator|
  accumulator.map! {|v| normalize_agency(v)}
end
to_field "imprint", extract_marc('260bc') do | record, accumulator |
  accumulator.map! {|v| normalize_agency(v) }
end
to_field "sudoc", extract_marc('086', :first => true)
#to_field "text", extract_all_marc_values(:from => '100', :to => '899')
to_field "source", literal("LIB_CATALOG")

to_field 'oclc', oclcnum;
# That's it!
