#!/usr/bin/env ruby
require 'text_sentencer/string_scan_offset'
require 'pp'

class TextSentencer
  ## default rules

  DEFAULT_RULES = {
    # All the positions of new line characters always take sentence break.
    break_pattern: "([ \t]*\n+)+[ \t]*",

    # All the positions of space and tab characters are candiates of sentence break.
    candidate_pattern: "[ \t]+",

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
    @rules[:break_pattern] ||= ""
    @rules[:candidate_pattern] ||= ""
    @rules[:positive_rules] ||= []
    @rules[:negative_rules] ||= []
  end

  def annotate(text)
    return nil if text.nil?

    sentences = segment(text)
    denotations = sentences.inject([]){|c, s| c << {:span => {:begin => s[0], :end => s[1]}, :obj => 'Sentence'}}
    {text:text, denotations:denotations}
  end

  private

  def segment(text)
    breaks = if @rules[:break_pattern].empty?
      []
    else
      text.scan_offset(/#{@rules[:break_pattern]}/).map{|m| m.offset(0)}
    end

    candidates = if @rules[:candidate_pattern].empty?
      []
    else
      text.scan_offset(/#{@rules[:candidate_pattern]}/).map{|m| m.offset(0)}
    end

    # breaks take precedent
    candidates -= breaks

    candidates.each do |c|
      last_end, next_begin = c

      if (last_end == 0) || (next_begin == text.length)
        breaks << c
        next
      end

      last_text = text[0...last_end]
      next_text = text[next_begin..-1]

      @rules[:positive_rules].each do |p|
        if (last_text =~ /#{p[0]}\Z/) && (next_text =~ /\A#{p[1]}/)
          break_p = true
          @rules[:negative_rules].each do |n|
            if (last_text =~ /#{n[0]}\Z/) && (next_text =~ /\A#{n[1]}/)
              break_p = false
              break
            end
          end
          breaks << c if break_p
          break
        end
      end
    end

    breaks.sort!

    sentences = []
    lastbreak = 0
    breaks.each do |b|
      sentences << [lastbreak, b[0]] if b[0] > lastbreak
      lastbreak = b[1]
    end
    sentences << [lastbreak, text.length] if lastbreak < text.length

    sentences
  end
end
