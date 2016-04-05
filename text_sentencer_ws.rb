#!/usr/bin/env ruby
require 'sinatra/base'
require 'json'
require 'text_sentencer'

class TextSentencerWS < Sinatra::Base

	before do
		if request.content_type && request.content_type.downcase == 'application/json'
			body = request.body.read
			begin
				json_params = JSON.parse body, :symbolize_names => true unless body.empty?
			rescue => e
				@error_message = 'ill-formed JSON string'
			end
			params.merge!(json_params) unless json_params.nil?
		end
	end

	get '/' do
		erb :index
	end

	post '/' do
		begin
			raise ArgumentError, @error_message if @error_message

			text = params[:text]
			raise ArgumentError, "'text' value needs to be supplied." if text.nil?

			sentences = TextSentencer.segment(text)

			# initialization
			denotations = []

			unless sentences.empty?
				sentences.each do |b, e|
					denotations << {:span => {:begin => b, :end => e}, :obj => 'Sentence'}
				end
			end

			headers \
				'Content-Type' => 'application/json'
			body denotations.to_json

		rescue ArgumentError => e
			headers \
				'Content-Type' => 'application/json'
			status 400
			{message:e.message}.to_json

		rescue IOError => e
			headers \
				'Content-Type' => 'application/json'
			status 502
			{message:e.message}.to_json
		end
	end
end