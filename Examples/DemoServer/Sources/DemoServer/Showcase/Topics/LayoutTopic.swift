import SwiftVaporUI

enum LayoutTopic {
    static let topic = Topic(
        slug: "layout",
        title: "Layout stacks",
        tagline: "HStack, VStack, Spacer and semantic page regions.",
        intro: [
            "HStack and VStack arrange their children in a row or a column using CSS flexbox, with SwiftUI's alignment and spacing parameters. Spacer pushes siblings apart.",
            "For the overall page structure, use the semantic containers (Header, Main, Section, Article, Aside, Footer) so browsers and screen readers understand the page.",
        ],
        examples: [
            Example(
                "hstack",
                title: "HStack",
                summary: "A flex row with an 8 pixel gap by default. Change the alignment and spacing like you would in SwiftUI."
            ) {
                // snippet: hstack
                HStack {
                    Span("Ferns").class("badge")
                    Span("Succulents").class("badge")
                    Span("Palms").class("badge")
                }

                HStack(alignment: .bottom, spacing: 24) {
                    Div { "Short" }.class("box")
                    Div { "Taller"; LineBreak(); "box" }.class("box")
                    Div { "Tallest"; LineBreak(); "box"; LineBreak(); "here" }.class("box")
                }
                .padding(.top, 12)
                // end-snippet
            },

            Example(
                "vstack",
                title: "VStack",
                summary: "With alignment or spacing, VStack is a flex column. With neither, it is a plain <div> so your own CSS can take over."
            ) {
                // snippet: vstack
                VStack(alignment: .leading, spacing: 8) {
                    Div { "Leading" }.class("box")
                    Div { "aligned, 8px apart" }.class("box")
                }

                VStack(alignment: .center, spacing: 4) {
                    Div { "Centered" }.class("box")
                    Div { "with a 4px gap" }.class("box")
                }
                .padding(.top, 16)
                // end-snippet
            },

            Example(
                "spacer",
                title: "Spacer",
                summary: "Spacer fills the free space along the stack's main axis, which is the easy way to push items to opposite edges."
            ) {
                // snippet: spacer
                HStack {
                    Strong("Monstera deliciosa")
                    Span("Bright light").class("badge", "badge-orange")
                    Spacer()
                    Button("Water now", action: .plain).class("button")
                }
                .class("card")
                // end-snippet
            },

            Example(
                "nested",
                title: "Nesting stacks",
                summary: "Stacks nest freely. Here a row holds an avatar and a column of text, a common media layout."
            ) {
                // snippet: nested
                HStack(alignment: .top, spacing: 14) {
                    Div {}
                        .frame(width: 48, height: 48)
                        .background(.hex("e8590c"))
                        .cornerRadius(24)
                    VStack(spacing: 2) {
                        Strong("Sam watered the ferns")
                        Small("Two hours ago").class("muted")
                        Paragraph("They looked a little droopy, so I gave them a good soak.")
                            .style("margin", "6px 0 0")
                    }
                }
                .class("card")
                // end-snippet
            },

            Example(
                "regions",
                title: "Semantic page regions",
                summary: "Header, Nav, Main, Aside, Article, Section and Footer render the matching HTML5 landmarks."
            ) {
                // snippet: regions
                Div {
                    Header { Strong("Greenhouse") }
                    HStack(alignment: .top, spacing: 16) {
                        Main {
                            Article {
                                Heading("Spring planting", level: .h4)
                                Paragraph("Start tomatoes indoors six weeks before the last frost.")
                            }
                        }
                        Aside {
                            Small("Tip: label every tray.")
                        }
                        .frame(maxWidth: 160)
                    }
                    Footer { Small("Updated weekly") }
                }
                .class("sample-site")
                // end-snippet
            },
        ]
    )
}
