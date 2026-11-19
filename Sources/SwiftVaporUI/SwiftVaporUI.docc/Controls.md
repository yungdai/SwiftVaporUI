# Controls and inputs

SwiftUI-style controls, typed HTML inputs and the other HTML5 form elements.

## Overview

Every control renders a real form field, so it submits with its ``Form`` and works without JavaScript. The control's `name` is the field name your route decodes.

### SwiftUI-style controls

Each of these renders a `<label>` around its title and field, so clicking the title focuses the field:

```swift
Form(action: "/visit") {
    Toggle("Email me when it opens", name: "notify", isOn: true)
    Picker("Spice", name: "spice", selection: "medium", options: [
        PickerOption("Mild", value: "mild"),
        PickerOption("Medium", value: "medium"),
    ])
    Slider("Brightness", name: "brightness", value: 70, in: 0...100, showsValue: true)
    Stepper("Guests", name: "guests", value: 2, in: 1...12)
    DatePicker("Arriving", name: "arrival", selection: Date(), displayedComponents: [.date, .hourAndMinute])
    ProgressView("Tables booked", value: 31, total: 40)
    Button("Send")
}
```

Modifiers on a control apply to the field, not the label, so `.disabled()` and `.class(_:)` behave as they do in SwiftUI.

| Control | Renders |
| --- | --- |
| ``Toggle`` | `<input type="checkbox">` |
| ``Picker`` | `<select>`, or a `<fieldset>` of radio buttons with ``PickerStyle/radioGroup`` |
| ``Slider`` | `<input type="range">`, with an `<output>` when `showsValue` is on |
| ``Stepper`` | `<input type="number">` |
| ``DatePicker`` | `<input type="date">`, `"time"` or `"datetime-local"` |
| ``ProgressView`` | `<progress>` |

``DatePicker`` writes dates in the time zone you pass, UTC by default. HTML date fields carry no time zone, so read the submitted value back in the same zone.

### Typed inputs

For your own layout, use one view per input type and pair it with ``Label``: ``Checkbox``, ``RadioButton``, ``NumberField``, ``RangeField``, ``DateField``, ``EmailField`` and ``FileField``. A form with a ``FileField`` must post as `multipart/form-data`.

### Other form elements

- ``OptionGroup`` labels a set of ``Option-struct``s in a ``Select``.
- ``DataList`` suggests values for a ``TextField`` with `list:` while still allowing any value.
- ``Meter`` shows a measurement in a range; use ``ProgressView`` for progress through a task.
- ``Output`` shows the result of a calculation.

## Topics

### SwiftUI-style controls

- ``Toggle``
- ``Picker``
- ``PickerOption``
- ``PickerStyle``
- ``Slider``
- ``Stepper``
- ``DatePicker``
- ``DatePickerComponents``
- ``ProgressView``

### Typed inputs

- ``Checkbox``
- ``RadioButton``
- ``NumberField``
- ``RangeField``
- ``DateField``
- ``EmailField``
- ``FileField``

### Other form elements

- ``OptionGroup``
- ``DataList``
- ``Meter``
- ``Output``
