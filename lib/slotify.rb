require "zeitwerk"
require "action_view"
require_relative "slotify/version"
require_relative "slotify/error"

loader = Zeitwerk::Loader.for_gem
loader.tag = "slotify"
loader.push_dir("#{__dir__}/slotify", namespace: Slotify)
loader.enable_reloading if ENV["RAILS_ENV"] == "development"
loader.setup

module Slotify
end

ActiveSupport.on_load :action_view do
  prepend Slotify::Extensions::Base
  ActionView::Template.prepend Slotify::Extensions::Template
  ActionView::PartialRenderer.prepend Slotify::Extensions::PartialRenderer
end
