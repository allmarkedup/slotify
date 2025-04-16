require "zeitwerk"
require "action_view"
require_relative "slotify/version"
require_relative "slotify/error"

loader = Zeitwerk::Loader.for_gem
loader.tag = "slotify"
loader.push_dir("#{__dir__}/slotify", namespace: Slotify)
loader.ignore("#{__dir__}/slotify/error")
loader.collapse("#{__dir__}/slotify/concerns")
loader.collapse("#{__dir__}/slotify/services")
loader.enable_reloading if ENV["RAILS_ENV"] == "development"
loader.setup

ActiveSupport.on_load :action_view do
  prepend Slotify::Extensions::Base
  ActionView::Template.prepend Slotify::Extensions::Template
  ActionView::PartialRenderer.prepend Slotify::Extensions::PartialRenderer
end

module Slotify
end
