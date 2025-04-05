require "test_helper"

class StrictLocalsTest < Slotify::TestCase
  describe "with strict locals" do
    let(:view_path) { "with_strict_locals" }

    it "has the expected locals available in the partial" do
      locals = { title: "Title from locals", subtitle: "Subtitle from locals" }
      render view_path, **locals do |partial|
        partial.with_description do
          "This is the description"
        end
      end

      _(page).must_have_css "h1", text: locals[:title]
      _(page).must_have_css "h2", text: locals[:subtitle]
      _(page).must_have_css "p", text: "This is the description"
    end
  end
end
