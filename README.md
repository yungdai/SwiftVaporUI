# SwiftVaporUI

A SwiftUI-like DSL for building HTML views in [Vapor](https://vapor.codes).

SwiftVaporUI lets you describe web pages with the declarative, composable syntax Swift developers already know from SwiftUI, and return them straight from Vapor routes. No template files, full type checking, and reusable components written in plain Swift.

## Quick look

```swift
import SwiftVaporUI   // re-exports Vapor

struct Greeting: View {
    let name: String
    let unread: Int

    var body: some View {
        Section {
            Heading("Hello, \(name)")
            if unread > 0 {
                Paragraph("You have \(unread) new messages").class("notice")
            }
            UnorderedList {
                for item in ["Inbox", "Archive"] {
                    ListItem(item)
                }
            }
        }
        .id("greeting")
        .role("region")
    }
}

app.get("hello") { _ in
    HTMLDocument(title: "Hello") {
        Greeting(name: "Ada", unread: 3)
    }
}
```

Any `View` can be returned from a route. It is sent as `text/html; charset=utf-8`. Use `HTMLResponse(status:headers:)` to pick another status, for example `HTMLResponse(status: .notFound) { NotFoundPage() }`.

## The DSL

- **Views.** Conform to `View` and implement `var body: some View`. Views compose like SwiftUI views and can take `@ViewBuilder` content.
- **Result builder.** `@ViewBuilder` blocks support `if`/`else`, `if let`, `switch`, `for` loops, and bare string literals, which render as escaped `Text`. `ForEach(collection) { ... }` and `Group { ... }` are available too.
- **Elements.** `Div`, `Span`, `Section`, `Header`, `Footer`, `Nav`, `Main`, `Article`, `Aside`, `Heading`, `Paragraph`, `Strong`, `Emphasis`, `Small`, `Code`, `Preformatted`, `Blockquote`, `Link`, `Image`, `LineBreak`, `Divider`, `UnorderedList`/`OrderedList`/`ListItem`, `List(data) { row }`, `DescriptionList`/`DescriptionTerm`/`DescriptionDetail`, tables, `Figure`, `Details`/`Summary`, `Template`, and form controls (`Form`, `Label`, `Input`, `TextField`, `SecureField`, `TextArea`, `Select`/`Option`, `Button`, `Fieldset`/`Legend`). Use `Element("tag") { ... }` or `VoidElement("tag")` for anything else.
- **Buttons.** `Button("Save")` submits its form, as in HTML. Other actions: `.reset`, `.plain`, `.navigate(to:)` (renders a link, so it works without JavaScript) and `.script(_:)` (an `onclick` handler).
- **Layout.** `HStack` (flex row, 8px gap by default), `VStack` (a plain `div` unless you pass `alignment` or `spacing`, so CSS can own the layout), `Spacer`, and `NavigationBar` (a `<nav>` laid out as a row).
- **Documents.** `HTMLDocument(title:head:body:)` writes the doctype, `<head>` (charset, viewport, title) and `<body>`. `Page(title:) { ... }` is the same with an empty head. For full control, compose `Document`, `HTMLRoot`, `Head`, `Title`, `Meta`, `ResourceLink`, `Stylesheet`, `Style`, `Script` and `DocumentBody` yourself.
- **Attribute modifiers.** `.class(_:)`, `.class(_:when:)`, `.id(_:)`, `.role(_:)`, `.attribute(_:_:)`, `.flag(_:if:)` for boolean attributes, `.data(_:_:)`, `.aria(_:_:)`, `.tooltip(_:)`, `.hidden()`, `.disabled()`, `.required()`, `.autofocus()`.
- **Styling modifiers.** `.style(_:)`, `.style(_:_:)`, `.padding()`, `.padding(_:_:)` with `Edge`s, `.font(_:)` (`.largeTitle`, `.title`, `.headline`, `.body`, `.caption`, `.system(size:weight:)`, ...), `.fontWeight(_:)`, `.bold()`, `.italic()`, `.foregroundColor(_:)`, `.background(_:)`, `.cornerRadius(_:)`, `.opacity(_:)`, `.frame(width:height:)`, `.frame(maxWidth:maxHeight:)`. `Color` has named colors plus `.hex(_:)` and `.rgb(_:_:_:opacity:)`.

Modifiers apply to the first HTML element their view renders, so modifiers on your own views reach the element inside them, and styling modifiers add to that element's `style` rather than wrapping it in another `div`. If the same attribute is set twice, the last modifier in the chain wins; classes and styles accumulate. A modifier on bare `Text` wraps it in a `<span>`.

## Safety

- Text and attribute values are always HTML-escaped.
- Attribute names and tag names are validated; unsafe ones are dropped instead of written.
- Inline `Script` and `Style` content cannot close its own tag early.
- `RawHTML("...")` is the only way to write unescaped markup. Only use it with HTML you trust.
- Escaping does not validate URLs. Do not put untrusted input into `href` or `src` without checking the scheme.

## `View` and `Vapor.View`

Vapor also has a type called `View` (used by its template renderers). `import SwiftVaporUI` re-exports Vapor and its `View` takes precedence, so files that import only SwiftVaporUI just work. If a file also imports `Vapor` or `XCTVapor` directly, add this line once anywhere in that module:

```swift
typealias View = SwiftVaporUI.View
```

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/yungdai/SwiftVaporUI.git", branch: "main"),
```

and add `"SwiftVaporUI"` to your target's dependencies.

## Repository layout

- `Sources/SwiftVaporUI`: the library.
- `Tests/SwiftVaporUITests`: unit tests.
- `Examples/DemoServer`: "Plant Shelf", a small Vapor app with a shared layout, list and detail pages, a validated form, a 404 page and an HTML fragment route.

## Running the demo server

```bash
cd Examples/DemoServer
swift run DemoServer
```

Then open http://localhost:8080.

## Requirements

- Swift 6.0+
- macOS 13+ or Linux
