<img src=".github/assets/slotify_wordmark.svg" width="200">

#### Superpowered slots for ActionView partials.

----------

## Overview 

Slotify adds an unobtrusive, ViewComponent-style **slots API** to ActionView partials.

Slots are a convenient way to pass blocks of content in to a partial without having to resort to ugly `<% capture do ... end %>` workarounds or unscoped (global) `<% content_for :foo %>` declarations.

Slotified partials are **an excellent tool for building components** in a Rails app if you want to stay close to _The Rails Way™️_ or just want to avoid the additional overhead and learning curve of libraries like [ViewComponent](https://viewcomponent.org/) or [Phlex](https://www.phlex.fun/).

### 

## Slotify basics

Slotify slots are defined using a [strict locals](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)-style magic comment at the top of partial templates ([more details here](#defining-slots)).

```erb
<%# slots: (slot_name: "default value", optional_slot_name: nil, required_slot_name:) -%>
```

Slot content is accessed via standard local variables within the partial. So a simple slot-enabled `article` partial template might look something like this:

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
> _The above code should feel familiar if you have used partials in the past. This is just regular partial syntax but with `slots` defined instead of `locals` (don't worry - you can still define locals too!)._

When the partial is rendered, a special `partial` object is yielded as an argument to the block. Slot content is set by calling the appropriate `.with_<slot_name>` methods on this partial object.

For example, here our `article` partial is being rendered with content for the `heading` and `body` slots that were defined above:

```erb
<!-- index.html.erb -->

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

The example above just scratches the surface of what Slotify slots can do. You can [jump to a more full-featured example here](#full-example) or read on to learn more...


## Single vs multiple entry slots

> _Docs coming soon..._ 

## Slot arguments and options

> _Docs coming soon..._ 

## Using helpers with slots

> _Docs coming soon..._ 

## Rendering slots

> _Docs coming soon..._ 

<a name="defining-slots" id="defining-slots"></a>
## Defining slots

Slots are defined using a [strict locals](https://guides.rubyonrails.org/action_view_overview.html#strict-locals)-style magic comment at the top of the partial template. The `slots:` signature uses the same syntax as standard Ruby method signatures.

> _Docs coming soon..._ 

### Required slots

> _Docs coming soon..._ 

### Optional slots

> _Docs coming soon..._ 

### Setting default values

> _Docs coming soon..._ 

## Slotify API

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

<br>

--- 

<br>
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
  
  <p>Example link: <%= partial.link_to website_link, data: {controller: "external-link"} %></p>

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
    <%= partial.li items, class: "list-item" %>
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


