module Slotify
  class ValueStore
    include InflectionHelper

    def initialize(view_context)
      @view_context = view_context
      @values = []
    end

    def for(slot_name)
      @values.select { _1.slot_name == singularize(slot_name) }
    end

    def add(slot_name, args = [], options = {}, block = nil)
      if plural?(slot_name)
        Array.wrap(args.first).map { add(singularize(slot_name), _1, options, block) }
      else
        MethodArgsResolver.call(args, options, block) do
          @values << Value.new(@view_context, _1, _2, _3, slot_name: singularize(slot_name))
        end
      end
    end

    def slot_names
      @values.map(&:slot_name).uniq
    end
  end
end
