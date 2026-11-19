# Custom modifiers and the environment

Bundle styling into your own modifiers, erase view types, and pass values down the tree.

## Overview

### ViewModifier

A ``ViewModifier`` turns a set of modifiers and wrapping views into one reusable piece:

```swift
struct CardStyle: ViewModifier {
    var isHighlighted = false

    func body(content: Self.Content) -> some View {
        Div { content }
            .padding(14)
            .border(isHighlighted ? .orange : .gray)
            .cornerRadius(12)
            .shadow(radius: 12, y: 4)
    }
}

Paragraph("Fresh today").modifier(CardStyle(isHighlighted: true))
```

Write `Self.Content` (or ``ViewModifierContent``) in `body(content:)`, not a bare `Content`: Vapor's `Content` protocol is also in scope and Swift picks that one.

Add an extension on ``View-protocol`` to make the modifier read like a built-in one:

```swift
extension View {
    func cardStyle(highlighted: Bool = false) -> some View {
        modifier(CardStyle(isHighlighted: highlighted))
    }
}
```

### AnyView

``AnyView`` hides a view's type, so a function, array or dictionary can hold different kinds of views. Prefer `@ViewBuilder` where you can; reach for `AnyView` when you need to store views.

### The environment

The environment passes a value to every view inside a subtree without threading it through each initializer, like SwiftUI's. Declare an ``EnvironmentKey`` and a property on ``EnvironmentValues``:

```swift
struct Theme: Sendable {
    var accent: Color
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme(accent: .blue)
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
```

Set it for a subtree with ``View/environment(_:_:)``, and read it with ``ViewEnvironment`` in a view's body, or with ``EnvironmentReader`` inline:

```swift
struct AccentHeading: View {
    @ViewEnvironment(\.theme) var theme
    let text: String

    var body: some View {
        Heading(text, level: .h2).foregroundColor(theme.accent)
    }
}

ProductPage()
    .environment(\.theme, Theme(accent: .purple))
```

The property wrapper is called `ViewEnvironment` rather than `Environment` so it does not clash with Vapor's `Environment` type. Values are scoped to the render: a change applies to its subtree only and never leaks to siblings or to other requests.

### Attribute and styling modifiers

Besides the modifiers in <doc:Modifiers>, every view has ``View/border(_:width:)``, ``View/shadow(color:radius:x:y:)`` and ``View/opacity(_:)`` for styling, and ``View/title(_:)``, ``View/tabIndex(_:)``, ``View/lang(_:)``, ``View/hidden(_:)`` and ``View/disabled(_:)`` for the global HTML attributes.

## Topics

### Custom modifiers

- ``ViewModifier``
- ``ViewModifierContent``
- ``ModifiedContent``

### Type erasure

- ``AnyView``

### Environment

- ``EnvironmentKey``
- ``EnvironmentValues``
- ``ViewEnvironment``
- ``EnvironmentReader``
- ``EnvironmentModifiedView``
