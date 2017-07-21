#!/usr/bin/env ruby
require 'pp'

class TextSentencer
  ## default rules

  DEFAULT_RULES = {
    # All the positions of new line characters always take sentence break.
    break_characters: [
      "\n"
    ],

    # All the positions of space and tab characters are candiates of sentence break.
    break_candidates: [
      " ", "\t"
    ],

    # First, positive rules are applied to the break candidates to make initial segmantations.
    positive_rules: [
      ['[.!?]', '[0-9A-Z]'],
      ['[:]', '[0-9]'],
      ['[:]', '[A-Z][a-z]']
    ],

    # Then, negative rules are applied to cancel some initial segmentations.
    negative_rules: [
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
  }

  def initialize(rules = nil)
    rules ||= DEFAULT_RULES
    @rules = Hash[rules.map{|(k,v)| [k.to_sym,v]}]
    @rules[:break_characters] ||= []
    @rules[:break_candidates] ||= []
    @rules[:positive_rules] ||= []
    @rules[:negative_rules] ||= []
  end

  def annotate(text)
    return nil if text.nil? || text.empty?
    sentences = segment(text)
    denotations = sentences.inject([]){|c, s| c << {:span => {:begin => s[0], :end => s[1]}, :obj => 'Sentence'}}
    denotations.empty? ? {text:text} : {text:text, denotations:denotations}
  end

  private

  def segment(text)
    original_text = text
    text = original_text.strip
    start = original_text.index(text)

    # sentence breaks
    breaks = []

    # breaks by positive rules
    pbreaks = []

    # canceled breaks by negative rules
    nbreaks = []

    for l in 0..text.length

      ## apply the positive rules to the places of break candidates
      if @rules[:break_candidates].include?(text[l])
        @rules[:positive_rules].each do |r|
          if (text[0...l] =~ /#{r[0]}\Z/) && (text[l+1..-1] =~ /\A#{r[1]}/)
            pbreaks << l
            break
          end
        end
      elsif @rules[:break_characters].include?(text[l])
        breaks << l
      end
    end

    ## apply the negative rules to the places of break candidates
    pbreaks.each do |l|
      @rules[:negative_rules].each do |r|
        if (text[0...l] =~ /#{r[0]}\Z/) && (text[l+1..-1] =~ /\A#{r[1]}/)
          nbreaks << l
          break
        end
      end
    end
    breaks += pbreaks - nbreaks
    breaks.sort!

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
