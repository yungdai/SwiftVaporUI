# SwiftVaporUI

A SwiftUI-like DSL for building HTML views in [Vapor](https://vapor.codes).

SwiftVaporUI lets you describe web pages with the declarative, composable syntax Swift developers already know from SwiftUI, and return them straight from Vapor routes. No template files, full type checking, and reusable components written in plain Swift.

## Goal

```swift
app.get { _ in
    Page(title: "Hello") {
        VStack {
            Text("Welcome to SwiftVaporUI")
                .font(.title)
            Link("Learn more", destination: "/docs")
        }
    }
}
```

The snippet above shows the direction of the API; the DSL is still being built and the current release only includes a minimal `Page` type.

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/yungdai/SwiftVaporUI.git", branch: "main"),
```

and add `"SwiftVaporUI"` to your target's dependencies.

## Repository layout

- `Sources/SwiftVaporUI`: the library.
- `Tests/SwiftVaporUITests`: unit tests.
- `Examples/DemoServer`: a Vapor app that showcases the different ways to use the DSL.

## Running the demo server

```bash
cd Examples/DemoServer
swift run DemoServer
```

Then open http://localhost:8080.

## Requirements

- Swift 6.0+
- macOS 13+ or Linux
