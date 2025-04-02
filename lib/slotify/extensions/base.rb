module Slotify
  module Extensions
    module Base
      attr_reader :partial

      def render(target = {}, locals = {}, &block)
        @partial = Slotify::Partial.new(self)

        if target.is_a?(Entry) || target.is_a?(EntryCollection)
          @partial.render(target, locals, &block)
        else
          super
        end
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
