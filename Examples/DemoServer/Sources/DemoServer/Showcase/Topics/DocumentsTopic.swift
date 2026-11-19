import SwiftVaporUI

/// The documents showcase page.
enum DocumentsTopic {
    /// The documents topic: its title, introduction and examples.
    static let topic = Topic(
        slug: "documents",
        title: "Full documents",
        tagline: "Pages, heads, shared layouts and responses.",
        intro: [
            "A complete page needs a doctype, an <html> element, a <head> and a <body>. HTMLDocument writes all of that, with the charset and viewport meta tags already in place. Page is the shortcut when you only need a title.",
            "The results on this page are whole documents, so each one is shown in its own frame.",
        ],
        examples: [
            Example(
                "page",
                title: "Page",
                summary: "The shortest complete document: a title and body content.",
                isolated: true
            ) {
                // snippet: page
                Page(title: "Hello") {
                    Heading("Hello, web!")
                    Paragraph("A complete HTML document in four lines of Swift.")
                }
                // end-snippet
            },

            Example(
                "html-document",
                title: "HTMLDocument with a head",
                summary: "Add stylesheets, inline styles, scripts and meta tags in the head builder, and the page content in body.",
                isolated: true
            ) {
                // snippet: html-document
                HTMLDocument(title: "Seed swap") {
                    Meta(name: "description", content: "Swap seeds with your neighbours")
                    Style("""
                    body { font-family: Georgia, serif; background: #fbf7ef; color: #3b2f1e; padding: 24px; }
                    h1 { color: #8a4b12; }
                    """)
                } body: {
                    Main {
                        Heading("Seed swap")
                        Paragraph("Saturday, 10am, at the community hall.")
                    }
                }
                // end-snippet
            },

            Example(
                "layout",
                title: "A shared layout",
                summary: "Wrap HTMLDocument in your own view to give every page the same head, header and footer. This showcase uses the same pattern.",
                isolated: true
            ) {
                // snippet: layout
                SiteShell(title: "Allotments") {
                    Heading("Allotment waiting list", level: .h2)
                    Paragraph("There are 14 people ahead of you.")
                }
                // end-snippet
            },

            Example(
                "manual",
                title: "Building the structure yourself",
                summary: "For full control, compose Document, HTMLRoot, Head, Title, Meta, ResourceLink and DocumentBody directly.",
                isolated: true
            ) {
                // snippet: manual
                Document {
                    HTMLRoot(language: "fr") {
                        Head {
                            Meta(charset: "utf-8")
                            Title("Bonjour")
                            ResourceLink(relationship: "icon", destination: "/images/leaf.svg")
                        }
                        DocumentBody {
                            Heading("Bonjour !")
                            Paragraph("Cette page déclare lang=\"fr\" sur l’élément html.")
                        }
                        .style("font-family", "system-ui")
                    }
                }
                // end-snippet
            },

            Example(
                "responses",
                title: "Status codes and headers",
                summary: "Returning a view sends 200 OK as text/html. Wrap it in HTMLResponse to choose another status or add headers.",
                isolated: true
            ) {
                // snippet: responses
                MissingPage(path: "/documents/missing")
                // end-snippet
            },
        ]
    )
}

// snippet: layout
struct SiteShell<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HTMLDocument(title: "\(title) · Greenfield") {
            Style("body { margin: 0; font-family: system-ui } header, footer, main { padding: 12px 20px }")
        } body: {
            Header {
                Strong("🌱 Greenfield")
            }
            .background(.hex("e3f4e7"))
            Main { content }
            Footer {
                Small("© Greenfield allotment society")
            }
            .foregroundColor(.gray)
        }
    }
}
// end-snippet

// snippet: responses
struct MissingPage: View {
    let path: String

    var body: some View {
        Page(title: "Not found") {
            Heading("404: nothing here")
            Paragraph {
                "There is no page at "
                Code(path)
                "."
            }
            Link("Back to the showcase", destination: "/documents")
                .attribute("target", "_top")
        }
    }
}

/// Registers the routes the document examples link to.
func registerDocumentRoutes(_ app: Application) {
    app.get("documents", "missing") { req in
        HTMLResponse(status: .notFound, headers: ["Cache-Control": "no-store"]) {
            MissingPage(path: req.url.path)
        }
    }
}
// end-snippet
