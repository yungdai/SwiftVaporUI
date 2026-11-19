import SwiftVaporUI

/// The text showcase page.
enum TextTopic {
    /// The text topic: its title, introduction and examples.
    static let topic = Topic(
        slug: "text",
        title: "Text and headings",
        tagline: "Headings, paragraphs, inline styles and escaping.",
        intro: [
            "Text is the starting point. A bare string in a view builder becomes escaped text, and the named elements (Heading, Paragraph, Strong and friends) map one to one onto their HTML tags.",
            "Most text elements have two forms: a string initializer for plain text, and a builder initializer when you want to mix text with other views.",
        ],
        examples: [
            Example(
                "headings",
                title: "Headings",
                summary: "Heading defaults to <h1>. Pass a level for <h2> to <h6>, or use the builder form to mix in other views."
            ) {
                // snippet: headings
                Heading("Plant care guide")
                Heading("Watering", level: .h2)
                Heading("How often?", level: .h3)
                Heading(level: .h4) {
                    "Rule of "
                    Emphasis("thumb")
                }
                // end-snippet
            },

            Example(
                "inline",
                title: "Paragraphs and inline text",
                summary: "Inside a builder, string literals sit next to inline elements, just like SwiftUI's Text concatenation."
            ) {
                // snippet: inline
                Paragraph {
                    "Water when the top "
                    Strong("two centimetres")
                    " of soil feel dry. "
                    Emphasis("Never")
                    " leave the pot standing in water."
                }
                Paragraph {
                    "Set the timer with "
                    Code("reminder.every(days: 7)")
                    "."
                    LineBreak()
                    Small("Times are approximate.")
                }
                // end-snippet
            },

            Example(
                "interpolation",
                title: "Interpolation and other values",
                summary: "Interpolate any value into a string, or pass numbers and other CustomStringConvertible values to Text directly."
            ) {
                // snippet: interpolation
                let plants = 12
                let thirsty = 3
                let ratio = Double(thirsty) / Double(plants)

                Paragraph("\(thirsty) of your \(plants) plants need water today.")
                Paragraph {
                    "Share of the shelf: "
                    Text(ratio)
                }
                // end-snippet
            },

            Example(
                "escaping",
                title: "Escaping is automatic",
                summary: "Strings are always HTML-escaped, so user input cannot inject markup. Look at the rendered HTML below the result."
            ) {
                // snippet: escaping
                let userInput = "<script>alert('hi')</script> & \"friends\""

                Paragraph {
                    "You searched for: "
                    Strong(userInput)
                }
                // end-snippet
            },

            Example(
                "blocks",
                title: "Quotes, preformatted text and dividers",
                summary: "Blockquote, Preformatted and Divider cover the remaining block-level text elements."
            ) {
                // snippet: blocks
                Blockquote("Plants grow at their own pace. Most good care is simply patience.")
                Divider()
                Preformatted("""
                Mon  water ferns
                Wed  mist orchids
                Sat  feed everything
                """)
                // end-snippet
            },
        ]
    )
}
