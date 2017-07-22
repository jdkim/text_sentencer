Gem::Specification.new do |s|
  s.name        = 'text_sentencer'
  s.version     = '1.0.0'
  s.summary     = 'A simple, rule-based script to find sentence boundaries in text.'
  s.date        = Time.now.utc.strftime("%Y-%m-%d")
  s.description = "TextSentencer is a simple rule-based system for segmenting a text block into sentences."
  s.authors     = ["Jin-Dong Kim"]
  s.email       = 'jindong.kim@gmail.com'
  s.files       = ["lib/text_sentencer.rb", "lib/text_sentencer/text_sentencer.rb", "lib/text_sentencer/string_scan_offset.rb"]
  s.executables << 'text_sentencer'
  s.homepage    = 'https://github.com/jdkim/text_sentencer'
  s.license     = 'MIT'
end