module Slotify
  class Helpers
    include Utils

    def initialize(view_context)
      @view_context = view_context
    end

    def respond_to_missing?(name, include_private = false)
      @view_context.respond_to?(name) || @view_context.tag.respond_to?(name)
    end

    def method_missing(name, *args, **options, &block)
      results = with_resolved_args(args, options, block) do |rargs, roptions, rblock|
        call_helper(name, *rargs, **roptions.to_h, &rblock)
      end
      results.reduce(ActiveSupport::SafeBuffer.new) { _1 << _2 }
    end

    private

    def call_helper(name, ...)
      if @view_context.respond_to?(name)
        @view_context.public_send(name, ...)
      else
        @view_context.tag.public_send(name, ...)
      end
    end
  end
end
