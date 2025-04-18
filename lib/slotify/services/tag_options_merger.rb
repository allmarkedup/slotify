module Slotify
  module TagOptionsMerger
    class << self
      def call(original, target)
        mix(original, target)
      end

      private

      # https://www.phlex.fun/sgml/helpers#mix
      def mix(*args)
        args.each_with_object({}) do |object, result|
          result.merge!(object) do |_key, old, new|
            case [old, new].freeze
            in [Array, Array] | [Set, Set]
              old + new
            in [Array, Set]
              old + new.to_a
            in [Array, String]
              old + [new]
            in [Hash, Hash]
              mix(old, new)
            in [Set, Array]
              old.to_a + new
            in [Set, String]
              old.to_a + [new]
            in [String, Array]
              [old] + new
            in [String, Set]
              [old] + new.to_a
            in [String, String]
              "#{old} #{new}"
            in [_, nil]
              old
            else
              new
            end
          end

          result.transform_keys! do |key|
            key.end_with?("!") ? key.name.chop.to_sym : key
          end
        end
      end
    end
  end
end
