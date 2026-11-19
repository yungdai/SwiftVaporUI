import SwiftVaporUI

/// The "Styling modifiers" showcase page.
enum StylingTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "styling",
        title: "Styling modifiers",
        tagline: "Classes, attributes and SwiftUI-style styling.",
        intro: [
            "Modifiers change the attributes of the first HTML element a view renders. Attribute modifiers such as .class, .id and .aria set HTML attributes. Styling modifiers such as .padding, .font and .foregroundColor add inline CSS to the same element instead of wrapping it in another div.",
            "Classes and styles accumulate as you chain modifiers. For any other attribute set twice, the last modifier in the chain wins.",
        ],
        examples: [
            Example(
                "classes",
                title: "Classes and attributes",
                summary: "Use .class with one or more names, .class(_:when:) for conditional classes, and .id, .role, .data, .aria and .tooltip for the rest."
            ) {
                // snippet: classes
                let isUrgent = true

                Paragraph("Three plants need water today.")
                    .class("notice")
                    .class("warning", when: isUrgent)
                    .id("watering-alert")
                    .role("status")
                    .data("count", "3")
                    .tooltip("Updated a minute ago")
                // end-snippet
            },

            Example(
                "fonts-colors",
                title: "Fonts and colors",
                summary: "Font has SwiftUI's text styles plus .system(size:weight:). Color has named colors, .hex and .rgb."
            ) {
                // snippet: fonts-colors
                Text("Large title").font(.largeTitle)
                LineBreak()
                Text("Headline").font(.headline)
                LineBreak()
                Text("Caption, in gray").font(.caption).foregroundColor(.gray)
                LineBreak()
                Text("Custom 20px medium, in hex").font(.system(size: 20, weight: .medium)).foregroundColor(.hex("1c5fd4"))
                LineBreak()
                Text("Bold and italic").bold().italic()
                // end-snippet
            },

            Example(
                "box-styling",
                title: "Padding, background and shape",
                summary: "Padding takes a length and optional edges. Combine it with background, cornerRadius, frame and opacity."
            ) {
                // snippet: box-styling
                HStack(spacing: 12) {
                    Div { "All edges" }
                        .padding(16)
                        .background(.hex("e3f4e7"))
                        .cornerRadius(12)

                    Div { "Horizontal" }
                        .padding(.horizontal, 32)
                        .background(.hex("fff1e8"))
                        .cornerRadius(999)

                    Div { "Faded" }
                        .padding(16)
                        .background(.rgb(28, 95, 212, opacity: 0.15))
                        .opacity(0.6)
                }
                // end-snippet
            },

            Example(
                "swatches",
                title: "Styling data-driven views",
                summary: "Modifiers are ordinary Swift calls, so their arguments can come from your data."
            ) {
                // snippet: swatches
                let palette: [(name: String, color: Color)] = [
                    ("Fern", .hex("2f6b3a")),
                    ("Terracotta", .hex("c4622d")),
                    ("Sky", .hex("5b9bd5")),
                    ("Sand", .hex("e4d3a8")),
                ]

                HStack(alignment: .top, spacing: 16) {
                    ForEach(palette) { swatch in
                        VStack(alignment: .center, spacing: 6) {
                            Div {}.class("swatch").background(swatch.color)
                            Small(swatch.name)
                        }
                    }
                }
                // end-snippet
            },

            Example(
                "order",
                title: "How modifiers combine",
                summary: "Classes and styles add up. For other attributes the outermost (last) modifier wins. A modifier on bare Text wraps it in a <span>."
            ) {
                // snippet: order
                Paragraph("Which id wins?")
                    .id("first")
                    .id("second")        // last one wins
                    .class("notice")
                    .class("muted")      // classes accumulate
                    .padding(12)
                    .bold()              // styles accumulate

                Paragraph {
                    "Plain text, then "
                    Text("modified text").foregroundColor(.red)
                }
                // end-snippet
            },

            Example(
                "raw-style",
                title: "Raw CSS when you need it",
                summary: "When there is no dedicated modifier, .style takes any CSS declarations, either as one string or as a property and a value."
            ) {
                // snippet: raw-style
                Div { "Dashed, with a shadow" }
                    .style("border: 2px dashed #e8590c; box-shadow: 0 4px 14px rgb(0 0 0 / 12%)")
                    .style("letter-spacing", "0.08em")
                    .padding(16)
                    .cornerRadius(10)
                // end-snippet
            },

            Example(
                "border-shadow",
                title: "Border, shadow and opacity",
                summary: "SwiftUI-style .border(_:width:), .shadow(color:radius:x:y:) and .opacity(_:) add inline CSS to the element, like the other styling modifiers."
            ) {
                // snippet: border-shadow
                HStack(spacing: 16) {
                    Div { "Border" }
                        .padding(16)
                        .border(.hex("1c5fd4"), width: 2)
                        .cornerRadius(8)
                    Div { "Shadow" }
                        .padding(16)
                        .background(.white)
                        .cornerRadius(8)
                        .shadow(radius: 12, y: 4)
                    Div { "Half opacity" }
                        .padding(16)
                        .background(.hex("e8590c"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .opacity(0.5)
                }
                // end-snippet
            },
        ]
    )

}
