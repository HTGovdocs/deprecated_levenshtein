#Small edit of Martin's normalize_agencies script. 
#Mainly, we do care who is selling it if its the GPO
def normalize_agency(ag)
  ag.strip!

  if ag.nil? then
   return nil  
  end

  ag.upcase!;
  ag.gsub!(/[,\.:;]|\'S?/, '');   # punctuations
  ag.gsub!(/[\(\)\{\}\[\]]/, ''); # Brackets
  #ag.gsub!(/FOR SALE BY.*/, '');  # I AM NOT INTERESTED IN WHAT YOU ARE SELLING KTHXBYE.
  ag.gsub!(/FOR SALE BY/, ''); #If it's a govdoc agency, then it MIGHT be a govdoc
  ag.gsub!(/\b(THE) /, '');       # Stop words

  # Abbreviations et cetera.
  ag.gsub!(/DEPARTMENT/, 'DEPT');
  ag.gsub!(/DEPTOF/, 'DEPT OF'); # Strangely common typo(?)

  ag.gsub!(/UNITED STATES( OF AMERICA)?/, 'US');
  ag.gsub!(/U\sS\s|U S$/, 'US ');
  ag.gsub!(/GOVERNMENT/, 'GOVT');
  ag.gsub!(/ SPN$/, '');

  # US GOVT PRINT OFF, which is so common yet has so many variations.
  ag.sub!(/(US\s?)?GOVT\s?PRINT(ING)?\s?OFF(ICE)?/, 'USGPO');
  ag.sub!(/U\s?S\s?G\s?P\s?O/, 'USGPO');
  ag.sub!(/^GPO$/, 'USGPO');
  
  ag.gsub!(/ +/, ' '); # whitespace
  ag.sub!(/^ +/,  '');
  ag.sub!(/ +$/,  '');
  
  return ag
end

