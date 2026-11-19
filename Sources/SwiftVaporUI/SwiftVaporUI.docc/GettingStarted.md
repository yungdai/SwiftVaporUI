# Getting started

Add SwiftVaporUI to a Vapor app, write a first view and return it from a route.

## Overview

SwiftVaporUI is a Swift package that depends on Vapor 4. It needs Swift 6.0 or later and runs on macOS 13 or later and on Linux.

### Add the package

In your app's `Package.swift`, add the package and the product:

```swift
dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
    .package(url: "https://github.com/yungdai/SwiftVaporUI.git", branch: "main"),
],
targets: [
    .executableTarget(
        name: "App",
        dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "SwiftVaporUI", package: "SwiftVaporUI"),
        ]
    ),
]
```

### Write a view

A view is a type that conforms to ``View-protocol`` and describes its content in `body`. Inside `body` you list child views, one per line, just like SwiftUI. Bare strings become escaped ``Text``.

```swift
import SwiftVaporUI

struct WelcomePage: View {
    let name: String

    var body: some View {
        Page(title: "Welcome") {
            Heading("Welcome, \(name)")
            Paragraph {
                "Read the "
                Link("guide", destination: "/guide")
                " to get started."
            }
        }
    }
}
```

``Page`` writes a complete HTML document: the doctype, a head with the charset, viewport and title, and a body.

### Return it from a route

Every view conforms to Vapor's `AsyncResponseEncodable`, so a route can return it directly. It is sent with status `200 OK` and `Content-Type: text/html; charset=utf-8`.

```swift
app.get("welcome", ":name") { req in
    WelcomePage(name: req.parameters.get("name") ?? "friend")
}
```

To choose another status or add headers, wrap the view in ``HTMLResponse``:

```swift
HTMLResponse(status: .notFound) { NotFoundPage() }
```

> Note: `import SwiftVaporUI` also imports Vapor, and its ``View-protocol`` takes precedence over Vapor's own `View` type. If a file imports `Vapor` or `XCTVapor` directly as well, add `typealias View = SwiftVaporUI.View` once in that module.

### Run the showcase server

The repository contains a showcase site in `Examples/DemoServer`, with a page for each feature area, a capstone page that puts everything together, and a playground. Every example shows the Swift source next to its live result.

To run it in Xcode, open `Examples/DemoServer/Package.swift`, choose the **DemoServer** scheme and **My Mac**, and press Command-R. To run it from a terminal:

```bash
cd Examples/DemoServer
swift run DemoServer
```

Then open <http://127.0.0.1:8080>.

### Next steps

- <doc:SettingUpAPage> shows how a web page differs from a SwiftUI screen, and how to set up the document, CSS, scripts and static files.
- <doc:BuildingViews> explains how views and the result builder work.
- <doc:Modifiers> covers classes, attributes and styling.
- <doc:ComposingViews> shows how to build your own reusable components.
