# Modifiers

Set attributes and style views with chained modifiers.

## Overview

Modifiers change the attributes of the first HTML element a view renders. They never add wrapper elements, with one exception: a modifier on bare ``Text`` wraps it in a `<span>`, since text has no element of its own.

```swift
Paragraph("Three plants need water.")
    .class("notice")
    .id("alert")
    .role("status")
    .padding(12)
    .foregroundColor(.hex("1f6b35"))
```

### Attribute modifiers

- `.class(_:)` adds one or more class names, and `.class(_:when:)` adds them only when a condition is true.
- `.id(_:)`, `.role(_:)` and `.tooltip(_:)` set `id`, `role` and `title`.
- `.data(_:_:)` and `.aria(_:_:)` set `data-*` and `aria-*` attributes.
- `.attribute(_:_:)` sets any attribute, or removes it when the value is `nil`.
- `.flag(_:if:)` adds a boolean attribute such as `open` or `novalidate`.
- `.hidden(_:)`, `.disabled(_:)`, `.required(_:)` and `.autofocus(_:)` toggle the common boolean attributes.

### Styling modifiers

Styling modifiers add inline CSS to the element:

- `.padding(_:)` and `.padding(_:_:)` with an ``Edge`` set.
- `.font(_:)` with a ``Font`` such as `.title` or `.system(size:weight:)`, plus `.fontWeight(_:)`, `.bold()` and `.italic()`.
- `.foregroundColor(_:)` and `.background(_:)` with a ``Color``: a named color, `.hex(_:)` or `.rgb(_:_:_:opacity:)`.
- `.cornerRadius(_:)`, `.opacity(_:)`, `.frame(width:height:)` and `.frame(maxWidth:maxHeight:)`.
- `.style(_:)` and `.style(_:_:)` for any other CSS.

### How modifiers combine

Classes and styles accumulate as you chain modifiers. For any other attribute, the last modifier in the chain wins, so a caller can override an attribute a component sets on itself.

Modifiers on your own views reach the first element inside them. That lets you style a component from outside without giving it extra parameters:

```swift
Card(title: "Featured") { ... }
    .background(.hex("fff1e8"))
```

If a modifier wraps several sibling elements, for example a ``Group``, only the first sibling receives the attributes.

## Topics

- ``ModifiedView``
- ``Color``
- ``Font``
- ``Edge``
- ``HTMLAttributes``
