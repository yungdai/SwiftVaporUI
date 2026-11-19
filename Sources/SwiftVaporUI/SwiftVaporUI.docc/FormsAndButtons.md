# Forms and buttons

Collect input with HTML forms, and handle the submission in a Vapor route.

## Overview

Forms are plain HTML forms. They work without JavaScript, and Vapor decodes the submitted fields with `req.content.decode`.

```swift
Form(action: "/plants", method: .post) {
    Label("Name", for: "name")
    TextField("e.g. Monstera", name: "name", id: "name", text: form.name)
        .required()

    Label("Light", for: "light")
    Select(name: "light") {
        Option("Low", value: "low")
        Option("Bright", value: "bright", selected: true)
    }
    .id("light")

    Button("Add plant")
}
```

### Controls

- ``TextField`` and ``SecureField`` mirror SwiftUI's names. ``SecureField`` never writes a value back into the page.
- ``TextArea`` is a multi-line field.
- ``Select`` and ``Option-struct`` make a drop-down.
- ``Input`` covers every other `type`: checkboxes, radio buttons, numbers, dates and more, through ``InputType``.
- ``Label`` captions a control. Match its `for:` to the control's `id`.
- ``Fieldset`` and ``Legend`` group related controls.

The browser validates `.required()`, `type: .email` and `.attribute("min", ...)` before submitting. Always validate on the server as well.

### Buttons

A ``Button``'s ``ButtonAction`` decides what it renders:

- `.submit`, the default, submits the enclosing form.
- `.reset` clears it.
- `.plain` does nothing by itself, for use with your own scripts.
- `.navigate(to:)` renders a link, so it works without JavaScript. Style it like a button with a class.
- `.script(_:)` runs inline JavaScript from `onclick`. Never build that code from user input.

### Handling the submission

Decode the fields into a `Content` type, validate them, and render a view. To show the form again with errors, return it with a `422` status and the submitted values:

```swift
app.post("plants") { req in
    let form = try req.content.decode(PlantForm.self)
    let errors = form.validate()
    guard errors.isEmpty else {
        return HTMLResponse(status: .unprocessableEntity) {
            AnyView(NewPlantPage(form: form, errors: errors))
        }
    }
    let plant = try await save(form)
    return HTMLResponse(status: .created) { AnyView(PlantPage(plant: plant)) }
}
```

``AnyView`` lets two branches that return different view types share one return type.

## Topics

- ``Form``
- ``FormMethod``
- ``Button``
- ``ButtonAction``
- ``Label``
- ``TextField``
- ``SecureField``
- ``TextArea``
- ``Input``
- ``InputType``
- ``Select``
- ``Option-struct``
- ``Fieldset``
- ``Legend``
