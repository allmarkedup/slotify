module Slotify
  class Helpers
    def initialize(view_context)
      @view_context = view_context
    end

    def respond_to_missing?(name, include_private = false)
      @view_context.respond_to?(name) || @view_context.tag.respond_to?(name)
    end

    def method_missing(name, *args, **kwargs, &block)
      entry_arg = args.find { _1.is_a?(EntryCollection) || _1.is_a?(Entry) }
      if entry_arg
        args.filter! { _1 != entry_arg }
        call_helper_with_entries(name, entry_arg, *args, **kwargs, &block)
      else
        call_helper(name, *args, **kwargs, &block)
      end
    end

    private

    def call_helper_with_entries(name, entries, *args, **options, &block)
      EntryCollection.new(entries).reduce(ActiveSupport::SafeBuffer.new) do |buffer, entry|
        merged_args, merged_options, merged_block = entry.merged_args(args, options, block)
        buffer << call_helper(name, *merged_args, **merged_options.to_h, &merged_block)
      end
    end

    def call_helper(name, ...)
      if @view_context.respond_to?(name)
        @view_context.public_send(name, ...)
      else
        @view_context.tag.public_send(name, ...)
      end
    end
  end
end
