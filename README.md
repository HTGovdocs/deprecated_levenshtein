levenshtein
===========

leven.rb computes Damerau-Levenshtein distance between imprint field in Hathi Files and the agency list. 

CIC_leven.rb does the same, but accepts json and multiple field comparisons. 

normalize_agency.rb is a slightly modified version of the normalization script found in duplicates.


Install
-------
bundle install --path .bundle


Use
---
bundle exec ruby leven.rb <agency_list> <hathi_file> <output_file>
bundle exec ruby CIC_leven.rb <agency_list> <cic_file.json> <output_file>



