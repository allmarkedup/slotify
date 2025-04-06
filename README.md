<img src=".github/assets/slotify_wordmark.svg" width="200">



<br>

## Superpowered slots for ActionView partials

Slotify adds an unobtrusive (but powerful!) **content slot API** to ActionView partials. 

Slots are a convenient way to pass blocks of content in to a partial without having to resort to ugly `<% capture do ... end %>` workarounds or unscoped (global) `<% content_for :foo %>` declarations.

Slotified partials are a great way to build components in a Rails app without the additional overhead and learning curve of libraries like [ViewComponent](https://viewcomponent.org/) or [Phlex](https://www.phlex.fun/).

> [!CAUTION]
> Slotify is still in a very early stage of development.
The documentation is still quite sparse and the API could change at any point prior to a `v1.0` release.

### 

## Slotify basics

Slotify slots are defined using a **[strict locals](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)-style magic comment** at the top of **partial templates** ([more details here](#defining-slots)).

```erb
<%# slots: (slot_name: "default value", optional_slot_name: nil, required_slot_name:) -%>
```

Slot content is accessed via **standard local variables** within the partial. So a simple, slot-enabled `article` partial template might look something like this:

```erb
<!-- _article.html.erb -->

<%# slots: (heading: "Default title", body: nil) -%>

<article>
  <h1><%= heading %></h1>
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

For example, here our `article` partial is being rendered with content for the `heading` and `body` slots that were defined above:

```erb
<%= render "article" do |partial| %>
  <% partial.with_heading "This is a title" %>
  <% partial.with_body do %>
    <p>You can use <%= tag.strong "markup" %> within slot content blocks without
      having to worry about marking the output as <code>html_safe</code> later.</p>
  <% end %>
<% end %>
```

> [!NOTE]
> _If you've ever used [ViewComponent](https://viewcomponent.org) then the above code should also feel quite familiar to you - it's pretty much the same syntax used to provide content to [component slots](https://viewcomponent.org/guide/slots.html)._

But this example just scratches the surface of what Slotify slots can do! Read on to learn more (or [jump to a more full-featured example here](#full-example)).

## Usage

<a name="defining-slots" id="defining-slots"></a>
### Defining slots

Slots are defined using a [strict locals](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)-style magic comment at the top of the partial template. The `slots:` signature uses the same syntax as standard Ruby method signatures:

```erb
<%# slots: (title:, summary: "No summary available", author: nil) -%>
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
<%# slots: (summary: "No summary available") -%>

<article>
  <h1><%= title %></h1>
  <div><%= summary %></div>
</article>
```

Locals are provided when rendering the partial in the usual way.

```erb
<%= render "article", title: "Article title here" do |partial| %>
  <% partial.with_summary do %>
    <p>Summary content here...</p>
  <% end %>
<% end %>
```

### Slot content and options

Content is passed into slots using dynamically generated `partial#with_<slot_name>` methods.

Content can be provided as either the **first argument** or **as a block** when calling these methods at render time.
The following `#with_title` calls are both equivalent:

```erb
<%= render "example" do |partial| %>
  <% partial.with_title "Title passed as argument" %>
  <% partial.with_title do %>
    Title passed as block content
  <% end %>
<% end %>
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
and their corresponding template variable represents an array of values:

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

### Passing slot content to helpers

> _Docs coming soon..._ 

### Rendering slots

> _Docs coming soon..._ 

### Slot value objects

> _Docs coming soon..._ 

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

--- 

<a name="full-example" id="full-example"></a>

## A more full-featured example

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


