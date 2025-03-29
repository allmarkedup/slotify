module Slotify
  class Partial
    include Utils

    SLOTS_REGEX = /\#\s+slots:\s+\((.*)\)/

    attr_reader :outer_partial

    def initialize(view_context)
      @view_context = view_context
      @outer_partial = view_context.partial
      @entries = []
      @slot_names = nil
    end

    def content_for(slot_name)
      raise SlotError, "slots content cannot be accessed before the slots are defined" if @slot_names.nil?
      raise UnknownSlotError, "unknown slot `#{slot_name}`" unless @slot_names.include?(slot_name.to_sym)

      matches = @entries.filter { _1.slot_name == slot_name.to_s.singularize.to_sym }
      singular?(slot_name) ? matches.first : EntryCollection.new(matches)
    end

    def capture(*args, &block)
      @captured_buffer = @view_context.capture(*args, self, &block)
    end

    def yield(*args)
      if args.empty?
        @captured_buffer
      else
        content_for(args.first).to_s
      end
    end

    def render(target, locals = {}, &block)
      if target.is_a?(EntryCollection)
        target.reduce(ActiveSupport::SafeBuffer.new) { _1 << render(_2, locals) }
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

    def define_slots(slot_definitions)
      @slot_names = slot_definitions.map { _1.first.to_sym }
      entries_slot_names = @entries.map(&:slot_name).uniq
      undefined_slot_names = entries_slot_names - @slot_names.map { _1.to_s.singularize.to_sym }

      if undefined_slot_names.any?
        display_slot_names = undefined_slot_names.map { "#{_1}/#{_1.to_s.pluralize}" }
        raise SlotError, "missing slot #{"definition".pluralize(display_slot_names.size)} for `#{display_slot_names.join(", ")}`"
      end

      slot_definitions.each do |definition|
        name = definition.first.to_s
        required = definition.size == 1
        single_entry_slot = singular?(name)
        entries = @entries.filter { _1.slot_name == name.singularize.to_sym }

        if required && entries.none?
          raise SlotError, "missing required content for slot `#{name}`"
        end

        if single_entry_slot && entries.many?
          raise SlotError, "singular `#{name}` slot called #{entries.size} times (expected 1)"
        end

        if !required && entries.none? && definition.last != "nil"
          default_value = @view_context.compiled_method_container.instance_eval(definition.last)
          add_entry(name, [default_value])
        end
      end

      define_accessors(@slot_names)
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
            raise SlotArgumentError, "first argument for plural slot setter `#{name}` must be an array"
          end
          collection.each { add_entry(slot_name.singularize, [_1, *args], options, block) }
        end
      else
        helpers.public_send(name, *args, **options, &block)
      end
    end

    private

    def add_entry(slot_name, args = [], options = {}, block = nil)
      if args.first.respond_to?(:to_entry)
        entry = args.shift
        entry = entry.to_entry
        args, options, block = entry.merged_args(args, options, block)
      end

      @entries << Entry.new(@view_context, slot_name, args, options, block)
    end

    def define_accessors(slot_names)
      slot_names.each do |name|
        self.class.define_method(name) { content_for(name) }
        self.class.define_method(:"#{name}?") { content_for(name).any? }

        @view_context.class.define_method(name) { partial.content_for(name) }
        @view_context.class.define_method(:"#{name}?") { partial.content_for(name).present? }
      end
    end

    class << self
      def parse_slots_definition(source)
        source.sub!(SLOTS_REGEX, "")
        definitions = $1
        definitions
          .split(",")
          .map(&:strip)
          .filter { !["&_", "**", "**nil"].include?(_1) }
          .map { _1.split(":", 2).map(&:strip) }
          .uniq(&:first)
      end
    end
  end
end
