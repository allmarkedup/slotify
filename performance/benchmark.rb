require "benchmark/ips"
require "rails"
require "active_support"
require "action_controller/railtie"

ENV["RAILS_ENV"] = "production"

class BenchmarkApp < Rails::Application
  config.root = __dir__
  config.hosts << "slotify.build"
  credentials.secret_key_base = "slotify_secret_key"
  config.cache_classes = true
end

class BenchmarksController < ActionController::Base; end  # rubocop:disable Rails/ApplicationController

BenchmarksController.view_paths = [File.expand_path("./views", __dir__)]

subject = ActiveSupport::StringInquirer.new(ENV.fetch("SUBJECT", "baseline"))
slots = ENV.fetch("SLOTS", "true") != "false"

if subject.nice_partials?
  require "nice_partials"
elsif subject.view_component?
  require "view_component"

  module Performance
    require_relative "components/no_slots_component"
    require_relative "components/slots_component"
  end
elsif subject.slotify?
  require_relative "../lib/slotify"
end

controller_view = BenchmarksController.new.view_context

title = "The title"
description = "The description"
items = Array.new(10) { rand(1...9) }

Benchmark.ips do |x|
  x.time = 5
  x.warmup = 1

  if slots
    x.report("baseline") do
      description = controller_view.capture { description }
      controller_view.render("action_view_slots", title:, description:, items:)
    end

    x.report("slots") do
      if subject.nice_partials?
        controller_view.render("nice_partials_slots", title:) do |partial|
          partial.description do
            description
          end
          partial.items items
        end
      elsif subject.view_component?
        controller_view.render(Performance::SlotsComponent.new(title:)) do |component|
          component.with_description do
            description
          end
          items.each { component.with_item _1 }
        end
      elsif subject.slotify?
        controller_view.render("slotify_slots", title:) do |partial|
          partial.with_description do
            description
          end
          items.each { partial.with_item _1 }
        end
      end
    end
  else
    x.report("baseline") do
      controller_view.render("action_view_no_slots", title:, description:, items:)
    end

    x.report("no slots") do
      if subject.nice_partials?
        controller_view.render("nice_partials_no_slots", title:, description:, items:)
      elsif subject.view_component?
        controller_view.render(Performance::NoSlotsComponent.new(title:, description:, items:))
      elsif subject.slotify?
        controller_view.render("slotify_no_slots", title:, description:, items:)
      end
    end
  end

  x.hold! "tmp/benchmark_results"
  x.compare!
end
