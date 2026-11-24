# Composing views

Build your own reusable components from smaller views.

## Overview

Any struct that conforms to ``View-protocol`` is a component. Give it properties for its inputs, and compose it from other views:

```swift
struct StatTile: View {
    let label: String
    let value: String
    var trend: String? = nil

    var body: some View {
        VStack(spacing: 2) {
            Small(label)
            Strong(value).font(.title2)
            if let trend {
                Small(trend).foregroundColor(trend.hasPrefix("-") ? .red : .green)
            }
        }
        .class("card")
    }
}
```

### Accepting content

Containers take a `@ViewBuilder` closure. Use a second builder for optional slots, and an extension that fills it with ``EmptyView`` so callers can leave it out:

```swift
struct Panel<Content: View, Footer: View>: View {
    let title: String
    let content: Content
    let footer: Footer

    init(title: String, @ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer) {
        self.title = title
        self.content = content()
        self.footer = footer()
    }

    var body: some View {
        Article {
            Heading(title, level: .h3)
            content
            footer
        }
        .class("panel")
    }
}

extension Panel where Footer == EmptyView {
    init(title: String, @ViewBuilder content: () -> Content) {
        self.init(title: title, content: content, footer: { EmptyView() })
    }
}
```

### Styling from outside

Modifiers on a component reach the first element it renders, so `Panel(...).id("featured")` sets the `id` of the panel's `<article>`.

### Shared layouts

A layout is a component that wraps ``HTMLDocument``. Give it a title and the current path, and every page gets the same head, header and footer. See <doc:DocumentsAndResponses>.

### Fragments

A component can be returned from a route on its own. It is sent as an HTML fragment, which suits libraries such as htmx that swap parts of a page. See <doc:HTMX> for the typed htmx modifiers and `req.fragmentOrPage(_:page:)`.

```swift
app.get("fragments", "stats") { _ in
    StatTile(label: "Plants", value: "24")
}
```
