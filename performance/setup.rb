require "benchmark/ips"
require "rails"
require "action_controller/railtie"

ENV["RAILS_ENV"] = "production"

class BenchmarkApp < Rails::Application
  config.root = __dir__
  config.hosts << "slotify.build"
  credentials.secret_key_base = "slotify_secret_key"
end

class BenchmarksController < ActionController::Base; end

module BenchmarkHelpers
  class << self
    def random_array(length = 10)
      Array.new(length) { rand(1...9) }
    end
  end
end

BenchmarksController.view_paths = [File.expand_path("./views", __dir__)]
