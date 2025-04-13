module Slotify
  module Extensions
    module PartialRenderer
      def render_partial_template(view, locals, template, layout, block)
        partial = view.partial = Slotify::Partial.new(view)

        return super unless template.strict_slots?

        partial.with_strict_slots(template.strict_slots_keys)

        view.capture_with_outer_partial_access(&block) if block
        locals = locals.merge(partial.slot_locals)

        decorate_strict_slots_errors do
          super(view, locals, template, layout, block)
        end
      ensure
        view.partial = partial.outer_partial if partial
      end

      def decorate_strict_slots_errors(&block)
        yield
      rescue ActionView::Template::Error => error
        if missing_strict_locals_error?(error)
          local_names = error.cause.message.scan(/\s:(\w+)/).flatten
          if local_names.any?
            slot_names = local_names.intersection(error.template.strict_slots_keys).map { ":#{_1}" }
            if slot_names.any?
              message = "missing #{"slot".pluralize(slot_names.size)}: #{slot_names.join(", ")} for #{error.template.short_identifier}"
              raise Slotify::StrictSlotsError, message
            end
          end
        end
        raise error
      end

      def missing_strict_locals_error?(error)
        error.template && (defined?(ActionView::StrictLocalsError) && error.cause.is_a?(ActionView::StrictLocalsError)) ||
          (error.cause.is_a?(ArgumentError) && error.cause.message.match(/missing local/))
      end
    end
  end
end
