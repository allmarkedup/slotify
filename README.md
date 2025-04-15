<img src=".github/assets/slotify_wordmark.svg" width="200">

<p><a href="https://rubygems.org/gems/slotify"><img src="https://img.shields.io/gem/v/slotify" alt="Gem version"></a>
<a href="https://github.com/allmarkedup/slotify/actions/workflows/ci.yml"><img src="https://github.com/allmarkedup/slotify/actions/workflows/ci.yml/badge.svg" alt="CI status"></a></p>

## Superpowered slots for ActionView partials

Slotify brings a ViewComponent-style **content slot API** to ActionView partials.

Slots are a convenient way to pass blocks of content in to a partial without having to resort to ugly `<% capture do ... end %>` workarounds or unscoped (global) `<% content_for :foo %>` declarations. 

Slotified partials are a great way to build components in a Rails app without the additional overhead and learning curve of libraries like [ViewComponent](https://viewcomponent.org/) or [Phlex](https://www.phlex.fun/).

> [!CAUTION]
> Slotify is still in a early stage of development.
The documentation is still quite sparse and the API could change at any point prior to a `v1.0` release.

### 

## Slotify basics

Slotify slots are defined using a **[strict locals](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)-style magic comment** at the top of **partial templates** ([more details here](#defining-slots)).

```erb
<%# slots: (title:, body: nil, theme: "default") -%>
```

Slot content is accessed via **standard local variables** within the partial. So a simple, slot-enabled `example` partial template might look something like this:

```erb
# views/examples/_example.html.erb

<%# slots: (title: "Default title", body: nil) -%>
<article>
  <h1><%= title %></h1>
  <% if body.present? %>
    <div>
      <%= body %>
    </div>
  <% end %>
</article>
```

> [!NOTE]
> _The above should feel familiar to anyone who has partials (and strict locals) in the past. This is just regular partial syntax but with `slots` defined instead of `locals` (don't worry - you can still define locals too!)._

When the partial is rendered, a special `partial` object is yielded as an argument to the block. Slot content is set by calling the appropriate `#with_<slot_name>` methods on this partial object.

For example, here our `article` partial is being rendered with content for the `title` and `body` slots that were defined above:

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_title "This is a title" %>
  <% partial.with_body do %>
    <p>You can use <%= tag.strong "markup" %> within slot content blocks without
      having to worry about marking the output as <code>html_safe</code> later.</p>
  <% end %>
<% end %>
```

> [!NOTE]
> _If you've ever used [ViewComponent](https://viewcomponent.org) then the above code should also feel quite familiar to you - it's pretty much the same syntax used to provide content to [component slots](https://viewcomponent.org/guide/slots.html)._

But this example just scratches the surface of what Slotify slots can do. Have a look at the more full-featured example below or jump to [the usage information](#usage).

<details>
<summary><h4>More full-featured example</h4></summary>

```erb
# views/examples/_example.html.erb

<%# locals: (id:) -%>
<%# slots: (title: "Example title", lists: [], quotes: [], website_link:) -%>

<%= tag.section id: do %>
  <h1 class="example-title">
    <%= title %>
  </h1>
  
  <p>Example link: <%= link_to website_link, data: {controller: "external-link"} %></p>

  <%= render lists, title: "Default title" %>

  <% if quotes.any? %>
    <h3>Quotes</h3>
    <% quotes.each do |quote| %>
      <blockquote <%= quote.options.except(:citation) %>>
        <%= quote %>
        <%== "&mdash; #{tag.cite(quote.options.citation)}" if quote.options.citation.present? %>
      </blockquote>
    <% end %>
  <% end %>
<% end %>
```

```erb
# views/examples/_list.html.erb

<%# locals: (title:) -%>
<%# slots: (items: []) -%>
 
<h3><%= title %></h3>

<% if items.any? %>
  <%= tag.ul class: "list" do %>
    <%= content_tag :li, items, class: "list-item" %>
  <% end %>
<% end %>
```

```erb
# views/examples/show.html.erb

<%= render "example", id: "slotify-example" do |partial| %>
  <% partial.with_subtitle do %>
    This is the <%= tag.em "subtitle" %>
  <% end %>

  <% partial.with_website_link "example.com", "https://example.com", target: "_blank", data: {controller: "preview-link"} %>

  <% partial.with_list do |list| %>
    <% list.with_item "first thing" %> 
    <% list.with_item "second thing", class: "text-green-700" %>
    <% list.with_item "third thing" %>
  <% end %>

  <% partial.with_quote citation: "A. Person", class: "text-lg" do %>
    <p>Lorem ipsum dolor sit amet consectetur adipisicing elit.</p>
  <% end %>

  <% partial.with_quote do %>
    <p>Non quos explicabo eius hic quaerat laboriosam incidunt numquam.</p>
  <% end %>
<% end %>
```

</details>

---

## Usage

<a name="defining-slots" id="defining-slots"></a>
### Defining slots

Slots are defined using a [strict locals](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)-style magic comment at the top of the partial template. The `slots:` signature uses the same syntax as standard Ruby method signatures:

```erb
<%# slots: (title:, body: "No content available", author: nil) -%>
```

#### Required slots

Required slots are defined without a default value.
If no content is provided for a required slot then a `StrictSlotsError` exception will be raised.

```erb
# views/examples/_required.html.erb

<%# slots: (title:) -%>
<h1><%= title %></h1>

# views/examples/show.html.erb

<%= render "required" do |partial| %>  
  <!-- ❌ raises an error, no content set for the `title` slot -->
<% end %>
```

#### Optional slots

If a default value is set then the slot becomes _optional_. If no content is provided when rendering the partial then
the default value will be used instead.

```erb
<%# slots: (title: "Default title", author: nil) -%>
```

### Setting slot values

Content is passed into slots using dynamically generated `partial#with_<slot_name>` writer methods.

Content can be provided as either the **first argument** or **as a block** when calling these methods at render time.
The following two examples are equivalent:

```erb
<%= render "example" do |partial| %>
  <% partial.with_title "Title passed as argument" %>
<% end %>

<%= render "example" do |partial| %>
  <% partial.with_title do %>
    Title passed as block content
  <% end %>
<% end %>
```

> [!TIP]
> Block content is generally better suited for longer-form content containing HTML tags because it will not need to be marked
as `html_safe` when used in the partial template.

The content will be available as a local variable in the partial template whichever way it is provided.

```erb
<%# slots: (title:) -%>
<h1><%= title %></h1> 
```

### Slot options

The slot value writer methods also accept optional arbitrary keyword arguments.
These can then be accessed in the partial template via the `.options` method on the slot variable.

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_title "The title", class: "color-hotpink", data: {controller: "fancy-title"} %>
<% end %>

# views/examples/_example.html.erb

<%# slots: (title:) -%>
<%= title.options.keys %> ➡️ [:class, :data]
<%= title %>              ➡️ "The title"
```

Slot options can be useful for providing tag attributes when rendering slot content or rendering variants
of a slot based on an option value.

```erb
<%= tag.h1 **title.options %><%= title %><% end %>
➡️ <h1 class="color-hotpink" data-controller="fancy-title">The title</h1>
```

When rendered as a string the options are passed through the Rails `tag.attributes` helper to generate an HTML tag attributes string:

```erb
<h1 <%= title.options %>><%= title %></h1> 
➡️ <h1 class="color-hotpink" data-controller="fancy-title">The title</h1>
```

### Single- vs multi-value slots

There are two types of slots.

* **Single-value** slots can only be called **once** when rendering the partial. The corresponding variable in the template represents a single slot value.
* **Multi-value** slots can be called **many times** when rendering the partial. The corresponding variable in the template represents **a collection of slot values**.

#### Single-value slots

Single-value slots are defined using a **singular** slot name:

```erb
<%# slots: (item: nil) -%>
```

Single-value slots can be called once (at most)
and their corresponding template variable represents a single value:

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
<% end %>

# views/examples/_example.html.erb

<%# slots: (item: nil) -%>
<div>
  <%= item %> ➡️ "Item one"
</div>
```

> [!WARNING]
> Calling a single-value slot more than once when rendering a partial will raise an error:
> 
> ```erb
> <%= render "example" do |partial| %>
>   <% partial.with_item "Item one" %>
>   <% partial.with_item "Item two" %> ❌ raises an error!
> <% end %>
> ```

#### Multi-value slots

Multi-value slots are defined using a **plural** slot name:

```erb
<%# slots: (items: []) -%>
```

Multi-value slots can be called as many times as needed
and their corresponding template variable represents an array of values.

The slot writer methods for multi-value slots use the **singluar form** of the slot name (e.g. `#with_item` for the `items` slot).

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
  <% partial.with_item "Item two" %>
  <% partial.with_item "Item three" %>
<% end %>

# views/examples/_example.html.erb

<%# slots: (items: []) -%>

<%= items %> ➡️ ["Item one", "Item two", "Item three"]

<ul>
  <% items.each do |item| %>
    <li>
      <% item %>
    </li>
  <% end %>
</ul>

➡️ <ul><li>Item one</li><li>Item two</li><li>Item three</li></ul>
```

### Using with view helpers

Slot values can be used with Rails view helpers (such as tag helpers) in the partial templates in the usual way:

```erb
<%= tag.h1 title %>
```

[Slot options](#slot-options) can be passed to helpers alongside the content by splatting slot value `.options`:

```erb
<%= tag.h1 title, **title.options %>
```

#### Slotified helpers

Slotify patches a number of the most commonly used view helpers (such as `content_tag`, `link_to`) so that slot value arguments and options are transparently expanded and passed to the underlying helper. This means that manual args/options splatting (as described above) is not required.

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_title "The title", class: "color-hotpink" %>
  <% partial.with_website_link "Example website", "https://example.com", data: {controller: "clicker"} %>
<% end %>

# views/examples/_example.html.erb

<%# slots: (title: nil, website_link: nil) -%>

<%= content_tag :h1, title %>
➡️ <h1 class="color-hotpink">The title</h1>

<%= link_to website_link %>
➡️ <a href="https://example.com" data-controller="clicker">Example website</a>
```

Any options provided to the helper are 'smart-merged' with slot value options using the [Phlex `mix` helper](https://www.phlex.fun/sgml/helpers#mix) which allows for class names and data attribute options to be combined as token lists rather than overwritten when merged.

```erb
<%= content_tag :h1, title, class: "text-xl", id: "headline" %> <!-- options here are merged with slot value options -->
➡️ <h1 class="text-xl color-hotpink" id="headline">The title</h1>

<%= link_to website_link, target: "_blank" %>
➡️ <a href="https://example.com" data-controller="clicker" target="_blank">Example website</a>
```

If a slotified helper is provided with a slot value collection (i.e. from a [multi-value slot](#multi-value-slots)) then the helper will be run once for each value in the collection:

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
  <% partial.with_item "Item two", class: "highlight" %>
<% end %>

# views/examples/_example.html.erb

<%# slots: (items: []) -%>

<%= content_tag :li, items %>
➡️ <li>Item one</li><li class="highlight">Item two</li>

<%= content_tag :li, items, class: "item" %>
➡️ <li class="item">Item one</li><li class="item highlight">Item two</li>
```

#### List of 'slotified' helpers

* `tag` _(top-level `tag` helper only, not the `tag.<tag_name>` shorthands)_
* `content_tag`
* `link_to`
* `link_to_if`
* `link_to_unless`
* `link_to_unless_current`
* `button_to`
* `mail_to`
* `sms_to`
* `phone_to`
* `url_for`

### Using alongside strict locals

Strict locals can be defined in 'slotified' partial templates in the same way as usual,
either above or below the `slots` definition.

```erb
# views/examples/_example.html.erb

<%# locals: (title:) -%>
<%# slots: (body: "No content available") -%>

<article>
  <h1><%= title %></h1>
  <div><%= body %></div>
</article>
```

Locals are provided when rendering the partial in the usual way.

```erb
# views/examples/show.html.erb

<%= render "article", title: "Article title here" do |partial| %>
  <% partial.with_body do %>
    <p>Body content here...</p>
  <% end %>
<% end %>
```

### Rendering slots

> _Docs coming soon..._ 

### Slot values API

**Singlular slot value variables** in partial templates are actually instances of `Slotity::Value`.
These value objects are automatically stringified so in most cases you will not even be aware of this and they can just be treated as regular string variables.

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_title class: "color-hotpink" do %>
    The title
  <% end %>
<% end %>
```

```erb
# views/examples/_example.html.erb

<%# slots: (title: nil) -%>

<% title.is_a?(Slotify::Value) %> ➡️ true

<%= title %>         ➡️ "The title"
<% title.content %>  ➡️ "The title"

<% title.options %>  ➡️ { class: "color-hotpink" }
<%= title.options %> ➡️ "class='color-hotpink'" 
```

**Plural slot value variables** in partial templates are instances of the enumerable `Slotify::ValueCollection` class, with all items instances of `Slotity::Value`.

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
  <% partial.with_item "Item two", class: "current" %>
<% end %>
```

```erb
# views/examples/_example.html.erb

<%# slots: (items: []) -%>

<% items.is_a?(Slotify::ValueCollection) %> ➡️ true

<% items.each do |item| %>
  <li <%= item.options %>><%= item %></li>
<% end %>
➡️ <li>Item one</li> <li class="current">Item two</li>

<%= items %> ➡️ "Item one Item two"
```

#### `Slotity::Value`

The following methods are available on `Slotity::Value` instances:

**`.content`**

Returns the slot content string that was provided as the first argument or as the block when calling the slot writer method.

**`.options`**

Returns a `Slotify::ValueOptions` instance that can be treated like a `Hash`. Calling `.slice` or `.except` on this will return another `Slotify::ValueOptions` instance.

When converted to a string either explicitly (via `.to_s`) or implicitly (by outputting the value template using ERB `<%= %>` expression tags) the stringified value is generated by passing the options hash through the Rails `tag.attributes` helper.

**`.args`**

Returns an array of the arguments that were passed into the slot writer method (if any) when rendering the partial.

Slot arguments can also be accessed using hash access notation.

```erb
# views/examples/show.html.erb

<%= render "example" do |partial| %>
  <% partial.with_link "Example link", "https://example.com", class: "external-link" %>
<% end %>
```

```erb
# views/examples/_example.html.erb

<%# slots: (link: nil) -%>

<% link.args %> ➡️ ["Example link", "https://example.com"]
<% link[0] %>   ➡️ "Example link"
<% link[1] %>   ➡️ "https://example.com"
```

**`.with_default_options(default_options)`**

Merges the options set when calling the slot value writer method with the `default_options` hash provided and returns a new `Slotity::Value` instance with the merged options set.

```erb
<% title_with_defaults = title.with_default_options(class: "size-lg", aria: {level: 1}) %> 

<% title_with_defaults.options %>  ➡️ { class: "size-lg color-hotpink", aria: {level: 1} }
<%= title_with_defaults.options %> ➡️ "class='size-lg color-hotpink' aria-level='1'"
```

## Slotify vs alternatives

#### `nice_partials`

Slotify was very much inspired by the [Nice Partials gem](https://github.com/bullet-train-co/nice_partials) and both provide similar functionality.
However there are a number of key differences:

* Slotify requires the explicit definition of slots using 'strict locals'-style comments;
Nice partials slots are implicitly defined when rendering the partial.
* Slotify slot values are available as local variables;
with Nice partials slot values are accessed via methods a single `partial` variable.
* Slotify has the concept (and enforces the use) of single- vs. multi-value slots.
* Slotify slot content and options are transparently expanded and merged into defaults when using with helpers like `content_tag` and `link_to`.
* Slotify slot values are `renderable` objects.

You might choose slotify if you prefer a stricter, 'Rails-native'-feeling slots implementation, and Nice Partials if you want more render-time flexibility and a clearer
separation of 'nice partial' functionality from ActionView-provided locals etc.

#### `view_component`

Both [ViewComponent](https://viewcomponent.org/) and Slotify provide a 'slots' API for content blocks.
Slotify's slot writer syntax (i.e. `.with_<slot_name>` methods) and the concept of single-value (`renders_one`) vs multi-value (`renders_many`) slots are both modelled on ViewComponent's slots implementation.

However apart from that they are quite different. Slotify adds functionality to regular ActionView partials whereas ViewComponent provides a complete standalone component system.

Each ViewComponent has an associated class which can be used to extract and encapsulate view logic.
Slotify doesn't have an analagous concept, any view-specific logic will by default live in the partial template (as per standard partial rendering patterns). 

You might choose Slotify if you want a more 'component-y' API but you don't want the overhead or learning curve associated with a tool that sits somewhat adjacent to the standard Rails way of doing things.
But if you have components with a lot of view logic or want a more formalised component format then ViewComponent is likely a better fit for your project.

## Installation

Add the following to your Rails app Gemfile:

```rb
gem "slotify"
```

And then run `bundle install`. You are good to go!

## Requirements

* `Rails 7.1+`
* `Ruby 3.1+`

## Testing 

Slotify uses MiniTest for its test suite.

[Appraisal](https://github.com/thoughtbot/appraisal) is used in CI to test against a matrix of Ruby/Rails versions.

#### Run tests

```shell
bin/test
```

### Benchmarks

Some crude render performance benchmark tests for `slotify`, `view_component` and `nice_partials` can be found in the `/performance` directory.

All benchmarks use a 'vanilla' ActionView template rendering performance measurement as the baseline for comparison against.

The benchmark tests are a little crude right now so any suggestions for improvements would be much appreciated!

**Running benchmarks:**

You can run the benchmark tests locally using the `bin/benchmark` command from the root of the repository.

```shell
bin/benchmarks # run all benchmarks
bin/benchmarks slotify # run specified benchmarks only (slotify / view_component / nice_partials)
bin/benchmarks --no-slots # run benchmarks for rendering without slots
```

<details>
<summary>Recent benchmark results</summary>

#### Slots benchmark

```
🏁🏁 NICE_PARTIALS 🏁🏁

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            baseline    11.951k i/100ms
Calculating -------------------------------------
            baseline    119.604k (± 4.0%) i/s    (8.36 μs/i) -    597.550k in   5.005305s

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
               slots     3.745k i/100ms
Calculating -------------------------------------
               slots     38.156k (± 3.3%) i/s   (26.21 μs/i) -    194.740k in   5.110455s

Comparison:
            baseline:   119603.6 i/s
               slots:    38156.2 i/s - 3.13x  slower


🏁🏁 VIEW_COMPONENT 🏁🏁

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            baseline    12.155k i/100ms
Calculating -------------------------------------
            baseline    120.458k (± 1.9%) i/s    (8.30 μs/i) -    607.750k in   5.047144s

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
               slots     7.636k i/100ms
Calculating -------------------------------------
               slots     76.412k (± 3.2%) i/s   (13.09 μs/i) -    381.800k in   5.002530s

Comparison:
            baseline:   120458.2 i/s
               slots:    76412.0 i/s - 1.58x  slower


🏁🏁 SLOTIFY 🏁🏁

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            baseline    11.988k i/100ms
Calculating -------------------------------------
            baseline    119.934k (± 3.0%) i/s    (8.34 μs/i) -    599.400k in   5.002971s

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
               slots     2.656k i/100ms
Calculating -------------------------------------
               slots     26.854k (± 1.2%) i/s   (37.24 μs/i) -    135.456k in   5.044894s

Comparison:
            baseline:   119933.6 i/s
               slots:    26853.9 i/s - 4.47x  slower
```

#### No slots benchmark

```
🏁🏁 NICE_PARTIALS 🏁🏁

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            baseline    13.033k i/100ms
Calculating -------------------------------------
            baseline    131.323k (± 1.0%) i/s    (7.61 μs/i) -    664.683k in   5.061999s

Pausing here -- run Ruby again to measure the next benchmark...

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots     4.659k i/100ms
Calculating -------------------------------------
            no slots     46.284k (± 2.8%) i/s   (21.61 μs/i) -    232.950k in   5.037627s

Comparison:
            baseline:   131322.8 i/s
            no slots:    46283.7 i/s - 2.84x  slower


🏁🏁 VIEW_COMPONENT 🏁🏁

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            baseline    12.845k i/100ms
Calculating -------------------------------------
            baseline    134.644k (± 1.6%) i/s    (7.43 μs/i) -    680.785k in   5.057489s

Pausing here -- run Ruby again to measure the next benchmark...

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots    20.785k i/100ms
Calculating -------------------------------------
            no slots    206.431k (± 3.7%) i/s    (4.84 μs/i) -      1.039M in   5.042744s

Comparison:
            no slots:   206431.4 i/s
            baseline:   134643.7 i/s - 1.53x  slower


🏁🏁 SLOTIFY 🏁🏁

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            baseline    13.247k i/100ms
Calculating -------------------------------------
            baseline    132.155k (± 2.9%) i/s    (7.57 μs/i) -    662.350k in   5.016827s

Pausing here -- run Ruby again to measure the next benchmark...

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots    11.537k i/100ms
Calculating -------------------------------------
            no slots    115.974k (± 1.8%) i/s    (8.62 μs/i) -    588.387k in   5.075197s

Comparison:
            baseline:   132154.8 i/s
            no slots:   115974.0 i/s - 1.14x  slower
```

</details>

## Credits

Slotify was inspired by the excellent [nice_partials gem](https://github.com/bullet-train-co/nice_partials) as well as ViewComponent's [slots implementation](https://viewcomponent.org/guide/slots.html).

`nice_partials` provides very similar functionality to Slotify but takes a slightly different approach/style. So if you are not convinced by Slotify then definitely [check it out](https://github.com/bullet-train-co/nice_partials)!