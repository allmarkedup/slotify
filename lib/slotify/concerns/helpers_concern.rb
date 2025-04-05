module Slotify
  module HelpersConcern
    def make_compatible_with_slots(*method_names)
      proxy = Module.new
      method_names.each do |name|
        proxy.define_method(name) do |*args, **kwargs, &block|
          return super(*args, **kwargs, &block) if args.none?

          results = MethodArgsResolver.call(args, kwargs, block) { super(*_1, **_2, &_3) }
          results.reduce(ActiveSupport::SafeBuffer.new) { _1 << _2 }
        end
      end
      prepend proxy
    end
  end
end
