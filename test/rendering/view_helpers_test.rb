require "test_helper"

class ViewHelpersTest < Slotify::TestCase
  include ViewHelpers

  let(:view_path) { "view_helpers" }

  before do
    render template: view_path
  end

  describe "before the partial is rendered" do
    it "the helpers output the expected values" do
      before_partial = page.find("#before-partial")
      _(before_partial).must_have_css "h1", text: user_name
      _(before_partial).must_have_css "time", text: birth_date
    end
  end

  describe "within the partial" do
    it "slots override helpers" do
      partial = page.find("#partial")
      _(partial).must_have_css "h1", text: "Mr Override"
    end

    it "non-overriden helpers are still available" do
      partial = page.find("#partial")
      _(partial).must_have_css "time", text: birth_date
    end
  end

  describe "after the partial is rendered" do
    it "the helpers output the expected values" do
      after_partial = page.find("#after-partial")
      _(after_partial).must_have_css "h1", text: user_name
      _(after_partial).must_have_css "time", text: birth_date
    end
  end
end
