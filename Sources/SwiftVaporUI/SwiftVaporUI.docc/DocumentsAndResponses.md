# Documents and responses

Write complete HTML documents, share a layout between pages, and control the HTTP response.

## Overview

``HTMLDocument`` writes the doctype, the `<html>` element, a `<head>` with the charset, viewport and title, and a `<body>`. Use the `head` builder for stylesheets, scripts and meta tags.

```swift
HTMLDocument(title: "Seed swap") {
    Meta(name: "description", content: "Swap seeds with your neighbours")
    Stylesheet(href: "/styles.css")
    Script(src: "/app.js", defer: true)
} body: {
    Main {
        Heading("Seed swap")
    }
}
```

``Page`` is the shortcut when you only need a title and a body. For full control, compose ``Document``, ``HTMLRoot``, ``Head``, ``Title``, ``Meta``, ``ResourceLink`` and ``DocumentBody`` yourself.

``Style`` and ``Script`` write inline CSS and JavaScript. Neither escapes its content, but both neutralise a closing tag inside it so the content cannot end the element early.

### A shared layout

Wrap ``HTMLDocument`` in a view of your own so every page shares its head and chrome:

```swift
struct SiteLayout<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HTMLDocument(title: "\(title) · Greenfield") {
            Stylesheet(href: "/site.css")
        } body: {
            Header { Link("Greenfield", destination: "/") }
            Main { content }
            Footer { Small("© Greenfield") }
        }
    }
}
```

### Responses

Returning a view from a route sends `200 OK` with `Content-Type: text/html; charset=utf-8`. Wrap it in ``HTMLResponse`` to choose the status or add headers:

```swift
app.get("missing") { req in
    HTMLResponse(status: .notFound, headers: ["Cache-Control": "no-store"]) {
        NotFoundPage()
    }
}
```

When different branches of a route return different views, wrap each in ``AnyView`` so they share a type.

## Topics

- ``HTMLDocument``
- ``Page``
- ``Document``
- ``HTMLRoot``
- ``Head``
- ``Title``
- ``Meta``
- ``ResourceLink``
- ``Stylesheet``
- ``Style``
- ``Script``
- ``DocumentBody``
- ``HTMLResponse``
