#leven and CIC_leven could probably be merged. 
#Only difference is expected source format and number of columns
#require './naive_leven.rb' #naive ruby implementation too slow, almost 5 mins
                            #to compare 1 record to the 27k agency list
require 'rubygems'
require 'bundler/setup'

require 'normalize_agency.rb'
require 'levenshtein' #Damerau-Levenshtein, written in C. levenshtein-ffi

agency_list = open(ARGV.shift, 'r')
cic_file = open(ARGV.shift, 'r')
out_file = open(ARGV.shift, 'w')

limit = 30 #leven is O(n^2), so we need to limit string length
dissim_cutoff = 0.1 #any less than 1 edit in 10 characters is auto accepted

rec_count = 0 

#get agency list
agencies = {} 
agency_list.each do | agency |
  #already normalized
  agencies[agency.strip[0..limit]] = true
end

#tracking processing time
start_time = Time.now

#the fields we are comparing with the agency list
compare_fields = ['title','author','corp_name','imprint']
#compare_fields = ['imprint']
cic_file.each do | rec |
  rec_count += 1
  rec = eval(rec)
  
  id = rec['id'][0].strip
  if rec['sudoc']
    sudoc = rec['sudoc'][0].strip
  else
    sudoc = ''
  end
 
  out_row = [id, sudoc] 
  compare_fields.each do | f |
    if rec[f]
      field_text = rec[f][0]
    else
      field_text = ''
    end
    if !field_text.empty? && !field_text.nil?
      field_length = field_text.length.to_f #for computing score
      best_match_distance = limit
      best_match = ''
      
      #avoid leven and 0(n^2) if possible 
      if agencies.has_key?(field_text) 
        best_match = field_text
        best_match_distance = 0
      else #compare to our existing agency list 
        agencies.each_key do | agency | 
          dist = Levenshtein.distance(field_text, agency)
          if dist / field_length < dissim_cutoff #close enough
            best_match = agency
            best_match_distance = dist
            break
          elsif dist < best_match_distance
            best_match_distance = dist
            best_match = agency
          end
        end
      end
      score = best_match_distance / field_length
      out_row = out_row + [field_text, best_match, best_match_distance, score]
    else
      out_row = out_row + ['', '', '', ''] 
    end
  end

  out_file.puts out_row.join("\t")
end

end_time = Time.now
duration = end_time - start_time
puts "#{rec_count}#{limit}\t#{dissim_cutoff}\t#{start_time}\t#{end_time}\t#{duration}\n" 
