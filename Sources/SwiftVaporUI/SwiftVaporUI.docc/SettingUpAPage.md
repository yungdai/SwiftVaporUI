# Setting up a page

Build the document around your views: the head, CSS, scripts and static files.

## Overview

A SwiftUI screen is a tree of views and nothing else: the system already knows how to draw a `Text` or a `Button`. A web page is different. The browser receives one **document**, and before it can show your views it needs to know how to read the bytes, how wide the screen is, what the page is called, and which **stylesheets** and **scripts** go with it. That information lives in the document's `<head>`. Your views describe the `<body>`.

So when you set up a page you decide three things that SwiftUI never asks you about:

1. **The document skeleton**: doctype, `<html lang>`, `<head>` and `<body>`.
2. **Where your CSS and JavaScript come from**, and where in the document they load.
3. **How those files are served** by Vapor.

Once that is in one reusable layout view, every route only describes its own content, much like a SwiftUI screen.

### The parts of a document

``HTMLDocument`` writes the whole skeleton for you. Built by hand from its pieces it looks like this:

```swift
Document {                                    // <!DOCTYPE html>
    HTMLRoot(language: "en") {                // <html lang="en">
        Head {
            Meta(charset: "utf-8")            // how to read the bytes
            Meta(name: "viewport", content: "width=device-width, initial-scale=1")
            Title("Tonight")                  // the browser tab and bookmarks
            Stylesheet(href: "/css/site.css") // CSS before any content
            Script(src: "/js/site.js", defer: true)
        }
        DocumentBody {
            Header { Strong("Riverside Night Market") }
            Main { StallList() }
        }
    }
}
```

- **Charset**: `utf-8` must come first so the browser decodes the rest of the page correctly.
- **Viewport**: without it, phones render the page at desktop width and shrink it.
- **Language**: `lang` on `<html>` tells screen readers how to pronounce the text and helps translation tools.

`HTMLDocument(title:language:head:body:)` writes the charset, viewport and title for you; the `head` builder adds the rest. ``Page`` is the same with an empty head.

### Styles go in the head

Put stylesheets in the `<head>`. The browser waits for them before drawing, so the page never flashes unstyled.

- ``Stylesheet`` links an external `.css` file. Prefer it for site-wide styles: the browser caches it across pages.
- ``Style`` embeds CSS in the page. Use it for small, page-specific rules.
- Styling modifiers such as ``View/padding(_:_:)`` and ``View/foregroundColor(_:)`` write inline `style` attributes. They are handy for one-off tweaks; use classes and a stylesheet for anything you repeat.

``ZStack``, ``Grid``, ``TabView`` and ``Menu`` need a few CSS rules of their own. Inside an ``HTMLDocument`` they are written in the `<head>` for you, only for the views the page uses. If you build the document yourself from ``Head`` and ``DocumentBody``, put ``SupportStyles`` in the head; otherwise each view writes its rules inline in a small `<style>` element the first time it appears.

### Scripts: defer them, or put them last

A plain `<script src>` in the head stops the browser from reading the page until the script has downloaded and run, and the script cannot see any elements yet. Choose one of these instead:

| Where and how | When it runs | Use it for |
| --- | --- | --- |
| `Script(src:defer: true)` in the head | After the page is parsed, in order | Most site scripts |
| `Script(src:module: true)` in the head | Like `defer` | ES modules |
| `Script(src:async: true)` in the head | As soon as it downloads, in any order | Independent scripts such as analytics |
| `Script("...")` at the end of `DocumentBody` | Immediately, with everything above it in place | Small inline set-up code |

Inline scripts and ``ButtonAction/script(_:)`` are written without escaping, so only use code you wrote; never build them from user input.

### Serve CSS and JavaScript with FileMiddleware

Put your static files in a `Public` folder next to `Package.swift`:

```
MyApp/
├── Package.swift
├── Public/
│   ├── css/site.css      →  /css/site.css
│   └── js/site.js        →  /js/site.js
└── Sources/App/configure.swift
```

and add Vapor's `FileMiddleware` when you configure the app:

```swift
app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
```

`app.directory.publicDirectory` is relative to the **working directory**. `swift run` from the package folder finds it; in Xcode, set the scheme's working directory (Edit Scheme › Run › Options › Working Directory) to the package folder, or build the path from `#filePath` as the showcase does.

### One layout for every page

Wrap the document in your own view so every page gets the same head, header and footer, and each route only says what is different:

```swift
struct SiteLayout<Content: View>: View {

    /// The page title, shown in the browser tab.
    let title: String

    /// The page's own content.
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HTMLDocument(title: "\(title) · Night Market") {
            Stylesheet(href: "/css/site.css")
            Script(src: "/js/site.js", defer: true)
        } body: {
            SiteHeader()
            Main { content }
            SiteFooter()
        }
    }
}

app.get("stalls") { _ in
    SiteLayout(title: "Stalls") {
        StallList()
    }
}
```

The showcase's "Setting up a page" page runs these examples live, with its CSS and JavaScript served from `Examples/DemoServer/Public`.

## Topics

- ``HTMLDocument``
- ``Page``
- ``Document``
- ``HTMLRoot``
- ``Head``
- ``DocumentBody``
- ``Meta``
- ``Title``
- ``Stylesheet``
- ``Style``
- ``Script``
- ``SupportStyles``
