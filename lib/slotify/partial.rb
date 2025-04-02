module Slotify
  class Partial
    include Utils

    attr_reader :outer_partial

    def initialize(view_context)
      @view_context = view_context
      @outer_partial = view_context.partial
      @entries = []
      @strict_slots = false
    end

    def content_for(slot_name, fallback_value = nil)
      raise SlotsAccessError, "slot content cannot be accessed from outside the partial" unless slots_defined?
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot_defined?(slot_name)

      entries = slot_entries(slot_name)

      if entries.none? && !fallback_value.nil?
        if plural?(slot_name) && fallback_value.is_a?(Array)
          fallback_value.each { entries << add_entry(slot_name, [_1]) }
        else
          entries << add_entry(slot_name, [fallback_value])
        end
      end

      singular?(slot_name) ? entries.first : EntryCollection.new(entries)
    end

    def content_for?(slot_name)
      raise SlotsAccessError, "slot content cannot be accessed from outside the partial" unless slots_defined?
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot_defined?(slot_name)

      slot_entries(slot_name).any?
    end

    def capture(*args, &block)
      @captured_buffer = @view_context.capture(*args, self, &block)
    end

    def yield(*args)
      if args.empty?
        @captured_buffer
      else
        content_for(args.first)
      end
    end

    def slot_locals
      @strict_slots.map { [_1, content_for(_1).presence] }.to_h.compact
    end

    def with_strict_slots(strict_slot_names)
      @strict_slots = strict_slot_names.map(&:to_sym)
      validate_slots!
    end

    def render(target, locals = {}, &block)
      if target.is_a?(EntryCollection)
        target.reduce(ActiveSupport::SafeBuffer.new) { |buffer, entry| buffer << render(entry, locals) }
      elsif target.is_a?(Entry)
        if locals.key?(:partial) || locals.key?(:locals)
          partial_path = locals[:partial] || target.to_partial_path
          options = merge_tag_options(locals.fetch(:locals, {}), target.options)
          @view_context.render(partial_path, options, &target.block)
        else
          target.with_default_options(locals).render_in(@view_context, &target.block)
        end
      else
        @view_context.render(target, locals, &block)
      end
    end

    def helpers
      @helpers || Helpers.new(@view_context)
    end

    def respond_to_missing?(name, include_private = false)
      name.start_with?("with_") || helpers.respond_to?(name)
    end

    def method_missing(name, *args, **options, &block)
      if name.start_with?("with_")
        slot_name = name.to_s.delete_prefix("with_")
        if singular?(slot_name)
          add_entry(slot_name, args, options, block)
        else
          collection = args.shift
          unless collection.respond_to?(:each)
            raise SlotArgumentError, "first argument for plural slot setter :#{name} must be an array"
          end
          collection.each { add_entry(slot_name.singularize, [_1, *args], options, block) }
        end
      else
        helpers.public_send(name, *args, **options, &block)
      end
    end

    private

    def slots_defined?
      !@strict_slots.nil?
    end

    def slot_defined?(slot_name)
      slot_name && slots_defined? && @strict_slots.include?(slot_name.to_sym)
    end

    def slot_entries(slot_name)
      @entries.filter { _1.slot_name == slot_name.to_s.singularize.to_sym }
    end

    def add_entry(slot_name, args = [], options = {}, block = nil)
      slot_name = slot_name.to_s.singularize.to_sym
      if args.first.is_a?(Entry)
        entry = args.shift
        entry = entry.to_entry
        args, options, block = entry.merged_args(args, options, block)
      end

      @entries << Entry.new(@view_context, slot_name, args, options, block)
      @entries.last
    end

    def validate_slots!
      return if @strict_slots.nil?

      singular_slots = @strict_slots.map { _1.to_s.singularize.to_sym }
      slots_called = @entries.map(&:slot_name).uniq
      undefined_slots = slots_called - singular_slots

      if undefined_slots.any?
        raise UndefinedSlotError, "missing slot #{"definition".pluralize(undefined_slots.size)} for `#{undefined_slots.map { ":#{_1}(s)" }.join(", ")}`"
      end

      @strict_slots.filter { singular?(_1) }.each do |slot_name|
        entries = slot_entries(slot_name)
        raise MultipleSlotEntriesError, "slot :#{slot_name} called #{entries.size} times (expected 1)" if entries.many?
      end
    end
  end
end
