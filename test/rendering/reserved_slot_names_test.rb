require "test_helper"

class ReservedSlotNamesTest < Slotify::TestCase
  describe "defining slots with singular reserved names" do
    let(:partial_path) { "reserved_singular_slot_names" }

    it "raises an exception" do
      _ do
        render partial_path { _1.with_content("The content") }
      end.must_raise Slotify::ReservedSlotNameError
    end
  end

  describe "defining slots with plural reserved names" do
    let(:partial_path) { "reserved_plural_slot_names" }

    it "raises an exception" do
      _ do
        render partial_path { _1.with_content("The content") }
      end.must_raise Slotify::ReservedSlotNameError
    end
  end


end
