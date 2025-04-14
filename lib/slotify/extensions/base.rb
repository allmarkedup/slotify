module Slotify
  module Extensions
    module Base
      include SlotCompatability

      attr_accessor :partial

      def capture_with_outer_partial_access(*args, &block)
        inner_partial, @partial = partial, partial.outer_partial
        inner_partial.capture(*args, &block)
      ensure
        @partial = inner_partial
      end

      make_compatible_with_slots :url_for, :link_to, :button_to, :link_to_unless_current,
        :link_to_unless, :link_to_if, :mail_to, :sms_to, :phone_to, :tag, :content_tag
    end
  end
end
