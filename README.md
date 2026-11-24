# SwiftVaporUI

A SwiftUI-like DSL for building HTML views in [Vapor](https://vapor.codes).

SwiftVaporUI lets you describe web pages with the declarative, composable syntax Swift developers already know from SwiftUI, and return them straight from Vapor routes. No template files, full type checking, and reusable components written in plain Swift.

Want to see it first? Clone the repo and [run the showcase site](#try-the-showcase-site): every feature with its source code next to the live result, plus a complete example website.

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
.package(url: "https://github.com/yungdai/SwiftVaporUI.git", from: "0.1.0-beta.1"),
```

and add `"SwiftVaporUI"` to your target's dependencies.

## Try the showcase site

The repository includes a showcase website built entirely with SwiftVaporUI. It has a page for each feature area, and every example shows the Swift source next to the live result it renders. The source on the page is read from the server's own Swift files, so it always matches what you see, and you can change a file, run again and watch the result change.

It also has:

- a **capstone page**: a complete "night market" event website that uses most of the DSL, shown live and then taken apart step by step, from the data model to the routes that serve it;
- a **playground** page backed by `Playground.swift`, for your own experiments;
- **Plant Shelf**, a small app with a shared layout, list and detail pages and a validated form.

### Clone

```bash
git clone https://github.com/yungdai/SwiftVaporUI.git
cd SwiftVaporUI
```

### Run in Xcode

1. Open the repository's `Package.swift` in Xcode (`open Package.swift`).
2. Wait for the Swift packages to resolve.
3. Choose the **DemoServer** scheme and **My Mac** as the destination.
4. Press **⌘R**.
5. Open http://127.0.0.1:8080 in your browser.

The server logs the address in Xcode's console when it starts. Press **⌘.** to stop it.

### Run from a terminal

```bash
swift run DemoServer
```

Run it from the repository folder. `swift test` there runs the library's tests and the showcase's tests.

Then open http://127.0.0.1:8080. To use another port, run `PORT=9000 swift run DemoServer` or `swift run DemoServer serve --port 9000`.

### What's on the site

| Page | Path |
| --- | --- |
| Home and a first view | `/` |
| Text and headings | `/text` |
| Layout stacks | `/layout` |
| Styling modifiers | `/styling` |
| Lists and ForEach | `/lists` |
| Conditionals | `/conditionals` |
| Tables | `/tables` |
| Forms, inputs and buttons | `/forms` |
| Navigation and links | `/navigation` |
| Custom views | `/components` |
| More elements | `/elements` |
| Full documents | `/documents` |
| Capstone: how the night market page is built | `/capstone` |
| The night market page on its own | `/market` |
| Playground | `/playground` |
| Plant Shelf sample app | `/plants` |

## Documentation

The library has DocC documentation: a getting-started guide, an article per feature area and reference docs for every public type. In Xcode, open the root `Package.swift` and choose **Product › Build Documentation** (⌃⇧⌘D). The sources are in `Sources/SwiftVaporUI/SwiftVaporUI.docc`.

## Repository layout

- `Sources/SwiftVaporUI`: the library.
- `Sources/SwiftVaporUI/SwiftVaporUI.docc`: the DocC catalog.
- `Tests/SwiftVaporUITests`: unit tests.
- `Examples/DemoServer`: the showcase server. It is the `DemoServer` executable target of the same package, so one `Package.swift` releases the library and runs the website. It is not a product, so apps that depend on SwiftVaporUI never build it.
  - `Public`: CSS and JavaScript served by `FileMiddleware`.
  - `Tests/DemoServerTests`: the showcase's tests.
  - `Sources/DemoServer/Showcase/Topics`: one file per feature page.
  - `Sources/DemoServer/Showcase/Capstone`: the night market page and the page that explains it.
  - `Sources/DemoServer/Showcase/Playground.swift`: the playground.
  - `Sources/DemoServer/PlantShelf`: the Plant Shelf sample app.

### Adding an example

Each example on a feature page is an `Example` whose preview is wrapped in marker comments:

```swift
Example("greeting", title: "A greeting") {
    // snippet: greeting
    Paragraph("Hello!")
    // end-snippet
}
```

The page shows the code between the markers next to the rendered result and the HTML it produced. A snippet id can appear more than once in a file, for example around a helper view defined further down, and the regions are shown together.

## Linting

[SwiftLint](https://github.com/realm/SwiftLint) runs on every build of the library, its tests and the showcase server, through the [SwiftLintPlugins](https://github.com/SimplyDanny/SwiftLintPlugins) build tool plugin. Violations show up in Xcode's issue navigator and in `swift build` output. The rules live in [`.swiftlint.yml`](.swiftlint.yml); the showcase folder adds a nested [`Examples/DemoServer/.swiftlint.yml`](Examples/DemoServer/.swiftlint.yml) on top of them. House style: every type, property and function, at any access level, has a `///` doc comment, and `missing_docs` warns when one is missing.

- **Turn it on (once per clone):** run `touch .enable-swiftlint` in the repository root. The file is git-ignored. Without it the library, its tests and the showcase build without SwiftLint, which is also how apps that depend on SwiftVaporUI see it.
- **Xcode:** the first time you build with linting on, Xcode asks you to trust `SwiftLintBuildToolPlugin`. Choose **Trust & Enable All**. SwiftPM and Xcode cache the evaluated manifest, so after creating or deleting the file run `swift package reset` in a terminal, or use **File › Packages › Reset Package Caches** in Xcode.
- **Terminal:** `swift build` lints as it builds. To lint without compiling (needs the opt-in file), run `swift package plugin --allow-writing-to-package-directory swiftlint`.

Projects that depend on SwiftVaporUI by URL never fetch or run SwiftLint, because the opt-in file only exists in your own clone. A project that depends on a local clone with `.package(path:)` does pick it up while that clone has the file.

## Requirements

- Swift 6.0+
- macOS 13+ or Linux

## License

SwiftVaporUI is available under the MIT license. See [LICENSE](LICENSE) for details.
