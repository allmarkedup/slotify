module Slotify
  class Partial
    include SymbolInflectionHelper

    RESERVED_SLOT_NAMES = [
      :content, :slot, :value, :content_for,
      :capture, :yield, :partial
    ]

    attr_reader :outer_partial

    def initialize(view_context)
      @view_context = view_context
      @outer_partial = view_context.partial
      @values = ValueStore.new(@view_context)
      @defined_slots = nil
    end

    def content_for(slot_name)
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot?(slot_name)

      slot_values = values.for(slot_name)
      singular?(slot_name) ? slot_values.first : ValueCollection.new(slot_values)
    end

    def content_for?(slot_name)
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot?(slot_name)

      values.for(slot_name).any?
    end

    def capture(*args, &block)
      @captured_buffer = @view_context.capture(*args, self, &block)
    end

    def yield(*args)
      args.empty? ? @captured_buffer : content_for(args.first)
    end

    def content
      self.yield
    end

    def set_slot_default(slot_name, default_value)
      raise UnknownSlotError, "unknown slot :#{slot_name}" unless slot?(slot_name)

      if values.for(slot_name).none? && !default_value.nil?
        values.add(slot_name, Array.wrap(default_value))
      end
    end

    def slot_locals
      pairs = @defined_slots.map do |slot_name|
        slot_values = values.for(slot_name)
        slot_values = singular?(slot_name) ? slot_values&.first : slot_values
        [slot_name, slot_values]
      end

      pairs.filter do |key, value|
        # keep empty strings as local value but filter out empty arrays
        # and objects so they don't override any default values set via strict slots.
        value.is_a?(String) || value&.present?
      end.to_h
    end

    def define_slots!(slot_names)
      raise SlotsDefinedError, "Slots cannot be redefined" unless @defined_slots.nil?

      @defined_slots = slot_names.map(&:to_sym).each do |slot_name|
        if RESERVED_SLOT_NAMES.include?(singularize(slot_name))
          raise ReservedSlotNameError,
            ":#{slot_name} is a reserved word and cannot be used as a slot name"
        end

        if singular?(slot_name)
          define_single_value_slot_method(slot_name)
        else
          define_multi_value_slot_methods(slot_name)
        end
      end
    end

    private

    attr_reader :values

    def slot?(slot_name)
      slot_name && @defined_slots.include?(slot_name.to_sym)
    end

    def define_single_value_slot_method(slot_name)
      method_name = :"with_#{slot_name}"

      return if respond_to?(method_name)

      self.class.define_method(method_name) do |*args, **options, &block|
        if values.for(slot_name).any?
          raise MultipleSlotEntriesError,
            "slot :#{slot_name} is defined as a single-value slot but was called multiple times"
        end

        values.add(slot_name, args, options, block)
      end
    end

    def define_multi_value_slot_methods(slot_name)
      method_name = :"with_#{slot_name}"
      singular_slot_name = singularize(slot_name)

      return if respond_to?(method_name)

      self.class.define_method(method_name) do |*args, **options, &block|
        values.add(slot_name, args, options, block)
      end

      self.class.define_method(:"with_#{singular_slot_name}") do |*args, **options, &block|
        values.add(singular_slot_name, args, options, block)
      end
    end
  end
end
