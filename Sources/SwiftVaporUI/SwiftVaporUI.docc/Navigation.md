# Navigation

Link pages together and serve each one from a route.

## Overview

On the web, navigation is links and routes. ``Link`` renders an `<a>`. Give it a title, or a label builder for richer content:

```swift
Link("All plants", destination: "/plants")

Link(destination: "/") {
    Image(src: "/logo.svg", alt: "Home")
}
```

Pass `target: .blank` to open a new tab; ``Link`` adds `rel="noopener"` for you unless you pass your own `relationship`, such as `"nofollow"`. ``NavigationLink`` marks the link to the current page with `aria-current="page"` when `isActive` is true:

```swift
NavigationBar {
    NavigationLink("Stalls", destination: "/stalls", isActive: path == "/stalls")
    NavigationLink("Map", destination: "/map", isActive: path == "/map")
}
```

### Navigation bars

``NavigationBar`` lays links out in a row inside a `<nav>`. Mark the current page with `.class(_:when:)` and `aria-current`:

```swift
NavigationBar {
    ForEach(sections) { section in
        Link(section.title, destination: section.path)
            .class("active", when: section.path == currentPath)
    }
}
.aria("label", "Main")
```

A shared layout view usually takes the current path as a property, so every page highlights its own link.

### Routes

Each Vapor route returns the view for its page, and can read path parameters and query strings to decide what to show:

```swift
app.get("plants", ":slug") { req in
    guard let plant = shelf.plant(slug: req.parameters.get("slug") ?? "") else {
        return HTMLResponse(status: .notFound) { AnyView(NotFoundPage()) }
    }
    return HTMLResponse { AnyView(PlantPage(plant: plant)) }
}
```

`Button(_:action:)` with `.navigate(to:)` renders a link too, for calls to action that should look like buttons.

## Topics

- ``Link``
- ``NavigationBar``
- ``Nav``
