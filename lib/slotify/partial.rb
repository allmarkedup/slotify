module Slotify
  class Partial
    include InflectionHelper

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
      validate_slots!

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
          raise ReservedSlotNameError, ":#{slot_name} is a reserved word and cannot be used as a slot name"
        end

        writer_method = :"with_#{slot_name}"
        unless respond_to?(writer_method)
          self.class.define_method(writer_method) { |*a, **o, &b| values.add(slot_name, a, o, b) }
        end

        if plural?(slot_name)
          singular_writer_method = :"with_#{singularize(slot_name)}"
          unless respond_to?(singular_writer_method)
            self.class.define_method(singular_writer_method) { |*a, **o, &b| values.add(singularize(slot_name), a, o, b) }
          end
        end
      end
    end

    private

    attr_reader :values

    def slot?(slot_name)
      slot_name && @defined_slots.include?(slot_name.to_sym)
    end

    def validate_slots!
      return if @defined_slots.nil?

      undefined_slots = values.slot_names - @defined_slots.map { singularize(_1) }
      if undefined_slots.any?
        raise UndefinedSlotError,
          "missing slot #{"definition".pluralize(undefined_slots.size)} for `#{undefined_slots.map { ":#{_1}(s)" }.join(", ")}`"
      end

      @defined_slots.filter { singular?(_1) }.each do |slot_name|
        slot_values = values.for(slot_name)
        raise MultipleSlotEntriesError, "slot :#{slot_name} called #{slot_values.size} times (expected 1)" if slot_values.many?
      end
    end
  end
end
