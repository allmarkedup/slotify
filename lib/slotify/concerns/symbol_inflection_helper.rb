module Slotify
  module SymbolInflectionHelper
    extend ActiveSupport::Concern

    mattr_accessor :singularizations, default: {}

    def singular?(sym)
      singularize(sym.to_sym) == sym.to_sym
    end

    def plural?(sym)
      !singular?(sym)
    end

    def singularize(sym)
      singularizations[sym.to_sym] ||= sym.to_s.singularize.to_sym
    end
  end
end
