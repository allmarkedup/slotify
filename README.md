<img src=".github/assets/slotify_wordmark.svg" width="140">
  


#### _A superpowered slot system for Rails partials._

----------

## Overview

Slotify adds a lightweight (but powerful!) slot system for providing content to partials when rendering them.

Slots are defined using a `strict locals`-style magic comment at the top of the partial.
Slot content is accessed via 'regular' local variables within the template.

```erb
<!-- views/_my_partial_.html.erb -->

<%# slots: (title: "Example title", items: nil, link:) -%>

<div>
  <h1><%= title %></h1>

  <% if items.any? %>
    <ul>
      <%= items.each do |item| %>
        <li <%= item.options %>>
          <%= item %>
        </li>
      <% end%>
    </ul>
  <% end %>

  <p>
    Example link: <%= partial.link_to link, class: "example-link" %>
  </p>
</div>
```

Content can then be provided to slots when rendering the partial:

```erb
<%= render "my_partial", do |partial| %>
  <%= partial.with_title do %>
    This is a title
  <% end %>

  <%= partial.with_item "Item 1" %>
  <%= partial.with_item "Item 2", class: "text-green-700" %>

  <% partial.with_link "example.com", "https://example.com", target: "_blank" %>
<% end %>
```

Slots defined with singular names can only be called with content once whereas slots defined with plural names can be called multiple times.

### Requirements

* `Rails 8.0+`
* `Ruby 3.1+`

## Usage

 🚧 Work in progress! 🚧

### Defining slots

Slots are defined using a `strict locals`-style magic comment at the top of the partial template.

```erb
<%# slots: (title: "Example title", lists: nil, quotes: nil, website_link:) -%>
```

* Singular slots can only accept one entry, plural slots can accept many.
* Slots can be required (no default value) or optional.
* Optional slots can additionaly specify default content as needed.

### A more complete example

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

## Credits

Slotify was heavily influenced by (and borrows some code from) the excellent [nice_partials gem](https://github.com/bullet-train-co/nice_partials). It provides similar functionality to Slotify so if you are not convinced by what you see here then go check it out!