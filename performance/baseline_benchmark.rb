require_relative "setup"

controller_view = BenchmarksController.new.view_context

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report("no slots") do
    controller_view.render(
      "no_slots",
      title: "ActionView - no slots",
      description: "The description",
      items: BenchmarkHelpers.random_array
    )
  end

  x.report("slots equivalent") do
    description = controller_view.capture { "The description" }
    items = Array.new(10) { rand(1...9) }
    controller_view.render("actionview_slots", title: "Slotify - With slots", description:, items:)
  end

  x.compare!
end
