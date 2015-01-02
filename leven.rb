=begin
  A simple script to compute distance between imprints and list of known agencies. 
  This takes Hathi files in tsv format. 
  See CIC_leven for json and multiple column comparisons. 
=end

#require './naive_leven.rb' #naive ruby implementation too slow, almost 5 mins 
                            #to compare 1 record to the 27k agency list
require 'rubygems'
require 'bundler/setup'

require 'normalize_agency.rb'
require 'levenshtein' #Damerau-Levenshtein, written in C. levenshtein-ffi (java)

agency_list = open(ARGV.shift, 'r')
source_file = open(ARGV.shift, 'r')
out_file = open(ARGV.shift, 'w')

limit = 50 #leven is O(n^2), so we need to limit string length
dissim_cutoff = 0.1 #any less than 1 edit in 10 characters is auto accepted
                    #in practice this might be useless

rec_count = 0 

#get agency list
agencies = {} 
agency_list.each do | agency |
  #already normalized
  agencies[agency.strip[0..limit]] = true
end

#tracking processing time
start_time = Time.now

source_file.each do | rec |
  rec = rec.split("\t")
  gov_doc = rec[15].strip #assumes Hathi files format
  if gov_doc == '1' #already taken care of
    next
  end
  imprint = normalize_agency(rec[12])[0..limit]
  if imprint == '' 
    next
  end
  
  id = rec[0].strip
  title = rec[11]

  
  imprint_length = imprint.length.to_f #for computing score
  best_match = ''
  best_match_distance = limit
  score = 1
 
  #avoid leven and 0(n^2) if possible 
  if agencies.has_key?(imprint) 
    best_match = imprint
    best_match_distance = 0
  else #compare to our existing agency list, ~27k
    agencies.each_key do | agency | 
      distance = Levenshtein.distance(imprint, agency)
      if distance / imprint_length < dissim_cutoff #close enough
        best_match = agency
        best_match_distance = distance
        break
      elsif distance < best_match_distance
        best_match_distance = distance
        best_match = agency
      end
    end
  end

  #this might not be the right way to score it
  score = best_match_distance / imprint_length 
  out_file.puts "#{id}\t#{title}\t#{rec[12]}\t#{best_match}\t#{best_match_distance}\t#{score}" 
  rec_count += 1
end

end_time = Time.now
duration = end_time - start_time
puts "#{rec_count}\t#{limit}\t#{dissim_cutoff}\t#{start_time}\t#{end_time}\t#{duration}\n" 
