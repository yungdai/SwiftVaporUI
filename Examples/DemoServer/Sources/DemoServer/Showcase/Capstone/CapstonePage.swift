import SwiftVaporUI

/// The capstone: a realistic page that uses most of the DSL, shown live
/// and then taken apart piece by piece.
struct CapstonePage: View {
    struct Step: Sendable {
        let id: String
        let title: String
        let text: String
        let snippet: String
        let file: String
    }

    static let steps = [
        Step(id: "data", title: "1. The data",
             text: "Plain Swift structs and enums hold the content. Nothing here knows about HTML. In a real app this would come from Fluent or an API.",
             snippet: "market-data", file: marketDataSourceFile),
        Step(id: "page", title: "2. The page",
             text: "MarketPage is the whole document. HTMLDocument writes the doctype and head, and the body is a list of smaller views, each taking only the data it needs.",
             snippet: "market-page", file: marketPageSourceFile),
        Step(id: "header", title: "3. Header and hero",
             text: "HStack, Spacer and NavigationBar build the top bar. The hero uses Button(action: .navigate) for links styled as buttons, and a small HeroStat component three times.",
             snippet: "market-header", file: marketPageSourceFile),
        Step(id: "stalls", title: "4. Stalls, with a filter",
             text: "The category filter is ordinary links with a query string. The route reads it and passes it in, and .class(_:when:) marks the active one. Each card uses if/else if for its badge.",
             snippet: "market-stalls", file: marketPageSourceFile),
        Step(id: "schedule", title: "5. Schedule and FAQ",
             text: "A Table built with ForEach, and native Details elements for the questions, so they open without any JavaScript.",
             snippet: "market-schedule", file: marketPageSourceFile),
        Step(id: "visit", title: "6. The form and its states",
             text: "A switch over VisitState shows the form, the form with an error, or a confirmation. The form keeps the visitor's values when it is shown again.",
             snippet: "market-visit", file: marketPageSourceFile),
        Step(id: "routes", title: "7. Serving it",
             text: "Two routes: GET renders the page, POST validates the form and renders the page again with the outcome, using HTMLResponse for the 422 status.",
             snippet: "market-routes", file: marketPageSourceFile),
    ]

    var body: some View {
        let html = MarketPage(market: NightMarket(), category: nil).render()

        ShowcaseLayout(title: "Capstone: a night market page", currentPath: "/capstone") {
            Header {
                Paragraph("Putting it together").class("eyebrow")
                Heading("A night market page")
                Paragraph("This is a complete, realistic page built from the pieces on the other feature pages: layout stacks, styling, lists, conditionals, a table, a working form, navigation, custom components and a full document. Below the live page, each step shows the Swift that builds it.").class("lead")
                HStack(spacing: 10) {
                    Button("Open the page on its own", action: .navigate(to: "/market")).class("button")
                    Button("Jump to the code", action: .navigate(to: "#how")).class("button-secondary")
                }
            }
            .class("page-header")

            Section {
                Div {
                    Div {
                        Span("Live result: /market").class("panel-name")
                    }
                    .class("panel-label")
                    Element("iframe", attributes: ["src": "/market", "title": "The night market page", "loading": "lazy"])
                        .class("preview-frame", "capstone-frame")
                }
                .class("panel", "result-panel")
            }
            .class("example")

            Section {
                Heading("How it is built", level: .h2)
                Paragraph("Every block of code below is read from the files in Sources/DemoServer/Showcase/Capstone, so it is exactly what produced the page above. Try changing a stall or a colour and running again.")
                    .class("summary")
                Nav {
                    UnorderedList {
                        ForEach(Self.steps) { step in
                            ListItem { Link(step.title, destination: "#\(step.id)") }
                        }
                    }
                }
                .class("toc")
            }
            .class("example")
            .id("how")

            ForEach(Self.steps) { step in
                Section {
                    Heading(level: .h2) {
                        Link(step.title, destination: "#\(step.id)").class("anchor")
                    }
                    Paragraph(step.text).class("summary")
                    CodePanel(source: SourceLibrary.shared.snippet(step.snippet, in: step.file))
                }
                .class("example")
                .id(step.id)
            }

            Section {
                Heading("8. What the browser receives", level: .h2)
                Paragraph("The route sends this HTML, rendered in a single pass with every string escaped. It is \(html.utf8.count.formatted()) bytes.")
                    .class("summary")
                Details {
                    Summary("Show the rendered HTML")
                    Preformatted { Code(HTMLFormatter.format(html)) }.class("code", "html-code")
                }
                .class("html-output")
            }
            .class("example")

            Script(copyScript)
        }
    }
}
