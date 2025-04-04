module Slotify
  module SlotifyHelpers
    def slotify_helpers(*method_names)
      proxy = Module.new
      method_names.each do |name|
        proxy.define_method(name) do |*args, **kwargs, &block|
          return super(*args, **kwargs, &block) if args.none?
          results = Utils.with_resolved_args(args, kwargs, block) do
            super(*_1, **_2.to_h, &_3 || block)
          end

          results.reduce(ActiveSupport::SafeBuffer.new) { _1 << _2 }
        end
      end
      prepend proxy
    end
  end
end
