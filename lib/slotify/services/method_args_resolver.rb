module Slotify
  module MethodArgsResolver
    class << self
      def call(args = [], options = {}, block = nil)
        args = args.is_a?(Array) ? args.clone : [args]
        entry_index = args.index { _1.is_a?(EntryCollection) || _1.is_a?(Entry) }
        if entry_index.nil?
          [yield(args, options, block)]
        else
          target = args[entry_index]
          entries = target.is_a?(EntryCollection) ? target : [target]
          entries.map do |entry|
            cloned_args = args.clone
            cloned_args[entry_index, 1] = entry.args.clone

            yield(
              cloned_args,
              TagOptionsMerger.call(options, entry.options),
              entry.block || block
            )
          end
        end
      end
    end
  end
end
