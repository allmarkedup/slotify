module Slotify
  class EntryCollection
    include Enumerable

    delegate_missing_to :@entries

    def initialize(entries = [])
      @entries = entries.is_a?(Entry) ? [entries] : entries
    end

    def to_s
      @entries.reduce(ActiveSupport::SafeBuffer.new) do |buffer, entry|
        buffer << entry.to_s
      end
    end
  end
end
