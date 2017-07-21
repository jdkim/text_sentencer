# TextSentencer

TextSentencer is a simple rule-based tool for segmenting a text block into sentences.

## Installation


### Gem installation

Download and install text_sentencer with the following.
```bash
> gem install text_sentencer
```

## Usage

### Simple command-line example
```bash
> echo "This is a sentence. This is another." | text_sentencer
This is a sentence.
This is another.
```
or
```bash
> text_sentencer filename
```
or
```bash
> text_sentencer < filename
```


### To use with a custom rules
```bash
> echo "This is a sentence" | text_sentencer -c custom_rules.json
```

### Ruby script example
```ruby
#!/usr/bin/env ruby
require 'text_sentencer'

text = "This is a sentence. This is another."
sentencer = TextSentencer.new
annotation = sentencer.annotate(text)
annotation[:denotations].each do |d|
  span = d[:span]
  puts text[span[:begin]...span[:end]]
end
```

## Rules

### Rule system

The rule system of text_sentencer consists of four components.

1. In a text, every position of characters included in _break_characters_ gets a setence break.
1. In a text, every position of characters included in _break_candidates_ is regarded as a candidate of sentence break.
1. For each break candidate, each rule in _positive_rules_ is tested (in the order). If a matching rule is found, the candiate gets a sentence break.
   * Each rule consists of two regular expressions (in perl syntax). 
   * The first RE is applied to the string preceding the break candidate. Note that '\Z' will be automatically added to the end of the first RE, to indicate the end of the string.
   * The second RE is applied to the string following the break candidate. Note that '\A' will be automatically added to the beginning of the second RE, to indicate the beginning of the string.
 1. For each break candidate that gets a sentence break by a positive rule, each rule in _negative_rules_ is tested. If a matching rule is found, the sentence break is cancelled.


### Default rules

The defulat rules were obtained by analyzing the GENIA corpus. Therefore, it will work best for PubMed articles.

Note that each string in _positive_ and _negative_rules_ represents a regular expression in Perl syntax. In Perl RE, a dot ('.') character is used as a wildcard marker which matches to any single character. To represent a literal dot character, it has to be escaped by a preceding backslash ('\') character. When a RE is stored in a string, the backslash character has to be escaped again. That is why some dot characters are double escaped in some rules, e.g. "(Sr|Jr)\\\\.".

```
{
  "break_characters": [
    "\n"
  ],
  "break_candidates": [
    " ",  "\t"
  ],
  "positive_rules": [
    ["[.!?]", "[0-9A-Z]"],
    ["[:]", "[0-9]"],
    ["[:]", "[A-Z][a-z]"]
  ],
  "negative_rules": [
    // Titles which usually appear before names
    ["(Mrs|Mmes|Mr|Messrs|Ms|Prof|Dr|Drs|Rev|Hon|Sen|St)\\.", "[A-Z][a-z]"],

    // Titles which sometimes appear before names
    ["(Sr|Jr)\\.", "[A-Z][a-z]"],
    
    // Abbreviations, e.g. middle names
    ["\b[A-Z][a-z]*\\.", "[0-9A-Z]"],
    
    // Frequent abbreviations which will never appear in the end of a sentence
    ["(cf|vs)\\.", ""],
    ["e\\.g\\.", ""],
    ["i\\.e\\.", ""],
    ["(Sec|Chap|Fig|Eq)\\.", "[0-9A-Z]"]
  ]
}
```

### An example of custom rules
Below is an example of custom rules which simply break at every whitespace character which follows a punctuation mark and is followed by a capitalized word.

Note that the two arrays, _break_characters_ and _negative_rules_ are not defined in the example. In the case, the two arrays will be set to be empty.


```
{
  "break_candidates": [
    " ", "\t", "\n"
  ],
  "positive_rules": [
    ["[.!?]", "[0-9A-Z][a-z]"]
  ]
}
```


## License

Released under the [MIT license](http://opensource.org/licenses/MIT).
