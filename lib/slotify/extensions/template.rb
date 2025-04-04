require "action_view/template/error"

module Slotify
  module Extensions
    module Template
      STRICT_SLOTS_REGEX = /\#\s+slots:\s+\((.*)\)/
      STRICT_SLOTS_KEYS_REGEX = /(\w+):(?=(?:[^"\\]*(?:\\.|"(?:[^"\\]*\\.)*[^"\\]*"))*[^"]*$)/

      def initialize(...)
        super
        @strict_slots = ActionView::Template::NONE
      end

      def strict_slots!
        if @strict_slots == ActionView::Template::NONE
          source.sub!(STRICT_SLOTS_REGEX, "")
          strict_slots = $1
          @strict_slots = if strict_slots.nil?
            ""
          else
            strict_slots.sub("**", "").strip.delete_suffix(",")
          end
        end

        @strict_slots
      end

      def strict_slots?
        strict_slots!.present?
      end

      def strict_slots_keys
        strict_slots!.scan(STRICT_SLOTS_KEYS_REGEX).map(&:first)
      end

      def strict_locals!
        return super unless strict_slots?

        [strict_slots!, super || "**"].compact.join(", ")
      end

      def locals_code
        return super unless strict_slots?

        strict_slots_keys.each_with_object(+super) do |key, code|
          code << "#{key} = partial.content_for(:#{key}, #{key});"
        end
      end
    end
  end
end
