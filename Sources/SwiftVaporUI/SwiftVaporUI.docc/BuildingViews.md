# Building views

Describe HTML with views, compose them with the result builder, and render them.

## Overview

Everything you put on a page is a ``View-protocol``. Library views such as ``Paragraph`` or ``HStack`` render HTML elements, and your own views are structs with a `body` made of other views.

```swift
struct PlantRow: View {
    let name: String
    let isThirsty: Bool

    var body: some View {
        HStack {
            Strong(name)
            if isThirsty {
                Span("Needs water").class("badge")
            }
        }
    }
}
```

### The result builder

`body`, and every `content:` closure in the library, is a ``ViewBuilder``. Inside it you can write:

- one view per line, which render in order;
- string literals and interpolated strings, which become escaped ``Text``;
- `if`, `if`/`else`, `if let` and `switch`, which render only the chosen branch;
- `for`-`in` loops, which render their body once per element;
- `let` declarations, for values used further down.

``ForEach`` and ``Group`` are available too, for when you want an expression rather than a statement.

### Taking content from callers

To make a container of your own, accept a `@ViewBuilder` closure, as SwiftUI views do:

```swift
struct Card<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        Article {
            Heading(title, level: .h2)
            content
        }
        .class("card")
    }
}
```

### Rendering

A route can return any view, and Vapor renders it for you. To get the HTML yourself, for example in a test or to cache it, call `render()`:

```swift
let html = PlantRow(name: "Fern", isThirsty: true).render()
```

Rendering is a single pass that writes into an ``HTMLRenderer``. Views have no state and no lifecycle: a view is a description of the HTML for one request.

### Any other tag

For a tag the library does not name, use ``Element`` or, for tags with no closing tag, ``VoidElement``:

```swift
Element("time", attributes: ["datetime": "2026-11-19"]) { "Today" }
```

## Topics

- ``View-protocol``
- ``ViewBuilder``
- ``Text``
- ``Group``
- ``ForEach``
- ``Element``
- ``VoidElement``
- ``AnyView``
