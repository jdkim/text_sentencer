require 'spec_helper'

describe TextSentencer do
	describe "#annotate" do
		before do
			@sentence1 = "This is a sentence."
			@sentence2 = "This is another."
		end

		context "When initialized without configuration" do
			before do
				@sentencer = TextSentencer.new
			end

			it "works with the default rules" do
				text = "   #{@sentence1} \t  \n\n  \n\t#{@sentence2}  \n"

				annotation = @sentencer.annotate(text)
				span1 = annotation[:denotations][0][:span]
				span2 = annotation[:denotations][1][:span]

				expect(text[span1[:begin]...span1[:end]]).to eql(@sentence1)
				expect(text[span2[:begin]...span2[:end]]).to eql(@sentence2)
			end

			it "works well when the input text has only one sentence." do
				annotation = @sentencer.annotate(@sentence1)
				span1 = annotation[:denotations][0][:span]

				expect(span1[:begin]).to eql(0)
				expect(span1[:end]).to eql(@sentence1.length)
			end

			it "works well when the input is an empty string" do
				annotation = @sentencer.annotate("")
				expect(annotation[:denotations]).to eql([])
			end

		end

		context "When initialized with an empty configuration" do
			before do
				@sentencer = TextSentencer.new({})
			end

			it "gives the whole text as a sentence" do
				text = "   #{@sentence1} \t  \n\n  \n\t#{@sentence2}  \n"
				annotation = @sentencer.annotate(text)
				span1 = annotation[:denotations][0][:span]

				expect(span1[:begin]).to eql(0)
				expect(span1[:end]).to eql(text.length)
			end
		end

		context "When initialized with a nil configuration" do
			before do
				@sentencer = TextSentencer.new(nil)
			end

			it "works with the default rules" do
				text = "   #{@sentence1} \t  \n\n  \n\t#{@sentence2}  \n"

				annotation = @sentencer.annotate(text)
				span1 = annotation[:denotations][0][:span]
				span2 = annotation[:denotations][1][:span]

				expect(text[span1[:begin]...span1[:end]]).to eql(@sentence1)
				expect(text[span2[:begin]...span2[:end]]).to eql(@sentence2)
			end
		end

		context "When initialized with a custom configuration" do
			before do
				@sentencer = TextSentencer.new({break_pattern:"\n\n", candidate_pattern:"[ \t]+"})
			end

			it "works with the custom rules" do
				text = "   #{@sentence1}\n\n#{@sentence2} "

				annotation = @sentencer.annotate(text)
				span1 = annotation[:denotations][0][:span]
				span2 = annotation[:denotations][1][:span]

				expect(text[span1[:begin]...span1[:end]]).to eql(@sentence1)
				expect(text[span2[:begin]...span2[:end]]).to eql(@sentence2)
			end
		end
	end
end