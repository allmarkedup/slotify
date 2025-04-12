module Slotify
  class Partial
    include InflectionHelper

    attr_reader :outer_partial

    def initialize(view_context)
      @view_context = view_context
      @outer_partial = view_context.partial
      @values = []
      @strict_slots = nil
    end

    def content_for(slot_name, fallback_value = nil)
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot_defined?(slot_name)

      values = slot_values(slot_name)
      if values.none? && !fallback_value.nil?
        values = add_values(slot_name, Array(fallback_value))
      end

      singular?(slot_name) ? values.first : ValueCollection.new(values)
    end

    def content_for?(slot_name)
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot_defined?(slot_name)

      slot_values(slot_name).any?
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
      pairs = @strict_slots.map do |slot_name|
        values = slot_values(slot_name)
        values = singular?(slot_name) ? values&.first : values
        [slot_name, values]
      end
      pairs.filter do |key, value|
        # keep empty strings as local value but filter out empty arrays
        # and objects so they don't override any default values set via strict slots.
        value.is_a?(String) || value&.present?
      end.to_h
    end

    def with_strict_slots(strict_slot_names)
      @strict_slots = strict_slot_names.map(&:to_sym)
      validate_slots!
    end

    def respond_to_missing?(name, include_private = false)
      name.start_with?("with_")
    end

    def method_missing(name, *args, **options, &block)
      if name.start_with?("with_")
        slot_name = name.to_s.delete_prefix("with_")
        if singular?(slot_name)
          add_value(slot_name, args, options, block)
        else
          collection = args.first
          add_values(slot_name, collection, options, block)
        end
      end
    end

    private

    def slots_defined?
      !@strict_slots.nil?
    end

    def slot_defined?(slot_name)
      slot_name && (@strict_slots.nil? || @strict_slots.include?(slot_name.to_sym))
    end

    def slot_values(slot_name)
      @values.filter { _1.slot_name == singularize(slot_name) }
    end

    def add_values(slot_name, collection, options = {}, block = nil)
      collection.map { add_value(slot_name, _1, options, block) }
    rescue NoMethodError
      raise SlotArgumentError, "expected array to be passed to slot :#{slot_name} (received #{collection.class.name})"
    end

    def add_value(slot_name, args = [], options = {}, block = nil)
      MethodArgsResolver.call(args, options, block) do
        @values << Value.new(@view_context, singularize(slot_name), _1, _2, _3)
      end

      @values.last
    end

    def validate_slots!
      return if @strict_slots.nil?

      singular_slots = @strict_slots.map { singularize(_1) }
      slots_called = @values.map(&:slot_name).uniq
      undefined_slots = slots_called - singular_slots

      if undefined_slots.any?
        raise UndefinedSlotError, "missing slot #{"definition".pluralize(undefined_slots.size)} for `#{undefined_slots.map { ":#{_1}(s)" }.join(", ")}`"
      end

      @strict_slots.filter { singular?(_1) }.each do |slot_name|
        values = slot_values(slot_name)
        raise MultipleSlotEntriesError, "slot :#{slot_name} called #{values.size} times (expected 1)" if values.many?
      end
    end
  end
end
