
module Slotify
  module TagOptionsMerger
    class << self
      include ::ActionView::Helpers::TagHelper

      def call(original, target)
        original = original.to_h.deep_symbolize_keys
        target = target.to_h.deep_symbolize_keys

        target.each do |key, value|
          original[key] = case key
          when :data
            merge_data_options(original[key], value)
          when :class
            merge_class_options(original[key], value)
          else
            value
          end
        end

        original
      end

      private

      def merge_data_options(original_data, target_data)
        original_data = original_data.dup

        target_data.each do |key, value|
          values = [original_data[key], value]
          original_data[key] = if key.in?([:controller, :action]) && all_kind_of?(String, values)
            merge_strings(values)
          else
            value
          end
        end

        original_data
      end

      def merge_class_options(original_classes, target_classes)
        class_names(original_classes, target_classes)
      end

      def merge_strings(*args)
        args.map(&:presence).compact.join(' ')
      end

      def all_kind_of?(kind, values)
        values.none? { !_1.is_a?(kind) }
      end
    end
  end
end
