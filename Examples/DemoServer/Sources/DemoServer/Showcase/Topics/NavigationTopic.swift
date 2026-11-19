import SwiftVaporUI

/// The "Navigation and links" showcase page.
enum NavigationTopic {

    /// The page's topic, with every example.
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

            Example(
                "navigation-link",
                title: "NavigationLink and the current page",
                summary: "NavigationLink(isActive:) marks the link to the page being shown with aria-current=\"page\", which screen readers announce and CSS can style."
            ) {
                // snippet: navigation-link
                NavigationBar(spacing: 4) {
                    NavigationLink("Stalls", destination: "#navigation-link", isActive: true)
                    NavigationLink("Map", destination: "#navigation-link")
                    NavigationLink("Visit", destination: "#navigation-link")
                }
                .class("pill-nav")
                // end-snippet
            },

            Example(
                "link-targets",
                title: "Opening links elsewhere",
                summary: "target: .blank opens a new tab and adds rel=\"noopener\" for you. Pass relationship for other rel values, such as nofollow for links you do not vouch for."
            ) {
                // snippet: link-targets
                UnorderedList {
                    ListItem {
                        Link("Vapor documentation", destination: "https://docs.vapor.codes", target: .blank)
                    }
                    ListItem {
                        Link("A visitor's blog", destination: "https://example.com", target: .blank, relationship: "nofollow noopener")
                    }
                    ListItem {
                        Link("Download the menu", destination: "/images/leaf.svg").attribute("download", "menu.svg")
                    }
                }
                // end-snippet
            },
        ]
    )
}

// snippet: breadcrumbs
/// A breadcrumb trail from the home page to the current one.
struct Breadcrumbs: View {

    // MARK: - Properties

    /// The pages from the home page to this one.
    let trail: [(title: String, path: String)]

    // MARK: - View

    /// The elements this view is made of.
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
/// Registers the routes the navigation examples link to.
/// - Parameter app: The application to add the routes to.
func registerNavigationRoutes(_ app: Application) {
    app.get("navigation", "greet", ":name") { req in
        let name = req.parameters.get("name") ?? "friend"
        return GreetingPage(name: name)
    }
}

/// A page that greets the name in its URL.
struct GreetingPage: View {

    // MARK: - Properties

    /// The name from the URL.
    let name: String

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        ShowcaseLayout(title: "Hello, \(name)", currentPath: "/navigation") {
            Heading("Hello, \(name)!")
            Paragraph("This page came from the route /navigation/greet/:name.")
            Link("← Back to navigation", destination: "/navigation#routes")
        }
    }
}
// end-snippet
