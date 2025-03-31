require "test_helper"

class PluralSlotsTest < Slotify::TestCase
  describe "optional" do
    let(:partial_path) { "plural_optional" }

    describe "with slot content" do
      it "renders one item when called once" do
        render partial_path do |partial|
          partial.with_item "Item 1"
          partial.with_thing "Thing 1"
        end

        _(page).must_have_css "li.item", count: 1, text: "Item 1"
        _(page).must_have_css "li.thing", count: 1, text: "Thing 1"
      end

      it "renders multiple entries when called multiple times" do
        render partial_path do |partial|
          partial.with_item "Item 1"
          partial.with_item "Item 2"
          partial.with_item "Item 3"

          partial.with_thing "Thing 1"
          partial.with_thing "Thing 2"
          partial.with_thing "Thing 3"
        end

        _(page).must_have_css "li.item", count: 3
        _(page).must_have_css "li.item", text: "Item 1"
        _(page).must_have_css "li.item", text: "Item 2"
        _(page).must_have_css "li.item", text: "Item 3"

        _(page).must_have_css "li.thing", count: 3
        _(page).must_have_css "li.thing", text: "Thing 1"
        _(page).must_have_css "li.thing", text: "Thing 2"
        _(page).must_have_css "li.thing", text: "Thing 3"
      end
    end

    describe "with no slot content set" do
      before do
        render partial_path
      end

      it "does not render the `items` slot (no default value)" do
        _(page).wont_have_css "ul.items"
        _(page).wont_have_css "li.item"
      end

      it "renders the `things` slot using the specified default values" do
        _(page).must_have_css "ul.things"
        _(page).must_have_css "li.thing", count: 1, text: "Default thing 1"
      end
    end
  end

  describe "required" do
    let(:partial_path) { "plural_required" }

    describe "with content" do
      before do
        render partial_path do |partial|
          partial.with_item "Item 1"
          partial.with_item "Item 2"
        end
      end

      it "renders the items" do
        _(page).must_have_css "li.item", count: 2
      end
    end

    describe "with no slot content set" do
      it "raises an exception" do
        error = _ { render partial_path }.must_raise ActionView::Template::Error
        _(error.cause).must_be_kind_of Slotify::MissingRequiredSlotError
      end
    end
  end
end
