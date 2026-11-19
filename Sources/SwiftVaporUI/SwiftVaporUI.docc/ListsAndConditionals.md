# Lists and conditionals

Repeat content for each element of a collection, and choose what to show with Swift's control flow.

## Overview

### Repeating content

There are three ways to repeat content:

- ``List`` builds a whole `<ul>` from a collection, wrapping each row in an `<li>`.
- ``ForEach`` renders a view per element, with no wrapper, so it works inside tables, stacks and lists.
- A `for`-`in` loop works inside any view builder, including `where` clauses and `enumerated()`.

```swift
List(plants) { plant in
    Link(plant.name, destination: "/plants/\(plant.slug)")
}

OrderedList {
    for (rank, plant) in plants.enumerated() where plant.isThirsty {
        ListItem("\(rank + 1). \(plant.name)")
    }
}
```

For key and value pairs, use ``DescriptionList`` with ``DescriptionTerm`` and ``DescriptionDetail``.

### Conditional content

View builders understand `if`, `if`/`else`, `if let` and `switch`. Only the chosen branch is rendered, so nothing hidden leaks into the page.

```swift
if let nickname = plant.nickname {
    Paragraph("Also known as \(nickname)")
}

switch plant.moisture {
case .dry: Paragraph("Water today").class("warning")
case .moist: Paragraph("All good")
case .soaked: Paragraph("Skip the next watering")
}
```

To keep an element in the page but toggle an attribute, use the Bool parameters of `.hidden(_:)`, `.disabled(_:)` and `.class(_:when:)` instead of branching.

## Topics

- ``List``
- ``ForEach``
- ``UnorderedList``
- ``OrderedList``
- ``ListItem``
- ``DescriptionList``
- ``DescriptionTerm``
- ``DescriptionDetail``
- ``OptionalView``
- ``ConditionalView``
