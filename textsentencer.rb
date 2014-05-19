#!/usr/bin/env ruby

module Sentencer
  # rules
  PositiveRules =
    [
     ['[\.!?]', '[0-9A-Z]'],
     ['[:]', '[0-9]'],
     ['[:]', '[A-Z][a-z]']
    ]

  NegativeRules =
    [
     # Titles before names
     ['(Mrs|Mmes|Mr|Messrs|Ms|Prof|Dr|Drs|Rev|Hon|Sen|St)\.', '[A-Z][a-z]'],

     # Titles usually before names, but ..
     ['(Sr|Jr)\.', '[A-Z][a-z]'],

     # Single letter abbriveations, e.g. middle name
#     ['\b[A-Z]\.', '[A-Z][a-z]'],

     # Abbriveations, e.g. middle name
     ['\b[A-Z][a-z]*\.', '[0-9A-Z]'],

     # Frequent abbreviations that will never appear in the end of a sentence
     ['(cf|vs)\.', ''],
     ['e\.g\.', ''],
     ['i\.e\.', ''],

     # Others
     ['(Sec|Chap|Fig|Eq)\.', '[0-9A-Z]']
    ]

  def Sentencer.segment(intext)
    text = intext.strip 
    start = intext.index(text)

    ## apply the positive rules to the places of space and newline characters
    pbreaks = []                # breaks by positive rules
    for l in 0..text.length

      case text[l]
      when ' '                   # space
        PositiveRules.each do |r|
          if (text[0...l] =~ /#{r[0]}\Z/) && (text[l+1..-1] =~ /\A#{r[1]}/)
            pbreaks << l
            break
          end
        end
      when "\n"                   # newline
        pbreaks << l
      end
    end

    ## apply the negative rules to the places of space characters
    nbreaks = []                # breaks by negative rules
    pbreaks.each do |l|
      if text[l] == ' '
        NegativeRules.each do |r|
          if (text[0...l] =~ /#{r[0]}\Z/) && (text[l+1..-1] =~ /\A#{r[1]}/)
            nbreaks << l
            break
          end
        end
      end
    end
    breaks = pbreaks - nbreaks

    sentences = []
    lastbreak = -1
    breaks.each do |b|
      sentences.push([lastbreak+1, b])
      lastbreak = b
    end
    sentences.push([lastbreak+1, text.length])

    ## filter out empty segments
    sentences.delete_if {|b, e| text[b...e] !~ /[a-zA-Z0-9]/}

    ## adjust offsets for the in text
    sentences.collect!{|b, e| [b + start, e + start]}

    sentences
  end
end

if __FILE__ == $0

  text = ''
  ARGF.each do |line|
    text += line
  end

  sen_so = Sentencer.segment(text)
  p(sen_so)
end
