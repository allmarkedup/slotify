require "test_helper"

class OptionsTest < Slotify::TestCase
  describe "options from slot value setter" do
    let(:partial_path) { "options" }

    it "converts options to tag attributes" do
      render partial_path do |partial|
        partial.with_title "The title", class: "title", data: {controller: "title"}
      end

      _(page).must_have_css %(#title.title[data-controller="title"])
    end
  end

  describe "with default options and slot value options" do
    let(:partial_path) { "options_with_defaults" }

    it "smart merges options with the defaults" do
      render partial_path do |partial|
        partial.with_title "The title", class: "title", data: {controller: "title"}
      end

      _(page).must_have_css %(#title.title.default[data-controller="default title"])
    end
  end

  describe "with default options only" do
    let(:partial_path) { "options_with_defaults" }

    it "uses default options for tag attributes" do
      render partial_path do |partial|
        partial.with_title "The title"
      end

      _(page).must_have_css %(#title.default[data-controller="default"])
    end
  end
end
