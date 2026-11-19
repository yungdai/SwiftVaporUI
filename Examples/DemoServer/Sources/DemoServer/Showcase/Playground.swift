import SwiftVaporUI

/// Where this file lives, so the playground page can show its source.
let playgroundSourceFile = #filePath

// ┌──────────────────────────────────────────────────────────────────────┐
// │ The playground. Change PlaygroundView, run the server again (⌘R in    │
// │ Xcode, or `swift run`), and reload http://127.0.0.1:8080/playground.  │
// │ The page shows your code next to what it renders.                    │
// └──────────────────────────────────────────────────────────────────────┘

// snippet: playground
struct PlaygroundView: View {
    var body: some View {
        Heading("Hello from the playground", level: .h3)
        Paragraph("Edit Playground.swift and run again to change this.")
        HStack {
            for word in ["Swift", "Vapor", "HTML"] {
                Span(word).class("badge")
            }
        }
    }
}
// end-snippet

struct PlaygroundPage: View {
    var body: some View {
        ShowcaseLayout(title: "Playground", currentPath: "/playground") {
            Header {
                Paragraph("Try it yourself").class("eyebrow")
                Heading("Playground")
                Paragraph {
                    "Open "
                    Code("Examples/DemoServer/Sources/DemoServer/Showcase/Playground.swift")
                    ", change PlaygroundView, then run the server again and reload this page. Everything from the feature pages works here."
                }
                .class("lead")
            }
            .class("page-header")

            ExampleView(example: Example(
                "playground",
                title: "Your view",
                summary: "This is PlaygroundView, rendered live.",
                file: playgroundSourceFile
            ) {
                PlaygroundView()
            })

            Script(copyScript)
        }
    }
}
