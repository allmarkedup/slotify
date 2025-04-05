module Slotify
  module Extensions
    module Base
      extend SlotifyHelpers

      slotify_helpers :url_for, :link_to, :button_to, :link_to_unless_current,
        :link_to_unless, :link_to_if, :mail_to, :sms_to, :phone_to, :tag, :content_tag

      attr_reader :partial

      def render(target = {}, locals = {}, &block)
        @partial = Slotify::Partial.new(self)
        super
      ensure
        @partial = partial.outer_partial
      end

      def _layout_for(*args, &block)
        if block && args.first.is_a?(Symbol)
          capture_with_outer_partial_access(*args, &block)
        else
          super
        end
      end

      def capture_with_outer_partial_access(*args, &block)
        inner_partial, @partial = partial, partial.outer_partial
        inner_partial.capture(*args, &block)
      ensure
        @partial = inner_partial
      end
    end
  end
end
