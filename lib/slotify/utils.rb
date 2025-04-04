module Slotify
  module Utils
    extend ActiveSupport::Concern

    def singular?(str)
      str = str.to_s
      str.singularize == str && str.pluralize != str
    end

    def singularize(sym)
      sym.to_s.singularize.to_sym
    end

    def plural?(str)
      !singular?(str)
    end

    def to_array(input)
      input.is_a?(Array) ? input : [input]
    end

    def merge_tag_options(...)
      TagOptionsMerger.call(...)
    end

    def with_resolved_args(args = [], options = {}, block = nil)
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
            merge_tag_options(options, entry.options),
            entry.block || block
          )
        end
      end
    end

    module_function :merge_tag_options
    module_function :with_resolved_args
  end
end
