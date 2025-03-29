module Slotify
  module Utils
    extend ActiveSupport::Concern

    def singular?(str)
      str = str.to_s
      str.singularize == str && str.pluralize != str
    end

    def plural?(str)
      !singular?(str)
    end

    def merge_tag_options(...)
      TagOptionsMerger.call(...)
    end
  end
end
