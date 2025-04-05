module Slotify
  class ValueOptions < ActiveSupport::OrderedOptions
    def initialize(view_context, options = {})
      @view_context = view_context
      merge!(options)
    end

    def except(...)
      ValueOptions.new(@view_context, to_h.except(...))
    end

    def slice(...)
      ValueOptions.new(@view_context, to_h.slice(...))
    end

    def to_s
      @view_context.tag.attributes(self)
    end
  end
end
