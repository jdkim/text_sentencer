require 'spec_helper'

describe TextSentencer do
	describe "#annotate" do
		before do
			@sentence1 = "This is the first sentence."
			@sentence2 = "This is the second."
			@text = @sentence1 + " " + @sentence2
		end

		context "When initialized without configuration" do
			before do
				@sentencer = TextSentencer.new
			end

			it "segments a text into sentences" do
				annotation = @sentencer.annotate(@text)
				span1 = annotation[:denotations][0][:span]
				span2 = annotation[:denotations][1][:span]

				expect(@text[span1[:begin]...span1[:end]]).to eql(@sentence1)
				expect(@text[span2[:begin]...span2[:end]]).to eql(@sentence2)
			end

			it "gives the whole text as a sentence" do
				annotation = @sentencer.annotate(@sentence1)
				span1 = annotation[:denotations][0][:span]

				expect(@text[span1[:begin]...span1[:end]]).to eql(@sentence1)
			end
		end

		context "When initialized with an empty configuration" do
			before do
				@sentencer = TextSentencer.new({})
			end

			it "gives the whole text as a sentence" do
				annotation = @sentencer.annotate(@text)
				span1 = annotation[:denotations][0][:span]

				expect(@text[span1[:begin]...span1[:end]]).to eql(@text)
			end
		end

		context "When initialized with a nil configuration" do
			before do
				@sentencer = TextSentencer.new(nil)
			end

			it "segment a text into sentences" do
				annotation = @sentencer.annotate(@text)
				span1 = annotation[:denotations][0][:span]
				span2 = annotation[:denotations][1][:span]

				expect(@text[span1[:begin]...span1[:end]]).to eql(@sentence1)
				expect(@text[span2[:begin]...span2[:end]]).to eql(@sentence2)
			end
		end

		context "When initialized with a wrong configuration" do
			before do
				@sentencer = TextSentencer.new({break_candidates:["\t"]})
			end

			it "returns an array of denotations" do
				annotation = @sentencer.annotate(@text)
				span1 = annotation[:denotations][0][:span]

				expect(@text[span1[:begin]...span1[:end]]).to eql(@text)
			end
		end
	end
end