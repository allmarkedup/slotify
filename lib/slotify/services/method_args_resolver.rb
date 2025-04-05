module Slotify
  module MethodArgsResolver
    class << self
      def call(args = [], options = {}, block = nil)
        args = args.is_a?(Array) ? args.clone : [args]
        value_index = args.index { _1.is_a?(ValueCollection) || _1.is_a?(Value) }
        if value_index.nil?
          [yield(args, options, block)]
        else
          target = args[value_index]
          values = target.is_a?(ValueCollection) ? target : [target]
          values.map do |value|
            cloned_args = args.clone
            cloned_args[value_index, 1] = value.args.clone

            yield(
              cloned_args,
              TagOptionsMerger.call(options, value.options),
              value.block || block
            )
          end
        end
      end
    end
  end
end
