module Slotify
  class EntryOptions < ActiveSupport::OrderedOptions
    def initialize(view_context, options = {})
      @view_context = view_context
      merge!(options)
    end

    def except(...)
      EntryOptions.new(@view_context, to_h.except(...))
    end

    def slice(...)
      EntryOptions.new(@view_context, to_h.slice(...))
    end

    def to_s
      @view_context.tag.attributes(self)
    end
  end
end
