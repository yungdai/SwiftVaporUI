# ``SwiftVaporUI``

Build HTML pages for Vapor with a declarative, SwiftUI-style DSL.

## Overview

SwiftVaporUI lets you describe web pages in Swift, the same way you describe screens in SwiftUI, and return them straight from Vapor routes. There are no template files to keep in sync: every page is type-checked Swift, made of small views you can reuse, give properties and style with modifiers.

```swift
import SwiftVaporUI

struct Greeting: View {
    let name: String

    var body: some View {
        Section {
            Heading("Hello, \(name)")
            Paragraph("Welcome to the site.")
                .class("lead")
        }
    }
}

app.get("hello") { _ in
    Page(title: "Hello") {
        Greeting(name: "Ada")
    }
}
```

Every string is HTML-escaped, every view can be returned from a route, and the output is plain HTML that works without JavaScript.

The repository includes a showcase server in `Examples/DemoServer` with a page for each feature area. Each example shows its Swift source next to the live result. See <doc:GettingStarted> to run it.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:SettingUpAPage>
- <doc:BuildingViews>
- ``View-protocol``
- ``ViewBuilder``
- ``HTMLResponse``

### Feature guides

- <doc:TextAndElements>
- <doc:LayoutStacks>
- <doc:ContainersAndControls>
- <doc:Modifiers>
- <doc:ModifiersAndEnvironment>
- <doc:ListsAndConditionals>
- <doc:Tables>
- <doc:FormsAndButtons>
- <doc:Controls>
- <doc:Navigation>
- <doc:MediaAndEmbeds>
- <doc:ComposingViews>
- <doc:DocumentsAndResponses>
- <doc:HTMX>
- <doc:PopoversAndDialogs>
- <doc:Safety>

### Text

- ``Text``
- ``Heading``
- ``HeadingLevel``
- ``Paragraph``
- ``Strong``
- ``Emphasis``
- ``Mark``
- ``Keyboard``
- ``Subscript``
- ``Superscript``
- ``Abbreviation``
- ``Time``
- ``Small``
- ``Code``
- ``Preformatted``
- ``Blockquote``
- ``LineBreak``
- ``Divider``

### Layout and structure

- ``HStack``
- ``VStack``
- ``Spacer``
- ``HorizontalAlignment``
- ``VerticalAlignment``
- ``Div``
- ``Span``
- ``Section``
- ``Header``
- ``Footer``
- ``Main``
- ``Article``
- ``Aside``
- ``Nav``
- ``NavigationBar``

### Lists and repetition

- ``List``
- ``ForEach``
- ``UnorderedList``
- ``OrderedList``
- ``ListItem``
- ``DescriptionList``
- ``DescriptionTerm``
- ``DescriptionDetail``

### Tables

- ``Table``
- ``TableHead``
- ``TableBody``
- ``TableFooter``
- ``TableRow``
- ``TableHeaderCell``
- ``TableCell``
- ``TableCaption``

### Forms and buttons

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

### Links, media and other elements

- ``Link``
- ``LinkTarget``
- ``Dialog``
- ``PopoverMode``
- ``PopoverAction``
- ``InvokerCommand``
- ``Image``
- ``Figure``
- ``FigureCaption``
- ``Details``
- ``Summary``
- ``Template``

### Documents

- ``HTMLDocument``
- ``Page``
- ``Document``
- ``HTMLRoot``
- ``Head``
- ``Title``
- ``Meta``
- ``ResourceLink``
- ``Stylesheet``
- ``Style``
- ``Script``
- ``DocumentBody``

### htmx

- ``HTMXScript``
- ``HTMXSwap``
- ``HTMXTrigger``
- ``HTMXRequestDetails``

### Styling

- ``Color``
- ``Font``
- ``Edge``
- ``ModifiedView``

### Building blocks and escape hatches

- ``Element``
- ``VoidElement``
- ``RawHTML``
- ``Group``
- ``EmptyView``
- ``AnyView``
- ``TupleView``
- ``OptionalView``
- ``ConditionalView``
- ``HTMLAttributes``
- ``HTMLRenderer``
- ``HTMLEscaping``
