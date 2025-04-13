require_relative "setup"
require "view_component"

module Performance
  require_relative "components/no_slots_component"
  require_relative "components/slots_component"
end

controller_view = BenchmarksController.new.view_context

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report("no slots") do
    controller_view.render(
      Performance::NoSlotsComponent.new(
        title: "ViewComponent - no slots",
        description: "The description",
        items: BenchmarkHelpers.random_array
      )
    )
  end

  x.report("slots") do
    controller_view.render(Performance::SlotsComponent.new(title: "ViewComponent - with slots")) do |component|
      component.with_description do
        "The description"
      end
      BenchmarkHelpers.random_array.each { component.with_item _1 }
    end
  end

  x.compare!
end
