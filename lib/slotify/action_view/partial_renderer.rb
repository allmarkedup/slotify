module Slotify
  module ActionView
    module PartialRenderer
      def render_partial_template(view, locals, template, layout, block)
        view.capture_with_outer_partial_access(&block) if block && !template.has_capturing_yield?
        super
      end
    end
  end
end
