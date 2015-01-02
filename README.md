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
bundle exec ruby leven.rb &lt;agency_list&gt; &lt;hathi_file&gt; &lt;output_file&gt;

bundle exec ruby CIC_leven.rb &lt;agency_list&gt; &lt;cic_file.json&gt; &lt;output_file&gt;



