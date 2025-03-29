module Slotify
  module ActionView
    module Template
      def compile!(view)
        super
        if File.basename(short_identifier).start_with?("_")
          slot_definitions = Partial.parse_slots_definition(source)
          view.partial.define_slots(slot_definitions) if slot_definitions
        end
      end

      def has_capturing_yield?
        defined?(@has_capturing_yield) ? @has_capturing_yield :
          @has_capturing_yield = source.match?(/[^\.\b]yield[\(? ]+(%>|[^:])/)
      end
    end
  end
end
