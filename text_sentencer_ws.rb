#!/usr/bin/env ruby
require 'sinatra/base'
require 'json'
require 'text_sentencer'

class TextSentencerWS < Sinatra::Base

	before do
		if request.content_type && request.content_type.downcase =~ /application\/json/
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
		if params.has_key?("text")
			@annotations = TextSentencer.annotations(params["text"])
			@annotations[:config] = {"entity types" => [{"color" => "#eeeeff", "id" => "Sentence", "type" => "block"}]}
		end
		erb :index
	end

	post '/' do
		begin
			raise ArgumentError, @error_message if @error_message

			text = params[:text]
			raise ArgumentError, "'text' value needs to be supplied." if text.nil?

			annotations = TextSentencer.annotations(text)

			headers \
				'Content-Type' => 'application/json'
			body annotations.to_json

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