# Layout stacks

Arrange views in rows and columns with HStack, VStack and Spacer.

## Overview

``HStack`` and ``VStack`` use CSS flexbox to lay out their children, with the alignment and spacing parameters you know from SwiftUI.

```swift
HStack(spacing: 12) {
    Strong("Monstera")
    Spacer()
    Button("Water", action: .plain)
}
```

- ``HStack`` is a flex row. Children are vertically centred with an 8 pixel gap by default.
- ``VStack`` is a flex column when you pass `alignment` or `spacing`. With neither, it is a plain `<div>`, because block elements already stack, which leaves the layout to your own CSS.
- ``Spacer`` fills the free space along the main axis, pushing its siblings apart.
- ``NavigationBar`` is a `<nav>` that lays its links out as a row.

Stacks nest freely, so most layouts are a few levels of rows and columns.

### Page regions

For the overall structure of a page, prefer the semantic containers: ``Header``, ``Nav``, ``Main``, ``Section``, ``Article``, ``Aside`` and ``Footer``. They render the matching HTML5 landmarks, which helps screen readers and search engines. ``Div`` and ``Span`` are there when no semantic element fits.

### Stacks and CSS

Stacks write their layout as inline styles. You can still add classes and more styles with modifiers, and they combine with the stack's own style. For responsive layouts such as grids, a class with a CSS rule is usually the better tool:

```swift
Div {
    ForEach(plants) { PlantCard(plant: $0) }
}
.class("grid")
```

## Topics

- ``HStack``
- ``VStack``
- ``Spacer``
- ``HorizontalAlignment``
- ``VerticalAlignment``
- ``NavigationBar``
- ``Div``
- ``Section``
- ``Header``
- ``Footer``
- ``Main``
- ``Article``
- ``Aside``
- ``Nav``
