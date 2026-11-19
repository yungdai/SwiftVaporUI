# SwiftUI containers

Layer, grid, scroll, tab and disclose content the way you would in SwiftUI.

## Overview

These containers keep their SwiftUI names and parameters and turn into plain HTML and CSS. None of them needs JavaScript.

### ZStack

``ZStack`` layers its children in one grid cell, later children on top, placed by an ``Alignment``:

```swift
ZStack(alignment: .bottomLeading) {
    Image(src: "/img/stall.jpg", alt: "")
    Span("Open late").class("badge")
}
```

### Grid and LazyVGrid

``Grid`` takes ``GridRow``s; each child of a row is a cell, and columns line up and size to their widest cell, as in SwiftUI.

```swift
Grid(horizontalSpacing: 24) {
    GridRow { Strong("Stall"); Strong("Opens") }
    GridRow { "Dumpling House"; "18:00" }
}
```

``LazyVGrid`` flows children into columns described by ``GridItem``s: `.fixed`, `.flexible` or `.adaptive`. An adaptive column fits as many cells as the width allows, which makes a responsive card grid in one line:

```swift
LazyVGrid(columns: [GridItem(.adaptive(minimum: 220))], spacing: 16) {
    ForEach(stalls) { StallCard(stall: $0) }
}
```

### ScrollView

``ScrollView`` scrolls on the ``Axis/Set`` you give it. Limit its size with ``View/frame(maxWidth:maxHeight:)``. It is focusable, so keyboard users can scroll it.

### TabView

``TabView`` holds ``Tab``s. Each tab becomes a visually hidden radio button, a label styled as a tab, and a panel that CSS shows when its radio button is checked. Arrow keys move between tabs.

```swift
TabView(id: "stall-info") {
    Tab("Menu") { MenuList() }
    Tab("Hours") { HoursTable() }
}
```

The `id` names the radio group, so it must be unique in the page.

### DisclosureGroup and Menu

``DisclosureGroup`` renders `<details>` and `<summary>`; `isExpanded` starts it open. ``Menu`` is a `<details>` too, with its items dropped down under the button. Fill it with ``Link``s or ``Button``s.

### NavigationLink and Divider

``NavigationLink`` is a link that can mark itself as the current page with `aria-current="page"`. ``Divider`` is a thematic break, `<hr>`.

### The CSS these views need

``ZStack``, ``Grid``, ``TabView`` and ``Menu`` each write a few CSS rules in a `<style>` element the first time they appear in a page. Put ``SupportStyles`` in your head to write them all there instead. See <doc:SettingUpAPage>.

## Topics

### Containers

- ``ZStack``
- ``Alignment``
- ``Grid``
- ``GridRow``
- ``LazyVGrid``
- ``GridItem``
- ``ScrollView``
- ``Axis``
- ``TabView``
- ``Tab``
- ``DisclosureGroup``
- ``Menu``
- ``NavigationLink``
- ``SupportStyles``
