module TextSentencer; end unless defined? TextSentencer

# All the positions of whitespace characters are candiate of sentence boundary.

# First, positive rules are applied to find make initial segmantations.
TextSentencer::POSITIVE_RULES = [
  ['[\.!?]', '[0-9A-Z]'],
  ['[:]', '[0-9]'],
  ['[:]', '[A-Z][a-z]']
]

# Then, negative rules are applied to cancel some initial segmentations.
TextSentencer::NEGATIVE_RULES = [
  # Titles before names
  ['(Mrs|Mmes|Mr|Messrs|Ms|Prof|Dr|Drs|Rev|Hon|Sen|St)\.', '[A-Z][a-z]'],

  # Titles usually before names, but ..
  ['(Sr|Jr)\.', '[A-Z][a-z]'],

  # Single letter abbriveations, e.g. middle name
  # ['\b[A-Z]\.', '[A-Z][a-z]'],

  # Abbriveations, e.g. middle name
  ['\b[A-Z][a-z]*\.', '[0-9A-Z]'],

  # Frequent abbreviations that will never appear in the end of a sentence
  ['(cf|vs)\.', ''],
  ['e\.g\.', ''],
  ['i\.e\.', ''],

  # Others
  ['(Sec|Chap|Fig|Eq)\.', '[0-9A-Z]']
]
