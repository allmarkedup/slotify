module Slotify
  class Partial
    include Utils

    attr_reader :outer_partial

    def initialize(view_context)
      @view_context = view_context
      @outer_partial = view_context.partial
      @entries = []
      @strict_slots = nil
    end

    def content_for(slot_name, fallback_value = nil)
      raise SlotsAccessError, "slot content cannot be accessed from outside the partial" unless slots_defined?
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot_defined?(slot_name)

      entries = slot_entries(slot_name)
      if entries.none? && !fallback_value.nil?
        entries = add_entries(slot_name, to_array(fallback_value))
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
          add_entries(slot_name, args.first, options, block)
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
      @entries.filter { _1.slot_name == singularize(slot_name) }
    end

    def add_entries(slot_name, collection, options = {}, block = nil)
      unless collection.respond_to?(:each)
        raise ArgumentError, "expected array to be passed to slot :#{slot_name} (received #{collection.class.name})"
      end

      collection.map { add_entry(slot_name, _1, options, block) }
    end

    def add_entry(slot_name, args = [], options = {}, block = nil)
      with_resolved_args(args, options, block) do |rargs, roptions, rblock|
        @entries << Entry.new(@view_context, singularize(slot_name), rargs, roptions, rblock)
      end

      @entries.last
    end

    def validate_slots!
      return if @strict_slots.nil?

      singular_slots = @strict_slots.map { singularize(_1) }
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
