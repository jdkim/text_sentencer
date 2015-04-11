#!/usr/bin/env ruby
require 'text_sentencer/rules'

module TextSentencer; end unless defined? TextSentencer

module TextSentencer
  def TextSentencer.segment(text)
    original_text = text
    text = original_text.strip
    start = original_text.index(text)

    ## apply the positive rules to the places of space and newline characters
    pbreaks = []                # breaks by positive rules
    for l in 0..text.length

      case text[l]
      when ' '                   # space
        POSITIVE_RULES.each do |r|
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
        NEGATIVE_RULES.each do |r|
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

  sen_so = TextSentencer.segment(text)
  p(sen_so)
end
