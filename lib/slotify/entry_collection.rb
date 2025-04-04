module Slotify
  class EntryCollection
    include Enumerable

    delegate_missing_to :@entries

    def initialize(entries = [])
      @entries = entries.is_a?(Entry) ? [entries] : entries
    end

    def with_default_options(...)
      EntryCollection.new(map { _1.with_default_options(...) })
    end

    def with_partial_path(...)
      EntryCollection.new(map { _1.with_partial_path(...) })
    end

    def to_s
      @entries.reduce(ActiveSupport::SafeBuffer.new) do |buffer, entry|
        buffer << entry.to_s
      end
    end

    def render_in(view_context, &block)
      @entries.reduce(ActiveSupport::SafeBuffer.new) do |buffer, entry|
        buffer << entry.render_in(view_context, &block)
      end
    end
  end
end
