import SwiftVaporUI

enum ElementsTopic {
    static let topic = Topic(
        slug: "elements",
        title: "More elements",
        tagline: "Images, figures, details and escape hatches.",
        intro: [
            "Beyond text and layout, SwiftVaporUI has views for images, figures, disclosure widgets and templates. For any tag it does not cover, Element and VoidElement let you write it directly, and RawHTML is there for trusted markup.",
        ],
        examples: [
            Example(
                "images",
                title: "Images and figures",
                summary: "Image requires alt text to encourage accessible pages. Figure and FigureCaption pair an image with its caption."
            ) {
                // snippet: images
                Figure {
                    Image(src: "/images/leaf.svg", alt: "A green leaf drawn as a simple outline", width: 120, height: 120)
                    FigureCaption("Served by the demo server from an SVG route.")
                }
                // end-snippet
            },

            Example(
                "details",
                title: "Details and summary",
                summary: "A native disclosure widget, no JavaScript needed. Add the open flag to start expanded."
            ) {
                // snippet: details
                Details {
                    Summary("Why are the leaves turning yellow?")
                    Paragraph("Most often it is overwatering. Let the soil dry out more between waterings.")
                }
                Details {
                    Summary("How much light is enough?")
                    Paragraph("If you can comfortably read a book there at midday, most foliage plants are fine.")
                }
                .flag("open")
                // end-snippet
            },

            Example(
                "custom-elements",
                title: "Element and VoidElement",
                summary: "Write any tag the library does not name, including custom elements and web components. Attributes are escaped and tag names validated."
            ) {
                // snippet: custom-elements
                Paragraph {
                    "Last watered "
                    Element("time", attributes: ["datetime": "2026-11-18"]) { "yesterday" }
                    "."
                }
                Paragraph {
                    "Progress: "
                    Element("progress", attributes: ["value": "70", "max": "100"]) { "70%" }
                }
                Element("mark") { "Highlighted with <mark>" }
                VoidElement("wbr")
                // end-snippet
            },

            Example(
                "raw-html",
                title: "RawHTML for trusted markup",
                summary: "RawHTML writes its string with no escaping. Only use it with markup you wrote or trust, never with user input."
            ) {
                // snippet: raw-html
                RawHTML("<p>This paragraph was written as <abbr title=\"HyperText Markup Language\">HTML</abbr> by hand.</p>")
                // end-snippet
            },

            Example(
                "groups",
                title: "Group and EmptyView",
                summary: "Group bundles views without adding an element. EmptyView renders nothing, which helps for optional slots."
            ) {
                // snippet: groups
                Div {
                    Group {
                        Span("One").class("badge")
                        " "
                        Span("Two").class("badge")
                    }
                    EmptyView()
                }
                // end-snippet
            },

            Example(
                "dialog",
                title: "Dialog",
                summary: "Dialog renders <dialog>. Open it as a modal with one line of script, and close it with a Form(method: .dialog), which needs no script at all."
            ) {
                // snippet: dialog
                Button("Show today's special", action: .script("document.getElementById('special').showModal()"))
                    .class("button")
                Dialog {
                    Heading("Today's special", level: .h3)
                    Paragraph("Crispy pork belly bao, until they run out.")
                    Form(method: .dialog) {
                        Button("Close").class("button-secondary")
                    }
                }
                .id("special")
                .border(.hex("e2e5eb"))
                .cornerRadius(12)
                // end-snippet
            },

            Example(
                "global-attributes",
                title: "Global attributes",
                summary: "Modifiers for the attributes any element can take: .title(_:) for a tooltip, .tabIndex(_:) for focus order, .lang(_:) for language, and .hidden() and .disabled()."
            ) {
                // snippet: global-attributes
                VStack(spacing: 8) {
                    Span("Hover me for a tooltip").title("Opens at 6pm")
                    Div { "This box can take keyboard focus" }
                        .class("box")
                        .tabIndex(0)
                    Paragraph("Guten Appetit!").lang("de")
                    Paragraph("You cannot see this paragraph.").hidden()
                    Button("Sold out", action: .plain).class("button").disabled()
                }
                // end-snippet
            },
        ]
    )
}

/// A small leaf illustration for the images example.
let leafSVG = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120"><rect width="120" height="120" rx="16" fill="#e3f4e7"/><path d="M28 92 C28 50 56 26 94 26 C94 66 70 92 28 92 Z" fill="#3c8d52"/><path d="M28 92 L78 42" stroke="#e3f4e7" stroke-width="4" stroke-linecap="round"/></svg>
"""
