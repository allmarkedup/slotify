module Slotify
  module Extensions
    module Base
      include SlotCompatability

      attr_accessor :slotify

      def capture_with_outer_slotify_access(*args, &block)
        inner_slotify, @slotify = slotify, slotify.outer_slotify
        inner_slotify.capture(*args, &block)
      ensure
        @slotify = inner_slotify
      end

      make_compatible_with_slots :url_for, :link_to, :button_to, :link_to_unless_current,
        :link_to_unless, :link_to_if, :mail_to, :sms_to, :phone_to, :tag, :content_tag
    end
  end
end
