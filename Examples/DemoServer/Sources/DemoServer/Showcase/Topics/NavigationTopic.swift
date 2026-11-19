import SwiftVaporUI

enum NavigationTopic {
    static let topic = Topic(
        slug: "navigation",
        title: "Navigation and links",
        tagline: "Links, navigation bars, breadcrumbs and routes.",
        intro: [
            "On the web, navigation is links and routes. Link renders an <a>, NavigationBar lays links out in a <nav>, and each Vapor route returns the view for its page.",
        ],
        examples: [
            Example(
                "links",
                title: "Links",
                summary: "Link takes a title and a destination, or a label builder for richer content. Add any other attribute with .attribute."
            ) {
                // snippet: links
                Paragraph {
                    "Read the "
                    Link("tables page", destination: "/tables")
                    " or jump to "
                    Link("the breadcrumbs example", destination: "#breadcrumbs")
                    "."
                }
                Paragraph {
                    Link(destination: "/components") {
                        Strong("Components")
                        " → build your own views"
                    }
                }
                Paragraph {
                    Link("Vapor documentation", destination: "https://docs.vapor.codes")
                        .attribute("target", "_blank")
                        .attribute("rel", "noopener")
                    Small(" (opens in a new tab)").class("muted")
                }
                // end-snippet
            },

            Example(
                "navigation-bar",
                title: "NavigationBar with an active link",
                summary: "NavigationBar is a <nav> laid out as a row. Mark the current page with .class(_:when:) and aria-current."
            ) {
                // snippet: navigation-bar
                let current = "/navigation"
                let sections = [("Lists", "/lists"), ("Navigation", "/navigation"), ("Tables", "/tables")]

                NavigationBar(spacing: 4) {
                    ForEach(sections) { title, path in
                        Link(title, destination: path)
                            .class("active", when: path == current)
                            .attribute("aria-current", path == current ? "page" : nil)
                    }
                }
                .class("pill-nav")
                .aria("label", "Sections")
                // end-snippet
            },

            Example(
                "breadcrumbs",
                title: "A breadcrumbs component",
                summary: "Small, reusable navigation pieces are just views with properties."
            ) {
                // snippet: breadcrumbs
                Breadcrumbs(trail: [
                    ("Home", "/"),
                    ("Features", "/text"),
                    ("Navigation", "/navigation"),
                ])
                // end-snippet
            },

            Example(
                "routes",
                title: "Routes return views",
                summary: "Any view can be returned from a Vapor route. These links go to a route that reads a path parameter and renders a page with it."
            ) {
                // snippet: routes
                NavigationBar {
                    for name in ["Ada", "Grace", "Linus"] {
                        Link("Greet \(name)", destination: "/navigation/greet/\(name)")
                    }
                }
                // end-snippet
            },
        ]
    )
}

// snippet: breadcrumbs
struct Breadcrumbs: View {
    let trail: [(title: String, path: String)]

    var body: some View {
        Nav {
            OrderedList {
                for (index, crumb) in trail.enumerated() {
                    ListItem {
                        if index == trail.count - 1 {
                            Span(crumb.title).aria("current", "page")
                        } else {
                            Link(crumb.title, destination: crumb.path)
                        }
                    }
                }
            }
        }
        .class("breadcrumbs")
        .aria("label", "Breadcrumb")
    }
}
// end-snippet

// snippet: routes
func registerNavigationRoutes(_ app: Application) {
    app.get("navigation", "greet", ":name") { req in
        let name = req.parameters.get("name") ?? "friend"
        return GreetingPage(name: name)
    }
}

struct GreetingPage: View {
    let name: String

    var body: some View {
        ShowcaseLayout(title: "Hello, \(name)", currentPath: "/navigation") {
            Heading("Hello, \(name)!")
            Paragraph("This page came from the route /navigation/greet/:name.")
            Link("← Back to navigation", destination: "/navigation#routes")
        }
    }
}
// end-snippet
