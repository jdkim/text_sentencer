#!/usr/bin/env ruby
require 'sinatra'
require 'json'
require 'erb'
require './textsentencer'

text = ''

before do
	if request.media_type == 'application/json'
		request.body.rewind
		p = JSON.parse(request.body.read)
		text = p['text']
	else 
		text = params['text']
	end
end

get '/' do
	erb :index
end

post '/' do
	sentences = Sentencer.segment(text)

	# initialization
	denotations = []

	unless sentences.empty?
		sentences.each do |b, e|
			denotations << {:begin => b, :end => e, :object => 'Sentence'}
		end
	end

	headers \
		'Content-Type' => 'application/json'
	body denotations.to_json
end
