<img src=".github/assets/slotify_wordmark.svg" width="200">

<p><a href="https://rubygems.org/gems/slotify"><img src="https://img.shields.io/gem/v/slotify" alt="Gem version"></a>
<a href="https://github.com/allmarkedup/slotify/actions/workflows/ci.yml"><img src="https://github.com/allmarkedup/slotify/actions/workflows/ci.yml/badge.svg" alt="CI status"></a></p>

## Superpowered slots for ActionView partials

Slotify adds an unobtrusive (but powerful!) **content slot API** to ActionView partials. 

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

Slot content is accessed via **standard local variables** within the partial. So a simple, slot-enabled `article` partial template might look something like this:

```erb
<!-- _article.html.erb -->

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
<%= render "article" do |partial| %>
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
<!-- views/_example.html.erb -->

<%# locals: (id:) -%>
<%# slots: (title: "Example title", lists: nil, quotes: nil, website_link:) -%>

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
<!-- views/_list.html.erb -->

<%# locals: (title:) -%>
<%# slots: (items: nil) -%>
 
<h3><%= title %></h3>

<% if items.any? %>
  <%= tag.ul class: "list" do %>
    <%= content_tag :li, items, class: "list-item" %>
  <% end %>
<% end %>
```

```erb
<!-- views/slotify.html.erb -->

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
<!-- _required.html.erb -->

<%# slots: (title:) -%>
<h1><%= title %></h1>
```

```erb
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

### Using alongside strict locals

Strict locals can be defined in 'slotified' partial templates in the same way as usual,
either above or below the `slots` definition.

```erb
<!-- _article.html.erb -->

<%# locals: (title:) -%>
<%# slots: (body: "No content available") -%>

<article>
  <h1><%= title %></h1>
  <div><%= body %></div>
</article>
```

Locals are provided when rendering the partial in the usual way.

```erb
<%= render "article", title: "Article title here" do |partial| %>
  <% partial.with_body do %>
    <p>Body content here...</p>
  <% end %>
<% end %>
```

### Setting slot values

Content is passed into slots using dynamically generated `partial#with_<slot_name>` writer methods.

Content can be provided as either the **first argument** or **as a block** when calling these methods at render time.
The following two examples are equivalent:

```erb
<%= render "example" do |partial| %>
  <% partial.with_title "Title passed as argument" %>
<% end %>
```

```erb
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
<%= render "example" do |partial| %>
  <% partial.with_title "The title", class: "color-hotpink", data: {controller: "fancy-title"} %>
<% end %>
```

```erb
<%# slots: (title:) -%>

<%= title.options.keys %> <!-- [:class, :data] -->
<%= title %> <!-- The title -->
```

Slot options can be useful for providing tag attributes when rendering slot content or rendering variants
of a slot based on an option value.

When rendered as a string the options are passed through the Rails `tag.attributes` helper to generate an HTML tag attributes string:

```erb
<h1 <%= title.options %>><%= title %></h1> 
<!-- <h1 class="color-hotpink" data-controller="fancy-title">The title</h1> -->
```

### Slot types

There are two types of slots.

* **Single-value** slots can only be called **once** and return **a single value**.
* **Multiple-value** slots can be called **many times** and return **an array of values**.

#### Single-value slots

Single-value slots are defined using a **singlular** slot name:

```erb
<%# slots: (item: nil) -%>
```

Single-value slots can be called once (at most)
and their corresponding template variable represents a single value:

```erb
<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
<% end %>
```

```erb
<%# slots: (item: nil) -%>
<div>
  <%= item %> <!-- "Item one" -->
</div>
```

> [!WARNING]
> Calling a single-value slot more than once when rendering a partial will raise an error:
> 
> ```erb
> <%= render "example" do |partial| %>
>   <% partial.with_item "Item one" %>
>   <% partial.with_item "Item two" %> # ❌ raises an error!
> <% end %>
> ```

#### Multiple-value slots

Multiple-value slots are defined using a **plural** slot name:

```erb
<%# slots: (items: nil) -%>
```

Multiple-value slots can be called as many times as needed
and their corresponding template variable represents an array of values.

The slot writer methods for multiple-value slots use the **singluar form** of the slot name (e.g. `#with_item` for the `items` slot).

```erb
<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
  <% partial.with_item "Item two" %>
  <% partial.with_item "Item three" %>
<% end %>
```

```erb
<%# slots: (items: nil) -%>

<%= items %> <!-- ["Item one", "Item two", "Item three"] -->

<ul>
  <% items.each do |item| %>
    <li>
      <% item %>
    </li>
  <% end %>
</ul>
```

### Using slots with helpers

> _Docs coming soon..._ 

```erb
<% partial.with_title "The title", class: "color-hotpink" %>
<% partial.with_website_link "Example website", "https://example.com", data: {controller: "external-link"} %>

<% partial.with_item "Item one" %>
<% partial.with_item "Item two", class: "highlight" %>
```

```erb
<%= content_tag :h1, title %> <!-- <h1 class="color-hotpink">The title</h1> -->
<%= content_tag :h1, title, class: "example-title" %> <!-- <h1 class="example-title color-hotpink">The title</h1> -->

<%= link_to website_link %> <!-- <a href="https://example.com" data-controller="external-link">Example website</a> -->

<%= content_tag :li, items %> <!-- <li>Item one</li><li class="highlight">Item two</li> -->
<%= content_tag :li, items, class: "item" %> <!-- <li class="item">Item one</li><li class="item highlight">Item two</li> -->
```

### Rendering slots

> _Docs coming soon..._ 

### Slot values API

**Singlular slot value variables** in partial templates are actually instances of `Slotity::Value`.
These value objects are automatically stringified so in most cases you will not even be aware of this and they can just be treated as regular string variables.



```erb
<%= render "example" do |partial| %>
  <% partial.with_title class: "color-hotpink" do %>
    The title
  <% end %>
<% end %>
```

```erb
<% title.is_a?(Slotify::Value) %> <!-- true -->
<% items.is_a?(Slotify::ValueCollection) %> <!-- true -->

<%= title %> <!-- "The title" -->
<% title.content %> <!-- "The title" -->

<% title.options %> <!-- { class: "color-hotpink" } (hash of any options provided when calling the `.with_title` slot value writer method) -->
<%= title.options %> <!-- "class='color-hotpink'" (string generated by passing the options hash through the Rails `tag.attributes` helper) -->
```

**Plural slot value variables** in partial templates are instances of the enumerable `Slotify::ValueCollection` class, with all items instances of `Slotity::Value`.

```erb
<%= render "example" do |partial| %>
  <% partial.with_item "Item one" %>
  <% partial.with_item "Item two", class: "current" %>
<% end %>
```

```erb
<% items.is_a?(Slotify::ValueCollection) %> <!-- true -->

<% items.each do |item| %>
  <li <%= item.options %>><%= item %></li>
<% end %>
<!-- <li>Item one</li> <li class="current">Item two</li> -->

<%= items %> <!-- "Item one Item two" -->
```

#### `Slotity::Value`

The following methods are available on `Slotity::Value` instances:

**`.content`**

Returns the slot content string that was provided as the first argument or as the block when calling the slot writer method.

**`.options`**

Returns a `Slotify::ValueOptions` instance that can be treated like a `Hash`. Calling `.slice` or `.except` on this will return another `Slotify::ValueOptions` instance.

When converted to a string either explicitly (via `.to_s`) or implicitly (by outputting the value template using ERB `<%= %>` expression tags) the stringified value is generated by passing the options hash through the Rails `tag.attributes` helper.

**`.with_default_options(default_options)`**

Merges the options set when calling the slot value writer method with the `default_options` hash provided and returns a new `Slotity::Value` instance with the merged options set.

```erb
<% title_with_default_opts = title.with_default_options(class: "size-lg", aria: {level: 1}) %> <!-- apply default options -->

<% title_with_default_opts.options %> <!-- { class: "size-lg color-hotpink", aria: {level: 1} } -->
<%= title_with_default_opts.options %> <!-- "class='size-lg color-hotpink' aria-level='1'" -->
```

## Slotify vs alternatives

#### `nice_partials`

Slotify was very much inspired by the [Nice Partials gem](https://github.com/bullet-train-co/nice_partials) and both provide similar functionality.
However there are a number of key differences:

* Slotify requires the explicit definition of slots using 'strict locals'-style comments;
Nice partials slots are implicitly defined when rendering the partial.
* Slotify slot values are available as local variables;
with Nice partials slot values are accessed via methods on the `partial` variable.
* Slotify has the concept (and enforces the use) of single-value vs. multiple-value slots.
* Slotify slot content and options are transparently expanded and merged into defaults when using with helpers like `content_tag` and `link_to`.
* Slotify slot values are `renderable` objects

You might choose slotify if you prefer a stricter, 'Rails-native'-feeling slots implementation, and Nice Partials if you want more render-time flexibility and a clearer
separation of 'nice partial' functionality from ActionView-provided locals etc.

#### `view_component`

Both [ViewComponent](https://viewcomponent.org/) and Slotify provide a 'slots' API for content blocks.
Slotify's slot writer syntax (i.e. `.with_<slot_name>` methods) and the concept of single-value (`renders_one`) vs multiple-value (`renders_many`) slots
are both modelled on ViewComponent's slots implementation.

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

## Credits

Slotify was inspired by the excellent [nice_partials gem](https://github.com/bullet-train-co/nice_partials) as well as ViewComponent's [slots implementation](https://viewcomponent.org/guide/slots.html).

`nice_partials` provides very similar functionality to Slotify but takes a slightly different approach/style. So if you are not convinced by Slotify then definitely [check it out](https://github.com/bullet-train-co/nice_partials)!

## Benchmarks

Slotify is still in the early stages of development and no attempt has yet been made to optimise rendering performance.

Below are some initial (crude) benchmarking comparisons with other similar gems.

> [!TIP]
> Benchmarks can be run using the `bin/benchmarks` command from the repository root.

```
✨🦄 ACTION_VIEW 🦄✨

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots    11.774k i/100ms
               slots    10.153k i/100ms
Calculating -------------------------------------
            no slots    125.557k (± 2.5%) i/s    (7.96 μs/i) -      1.260M in  10.040938s
               slots    106.413k (± 3.8%) i/s    (9.40 μs/i) -      1.066M in  10.034026s

Comparison:
            no slots:   125556.9 i/s
               slots:   106413.2 i/s - 1.18x  slower


✨🦄 NICE_PARTIALS 🦄✨

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots    11.581k i/100ms
               slots     4.070k i/100ms
Calculating -------------------------------------
            no slots    118.314k (± 2.3%) i/s    (8.45 μs/i) -      1.193M in  10.087734s
               slots     42.704k (± 2.4%) i/s   (23.42 μs/i) -    427.350k in  10.013680s

Comparison:
            no slots:   118314.5 i/s
               slots:    42704.4 i/s - 2.77x  slower


✨🦄 VIEW_COMPONENT 🦄✨

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots    20.272k i/100ms
               slots     7.259k i/100ms
Calculating -------------------------------------
            no slots    201.976k (± 2.3%) i/s    (4.95 μs/i) -      2.027M in  10.042483s
               slots     72.336k (± 4.2%) i/s   (13.82 μs/i) -    725.900k in  10.057500s

Comparison:
            no slots:   201975.5 i/s
               slots:    72336.1 i/s - 2.79x  slower


✨🦄 SLOTIFY 🦄✨

ruby 3.3.1 (2024-04-23 revision c56cd86388) [arm64-darwin23]
Warming up --------------------------------------
            no slots     9.610k i/100ms
               slots     2.511k i/100ms
Calculating -------------------------------------
            no slots     93.193k (± 6.2%) i/s   (10.73 μs/i) -    932.170k in  10.055697s
               slots     24.921k (± 4.3%) i/s   (40.13 μs/i) -    251.100k in  10.097174s

Comparison:
            no slots:    93193.0 i/s
               slots:    24921.2 i/s - 3.74x  slower
```
