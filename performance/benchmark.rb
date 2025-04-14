require "benchmark/ips"
require "rails"
require "active_support"
require "action_controller/railtie"

ENV["RAILS_ENV"] = "production"

target = ActiveSupport::StringInquirer.new(ENV.fetch("BENCHMARK_TARGET", "slotify"))

class BenchmarkApp < Rails::Application
  config.root = __dir__
  config.hosts << "slotify.build"
  credentials.secret_key_base = "slotify_secret_key"
  config.cache_classes = true
end

class BenchmarksController < ActionController::Base; end

BenchmarksController.view_paths = [File.expand_path("./views", __dir__)]

if target.nice_partials?
  require "nice_partials"
elsif target.view_component?
  require "view_component"

  module Performance
    require_relative "components/no_slots_component"
    require_relative "components/slots_component"
  end
elsif target.slotify?
  require_relative "../lib/slotify"
end

controller_view = BenchmarksController.new.view_context

puts "\n🏁🏁 #{target.upcase} 🏁🏁\n\n"

title = "The title"
description = "The description"
items = Array.new(10) { rand(1...9) }

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report("no slots") do
    if target.view_component?
      controller_view.render(
        Performance::NoSlotsComponent.new(title:, description:, items:)
      )
    else
      controller_view.render("no_slots", title:, description:, items:)
    end
  end

  x.report("slots") do
    if target.nice_partials?
      controller_view.render("nice_partials_slots", title:) do |partial|
        partial.description do
          description
        end
        partial.items
      end
    elsif target.view_component?
      controller_view.render(Performance::SlotsComponent.new(title:)) do |component|
        component.with_description do
          description
        end
        items.each { component.with_item _1 }
      end
    elsif target.slotify?
      controller_view.render("slotify_slots", title:) do |partial|
        partial.with_description do
          description
        end
        items.each { partial.with_item _1 }
      end
    elsif target.action_view?
      description = controller_view.capture { description }
      controller_view.render("action_view_slots", title:, description:, items:)
    end
  end

  x.compare!
end
