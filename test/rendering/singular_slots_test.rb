require "test_helper"

class SingleSlotsTest < Slotify::TestCase
  describe "optional" do
    let(:partial_path) { "singular_optional" }

    describe "with content for all slots" do
      before do
        render partial_path do |partial|
          partial.with_title "This is the title"
          partial.with_subtitle "This is the subtitle"
        end
      end

      it "renders the slots" do
        _(page).must_have_css "h1", text: "This is the title"
        _(page).must_have_css "h2", text: "This is the subtitle"
      end
    end

    describe "with no slot content" do
      before do
        render partial_path
      end

      it "does not render slots without a default value" do
        _(page).wont_have_css "h1"
      end

      it "renders slots with default values" do
        _(page).must_have_css "h2", text: "Default subtitle"
      end
    end
  end

  describe "required" do
    let(:partial_path) { "singular_required" }

    describe "with content" do
      before do
        render partial_path do |partial|
          partial.with_title "This is the title"
        end
      end

      it "renders the slot" do
        _(page).must_have_css "h1", text: "This is the title"
      end
    end

    describe "with no slot content set" do
      it "raises an exception" do
        _ { render partial_path }.must_raise Slotify::StrictSlotsError
      end
    end
  end

  describe "multiple calls to singular slot" do
    it "raises an exception" do
      _ do
        render "singular_optional" do |partial|
          partial.with_title "Title 1"
          partial.with_title "Title 2"
        end
      end.must_raise Slotify::MultipleSlotEntriesError
    end
  end
end
