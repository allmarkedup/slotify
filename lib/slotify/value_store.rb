module Slotify
  class ValueStore
    include SymbolInflectionHelper

    def initialize(view_context)
      @view_context = view_context
      @values = []
    end

    def for(slot_name)
      @values.select { _1.slot_name == singularize(slot_name) }
    end

    def add(slot_name, args = [], options = {}, block = nil)
      if plural?(slot_name)
        Array.wrap(args.shift).map { add(singularize(slot_name), [_1, *args], options, block) }
      else
        @values << Value.new(@view_context, args, options, block, slot_name: singularize(slot_name))
      end
    end

    def slot_names
      @values.map(&:slot_name).uniq
    end
  end
end
