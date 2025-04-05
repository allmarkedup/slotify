module Slotify
  class ValueCollection
    include Enumerable

    delegate_missing_to :@values

    def initialize(values = [])
      @values = values.is_a?(Value) ? [values] : values
    end

    def with_default_options(...)
      ValueCollection.new(map { _1.with_default_options(...) })
    end

    def with_partial_path(...)
      ValueCollection.new(map { _1.with_partial_path(...) })
    end

    def to_s
      @values.reduce(ActiveSupport::SafeBuffer.new) do |buffer, value|
        buffer << value.to_s
      end
    end

    def render_in(view_context, &block)
      @values.reduce(ActiveSupport::SafeBuffer.new) do |buffer, value|
        buffer << value.render_in(view_context, &block)
      end
    end
  end
end
