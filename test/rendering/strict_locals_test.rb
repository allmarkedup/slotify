require "test_helper"

class StrictLocalsTest < Slotify::TestCase
  describe "with strict locals" do
    let(:partial_path) { "with_strict_locals" }

    it "makes local values available in the template" do
      locals = { title: "Title from locals", subtitle: "Subtitle from locals" }
      render partial_path, **locals do |partial|
        partial.with_description "This is the description"
      end

      _(page).must_have_css ".title", text: locals[:title]
      _(page).must_have_css ".subtitle", text: locals[:subtitle]
    end

    it "sets default values" do
      locals = { title: "Title from locals" }
      render partial_path, **locals do |partial|
        partial.with_description "This is the description"
      end

      _(page).must_have_css ".title", text: locals[:title]
      _(page).must_have_css ".subtitle", text: "Default subtitle"
    end

    it "sets slot values" do
      render partial_path, title: "Title from locals" do |partial|
        partial.with_description "This is the description"
      end

      _(page).must_have_css ".description", text: "This is the description"
      _(page).must_have_css ".author", text: "Mark"
    end

    it "raises on unknown local" do
      _ do
        render(partial_path, title: "Title from locals", foo: "bar") do |partial|
          partial.with_description "This is the description"
        end.assert_raise ::ActionView::Template::Error
      end
    end
  end

  describe "without strict locals" do
    let(:partial_path) { "without_strict_locals" }

    it "enables strict locals implicitly" do
      _ do
        render(partial_path, title: "Title from locals") do |partial|
          partial.with_description "This is the description"
        end
      end.must_raise ::ActionView::Template::Error
    end
  end
end
