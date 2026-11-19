# Text and elements

Headings, paragraphs, inline text, images and the other content elements.

## Overview

Most named views render exactly one HTML element. Text elements have two initializers: one that takes a string, and one that takes a builder so you can mix text with other views.

```swift
Heading("Plant care")                    // <h1>
Heading("Watering", level: .h2)          // <h2>
Paragraph {
    "Water when the top "
    Strong("two centimetres")
    " are dry."
}
```

Inline text views include ``Strong``, ``Emphasis``, ``Small``, ``Code`` and ``Span``. Block views include ``Paragraph``, ``Blockquote``, ``Preformatted`` and ``Divider``. ``LineBreak`` inserts a `<br>`.

``Text`` accepts any `CustomStringConvertible`, so numbers can be used directly: `Text(42)`.

### Text-level elements

``Mark`` highlights text, ``Keyboard`` shows keys, ``Subscript`` and ``Superscript`` shift text, ``Abbreviation`` carries its expansion as a tooltip, and ``Time`` gives a date or time a machine-readable value:

```swift
Paragraph {
    "Press "; Keyboard("⌘K"); " to search. H"; Subscript("2"); "O. "
    Abbreviation("RSVP", title: "Répondez s'il vous plaît")
    " by "; Time("Friday", dateTime: "2026-11-27")
}
```

### Dialogs

``Dialog`` renders `<dialog>`. Open it as a modal with `Button(action: .script("document.getElementById('id').showModal()"))` and close it with a `Form(method: .dialog)`, which needs no script.

### Images and figures

``Image`` requires alt text. Pass an empty string for purely decorative images.

```swift
Figure {
    Image(src: "/images/fern.jpg", alt: "A Boston fern in a hanging basket", width: 640, height: 480)
    FigureCaption("Ferns love humidity.")
}
```

### Disclosure

``Details`` and ``Summary`` make a native collapsible section that needs no JavaScript. Add `.flag("open")` to start it expanded.

### Escape hatches

``Element`` and ``VoidElement`` write any tag. ``RawHTML`` writes markup with no escaping at all; see <doc:Safety> before using it.

## Topics

### Text-level elements

- ``Mark``
- ``Keyboard``
- ``Subscript``
- ``Superscript``
- ``Abbreviation``
- ``Time``
- ``Dialog``

- ``Heading``
- ``Paragraph``
- ``Strong``
- ``Emphasis``
- ``Small``
- ``Code``
- ``Preformatted``
- ``Blockquote``
- ``Span``
- ``LineBreak``
- ``Divider``
- ``Image``
- ``Figure``
- ``FigureCaption``
- ``Details``
- ``Summary``
- ``Template``
- ``RawHTML``
