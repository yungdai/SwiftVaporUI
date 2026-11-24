# Popovers and dialogs

Open popovers, menus and modal dialogs with HTML attributes alone, no script.

## Overview

Browsers can now show and hide popovers and dialogs on their own. A button names the element it controls by `id`, and the browser handles opening, closing, focus, the Escape key and the top layer. SwiftVaporUI writes those attributes for you through ``ButtonAction``.

### Popovers

Make any element a popover with `.popover()`, give it an `id`, and point a button at it with ``ButtonAction/popover(_:target:)``.

```swift
Button("What's a bao?", action: .popover(target: "bao-info"))
Paragraph("A soft steamed bun, folded around a filling.")
    .id("bao-info")
    .popover()
```

The button toggles the popover by default; pass `.show` or `.hide` for a button that only opens or only closes it. ``PopoverMode`` sets how it closes:

| Mode | Closes when | Use it for |
| --- | --- | --- |
| `.auto` | The visitor clicks elsewhere, presses Escape, or opens another `auto` popover | Menus, pickers, details |
| `.manual` | A button or script closes it | Toasts, notices |
| `.hint` | Like `auto`, but leaves `auto` popovers open | Tooltips |

### Menus

``Menu`` with a `popoverID` is built on the Popover API: its items open on top of the page, below the button where the browser supports anchor positioning, and close on an outside click or Escape. Without one, it is built on `<details>` as before.

```swift
Menu("Directions", popoverID: "directions-menu") {
    Link("Walking", destination: "/walk")
    Link("By bus", destination: "/bus")
}
```

### Dialogs

Invoker commands let a button act on another element. ``ButtonAction/command(_:target:)`` writes `commandfor` and `command`; ``InvokerCommand`` names the built-in commands.

```swift
Button("Show today's special", action: .command(.showModal, target: "special"))
Dialog {
    Paragraph("Crispy pork belly bao, until they run out.")
    Button("Close", action: .command(.close, target: "special"))
}
.id("special")
```

`.showModal` opens a ``Dialog`` as a modal and `.close` closes it. A `Form(method: .dialog)` with a button inside the dialog closes it too.

Invoker commands need Chrome 135, Safari 26.2, Firefox 144 or later; the Popover API is older and works in every current browser. If you must support older browsers, open the dialog with ``ButtonAction/script(_:)`` calling `showModal()` and close it with a `Form(method: .dialog)`, which works everywhere. The popover commands (`.togglePopover`, `.showPopover`, `.hidePopover`) work on popovers, and ``InvokerCommand/custom(_:)`` sends your own `--` command for a script to handle with a `command` event listener.

Reach for ``ButtonAction/script(_:)`` only for behaviour the browser does not have built in.

## Topics

### Popovers

- ``PopoverMode``
- ``PopoverAction``

### Commands

- ``InvokerCommand``
- ``ButtonAction``
- ``Dialog``
