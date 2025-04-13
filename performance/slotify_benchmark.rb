require_relative "../lib/slotify"
require_relative "setup"

controller_view = BenchmarksController.new.view_context

Benchmark.ips do |x|
  x.time = 10
  x.warmup = 2

  x.report("no slots") do
    controller_view.render(
      "no_slots",
      title: "Slotify - no slots",
      description: "The description",
      items: BenchmarkHelpers.random_array
    )
  end

  x.report("slots") do
    controller_view.render("slotify_slots", title: "Slotify - with slots") do |partial|
      partial.with_description do
        "The description"
      end
      partial.with_items Array.new(10) { rand(1...9) }
    end
  end

  x.compare!
end
