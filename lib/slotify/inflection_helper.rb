module Slotify
  module InflectionHelper
    extend ActiveSupport::Concern

    def singular?(str)
      str = str.to_s
      str.singularize == str && str.pluralize != str
    end

    def singularize(sym)
      sym.to_s.singularize.to_sym
    end

    def plural?(str)
      !singular?(str)
    end
  end
end
