import SwiftVaporUI

// The showcase site is itself built with SwiftVaporUI. These are the views
// that frame every page.

/// The page shell: document head, top bar, topic sidebar and main column.
struct ShowcaseLayout<Content: View>: View {

    // MARK: - Properties

    /// The page title, shown in the browser tab.
    let title: String

    /// The path of the current page, used to highlight the sidebar link.
    let currentPath: String

    /// The page's own content.
    let content: Content

    // MARK: - Initializer

    /// Creates a showcase page.
    /// - Parameters:
    ///   - title: The page title, shown in the browser tab.
    ///   - currentPath: The path of the current page, used to highlight the sidebar link.
    ///   - content: A view builder that creates the page's own content.
    init(title: String, currentPath: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.currentPath = currentPath
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        HTMLDocument(title: "\(title) · SwiftVaporUI Showcase") {
            Meta(name: "description", content: "Live examples of the SwiftVaporUI DSL, each shown next to its Swift source.")
            Style(showcaseCSS)
            HTMXScript()
        } body: {
            Header {
                HStack(spacing: 16) {
                    Link(destination: "/") {
                        Span("SwiftVaporUI").class("brand-name")
                        Span("Showcase").class("brand-tag")
                    }
                    .class("brand")
                    Spacer()
                    NavigationBar {
                        Link("Playground", destination: "/playground")
                            .class("active", when: currentPath == "/playground")
                        Link("Sample app", destination: "/plants")
                        Link("GitHub", destination: "https://github.com/yungdai/SwiftVaporUI")
                    }
                    .class("top-links")
                    .aria("label", "Site")
                }
            }
            .class("topbar")

            Div {
                Nav {
                    Heading("Features", level: .h2).class("sidebar-title")
                    OrderedList {
                        ForEach(Topics.all) { topic in
                            ListItem {
                                Link(topic.title, destination: topic.path)
                                    .class("active", when: topic.path == currentPath)
                                    .tooltip(topic.tagline)
                            }
                        }
                    }
                    Heading("Put together", level: .h2).class("sidebar-title")
                    UnorderedList {
                        ListItem {
                            Link("Capstone: night market", destination: "/capstone")
                                .class("active", when: currentPath == "/capstone")
                        }
                        ListItem {
                            Link("Playground", destination: "/playground")
                                .class("active", when: currentPath == "/playground")
                        }
                    }
                    .class("sidebar-extra")
                }
                .class("sidebar")
                .aria("label", "Features")

                Main { content }.class("content")
            }
            .class("shell")
        }
    }

}

/// One example: the Swift source on the left, the live result on the
/// right, and the HTML it produced underneath.
struct ExampleView: View {

    // MARK: - Properties

    /// The example to show.
    let example: Example

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        let source = example.source
        let html = example.html

        Section {
            Heading(level: .h2) {
                Link(example.title, destination: "#\(example.id)").class("anchor")
            }
            if !example.summary.isEmpty {
                Paragraph(example.summary).class("summary")
            }

            Div {
                CodePanel(source: source)

                Div {
                    Div { Span("Result").class("panel-name") }.class("panel-label")
                    if example.isolated {
                        Element("iframe", attributes: ["srcdoc": html, "title": "Result of \(example.title)", "loading": "lazy"])
                            .class("preview-frame")
                    } else {
                        Div { RawHTML(html) }.class("preview")
                    }
                }
                .class("panel", "result-panel")
            }
            .class("example-grid")

            Details {
                Summary("Rendered HTML")
                Preformatted { Code(HTMLFormatter.format(html)) }.class("code", "html-code")
            }
            .class("html-output")
        }
        .class("example")
        .id(example.id)
    }

}

/// Highlighted Swift source with a copy button and the file it came from.
struct CodePanel: View {

    // MARK: - Properties

    /// The Swift source to show.
    let source: SourceSnippet

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Div {
            HStack(spacing: 8) {
                Span("Swift").class("panel-name")
                Spacer()
                Button("Copy", action: .script("copyCode(this)")).class("copy-button")
            }
            .class("panel-label")
            Preformatted {
                Code { RawHTML(SwiftHighlighter.highlight(source.code)) }
            }
            .class("code")
            if let line = source.line {
                Small("\(source.displayPath):\(line)").class("source-path")
            } else {
                Small(source.displayPath).class("source-path")
            }
        }
        .class("panel", "code-panel")
    }

}

/// A topic page: introduction, contents, every example, and links to the
/// neighbouring topics.
struct TopicPage: View {

    // MARK: - Properties

    /// The topic to show.
    let topic: Topic

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        let index = Topics.all.firstIndex { $0.slug == topic.slug } ?? 0
        let previous = index > 0 ? Topics.all[index - 1] : nil
        let next = index + 1 < Topics.all.count ? Topics.all[index + 1] : nil

        ShowcaseLayout(title: topic.title, currentPath: topic.path) {
            Header {
                Paragraph("Feature \(index + 1) of \(Topics.all.count)").class("eyebrow")
                Heading(topic.title)
                ForEach(topic.intro) { paragraph in
                    Paragraph(paragraph).class("lead")
                }
                Nav {
                    Strong("On this page")
                    UnorderedList {
                        ForEach(topic.examples) { example in
                            ListItem { Link(example.title, destination: "#\(example.id)") }
                        }
                    }
                }
                .class("toc")
                .aria("label", "On this page")
            }
            .class("page-header")

            ForEach(topic.examples) { example in
                ExampleView(example: example)
            }

            Footer {
                if let previous {
                    Link(destination: previous.path) {
                        Small("Previous")
                        Span(previous.title)
                    }
                    .class("pager-link")
                }
                Spacer()
                if let next {
                    Link(destination: next.path) {
                        Small("Next")
                        Span(next.title)
                    }
                    .class("pager-link", "pager-next")
                }
            }
            .class("pager")

            Script(copyScript)
        }
    }

}

/// The landing page.
struct ShowcaseHomePage: View {

    /// The elements this view is made of.
    var body: some View {
        ShowcaseLayout(title: "Home", currentPath: "/") {
            Header {
                Paragraph("SwiftVaporUI").class("eyebrow")
                Heading("SwiftUI-style HTML for Vapor")
                Paragraph("Describe web pages with the declarative, type-checked syntax you already know from SwiftUI, and return them straight from Vapor routes. Every page of this site is written that way.").class("lead")
            }
            .class("page-header")

            ExampleView(example: HomeExamples.quickStart)

            Heading("Explore the features", level: .h2)
            Paragraph("Each page shows live examples. On the left is the Swift that produced the result on the right, read straight from this server's own source files, so the two can never drift apart. Open a file, change it, run again, and see what happens.")
            Div {
                ForEach(Array(Topics.all.enumerated())) { offset, topic in
                    Link(destination: topic.path) {
                        Small("\(offset + 1)")
                        Strong(topic.title)
                        Span(topic.tagline)
                    }
                    .class("topic-card")
                }
            }
            .class("topic-grid")

            Heading("See it all together", level: .h2)
            Paragraph {
                "The "
                Link("capstone page", destination: "/capstone")
                " is a full night market website built from all of these pieces, shown live and then taken apart step by step, from the data model to the route that serves it."
            }

            Heading("Keep going", level: .h2)
            UnorderedList {
                ListItem {
                    Link("Playground", destination: "/playground")
                    ": an empty page in "
                    Code("Playground.swift")
                    " for your own experiments."
                }
                ListItem {
                    Link("Plant Shelf", destination: "/plants")
                    ": a small app with a shared layout, a list, detail pages and a validated form."
                }
                ListItem {
                    "The DocC documentation: open the package in Xcode and choose "
                    Strong("Product › Build Documentation")
                    "."
                }
            }
            Script(copyScript)
        }
    }

}

/// The examples shown on the home page.
enum HomeExamples {

    /// The example on the home page.
    static let quickStart = Example(
        "quick-start",
        title: "A first view",
        summary: "Conform to View, describe the content in body, and return it from a route. Strings in a builder become escaped text."
    ) {
        // snippet: quick-start
        Greeting(name: "Ada", unread: 3)
        // end-snippet
    }

}

// snippet: quick-start
/// The home page's quick-start example view.
struct Greeting: View {

    // MARK: - Properties

    /// The visitor's name.
    let name: String

    /// How many unread messages the visitor has.
    let unread: Int

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Section {
            Heading("Hello, \(name)", level: .h3)
            if unread > 0 {
                Paragraph("You have \(unread) new messages.")
                    .class("notice")
            }
        }
    }

}

// In main.swift:
// app.get("hello") { _ in
//     Greeting(name: "Ada", unread: 3)
// }
// end-snippet

/// The script behind the Copy buttons on code panels.
let copyScript = """
function copyCode(button) {
  const code = button.closest('.panel').querySelector('pre code').innerText;
  navigator.clipboard.writeText(code).then(() => {
    button.textContent = 'Copied';
    setTimeout(() => { button.textContent = 'Copy'; }, 1500);
  });
}
"""
