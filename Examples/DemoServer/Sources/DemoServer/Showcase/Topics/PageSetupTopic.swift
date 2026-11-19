import SwiftVaporUI

/// The folder of the demo's sources (`Sources/DemoServer`), found from this
/// file's path.
let demoSourcesDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent() // Topics
    .deletingLastPathComponent() // Showcase
    .deletingLastPathComponent() // DemoServer

/// Where `main.swift` lives, so the page setup topic can show its source.
let mainSourceFile = demoSourcesDirectory.appendingPathComponent("main.swift").path

/// Finds the demo's `Public` folder.
///
/// Vapor's `app.directory.publicDirectory` is used when it exists, which is
/// the case when the server runs from the package folder or a deployment
/// that ships `Public`. Otherwise the folder next to the demo's
/// `Package.swift` is used, which also works from Xcode.
/// - Parameter app: The application, for its working directory and logger.
/// - Returns: The path of the folder to serve, ending in `/`.
func demoPublicDirectory(for app: Application) -> String {
    let fromWorkingDirectory = app.directory.publicDirectory
    if FileManager.default.fileExists(atPath: fromWorkingDirectory) {
        return fromWorkingDirectory
    }
    let fromSources = demoSourcesDirectory
        .deletingLastPathComponent() // Sources
        .deletingLastPathComponent() // the package folder
        .appendingPathComponent("Public").path + "/"
    if !FileManager.default.fileExists(atPath: fromSources) {
        app.logger.warning("No Public folder at \(fromWorkingDirectory) or \(fromSources); CSS and JavaScript files will not be served.")
    }
    return fromSources
}

// snippet: site-layout
/// The layout every page of a site shares: one `<head>` with the stylesheet
/// and script, a header, the page's own content and a footer.
struct MarketLayout<Content: View>: View {

    // MARK: - Properties

    /// The page title, shown in the browser tab.
    let title: String

    /// The page's own content.
    let content: Content

    // MARK: - Initializer

    /// Creates a page in the shared layout.
    /// - Parameters:
    ///   - title: The page title, shown in the browser tab.
    ///   - content: A view builder that creates the page's own content.
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // MARK: - View

    /// The document, with the shared head, header and footer around the content.
    var body: some View {
        HTMLDocument(title: "\(title) · Night Market") {
            Stylesheet(href: "/css/page-setup.css")
            Script(src: "/js/page-setup.js", defer: true)
        } body: {
            Header { Strong("Riverside Night Market") }
            Main { content }
            Footer { Small("Every Friday by the river.") }
        }
    }

}
// end-snippet

/// The "Setting up a page" showcase page: how a web page differs from a
/// SwiftUI screen, and where styles and scripts go.
enum PageSetupTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "page-setup",
        title: "Setting up a page",
        tagline: "The document, its head, CSS and scripts, static files and a shared layout.",
        intro: [
            "A SwiftUI screen is a tree of views and nothing else. A web page is a document: the browser reads a <head> with the title, character set, viewport, stylesheets and scripts, then a <body> with the content. Your views only describe the body; the head is where you connect the CSS and JavaScript they rely on.",
            "Put stylesheets in the head so the page never draws unstyled. Load scripts with defer (or as modules) in the head, or put inline scripts at the end of the body, so they run once the elements they touch exist. Serve your .css and .js files from Public/ with Vapor's FileMiddleware, and wrap every page in one layout view so each gets the same head.",
        ],
        examples: [
            Example(
                "document-anatomy",
                title: "The parts of a document",
                summary: "Built by hand from Document, HTMLRoot, Head and DocumentBody to show every piece. HTMLDocument writes the same structure for you.",
                isolated: true
            ) {
                // snippet: document-anatomy
                Document {                                   // <!DOCTYPE html>
                    HTMLRoot(language: "en") {               // <html lang="en">
                        Head {
                            Meta(charset: "utf-8")           // how to read the bytes
                            Meta(name: "viewport", content: "width=device-width, initial-scale=1")
                            Title("Tonight")                 // the browser tab
                            Stylesheet(href: "/css/page-setup.css")       // CSS first
                            Script(src: "/js/page-setup.js", defer: true) // runs after parsing
                        }
                        DocumentBody {
                            Header { Strong("Riverside Night Market") }
                            Main {
                                Paragraph("Styled by /css/page-setup.css.")
                                Paragraph("Waiting for JavaScript…")
                                    .data("js-status", "")
                                    .class("js-status")
                                Paragraph("Inline script: not run yet.").id("inline-status")
                            }
                            // An inline script at the end of the body runs once
                            // everything above it exists.
                            Script("document.getElementById('inline-status').textContent = 'Inline script at the end of <body> ran.'")
                        }
                    }
                }
                // end-snippet
            },

            Example(
                "site-layout",
                title: "One layout for every page",
                summary: "MarketLayout owns the head, header and footer. Each route only says what is different about its page.",
                isolated: true
            ) {
                // snippet: site-layout
                MarketLayout(title: "Stalls") {
                    Heading("The stalls", level: .h2)
                    Paragraph("Eight stalls tonight, two of them new.")
                    Paragraph("").data("js-status", "").class("js-status")
                }
                // end-snippet
            },

            Example(
                "static-files",
                title: "Serving CSS and JavaScript",
                summary: "FileMiddleware serves the files in Public/ at the root of the site. This is the line in the demo's main.swift.",
                snippet: "static-files",
                file: mainSourceFile
            ) {
                Preformatted {
                    Code("""
                    Examples/DemoServer/
                    ├── Package.swift
                    ├── Public/
                    │   ├── css/page-setup.css   →  /css/page-setup.css
                    │   └── js/page-setup.js     →  /js/page-setup.js
                    └── Sources/DemoServer/main.swift
                    """)
                }
                .class("code", "html-code")
            },
        ]
    )

}
