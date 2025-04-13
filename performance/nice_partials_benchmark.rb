require_relative "setup"
require "nice_partials"

controller_view = BenchmarksController.new.view_context

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report("no slots") do
    controller_view.render(
      "no_slots",
      title: "Nice Partials - no slots",
      description: "The description",
      items: BenchmarkHelpers.random_array
    )
  end

  x.report("slots") do
    controller_view.render("nice_partials_slots", title: "Nice Partials - with slots") do |partial|
      partial.description do
        "The description"
      end
      partial.items BenchmarkHelpers.random_array
    end
  end

  x.compare!
end
