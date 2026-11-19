import SwiftVaporUI

/// The "Custom views" showcase page.
enum ComponentsTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "components",
        title: "Custom views",
        tagline: "Compose your own reusable components.",
        intro: [
            "The real power of the DSL is composition. Any struct that conforms to View and has a body is a component you can reuse, give properties, fill with content and style with modifiers, exactly like a SwiftUI view.",
        ],
        examples: [
            Example(
                "properties",
                title: "A view with properties",
                summary: "Properties are the component's inputs. Here a stat tile takes a label, a value and an optional trend."
            ) {
                // snippet: properties
                HStack(spacing: 12) {
                    StatTile(label: "Plants", value: "24")
                    StatTile(label: "Watered today", value: "9", trend: "+3")
                    StatTile(label: "Overdue", value: "2", trend: "-1")
                }
                // end-snippet
            },

            Example(
                "content",
                title: "Taking content with @ViewBuilder",
                summary: "Accept a @ViewBuilder closure to let callers put any views inside, like SwiftUI containers. A second builder makes an optional footer."
            ) {
                // snippet: content
                Panel(title: "Repotting checklist") {
                    UnorderedList {
                        ListItem("Pick a pot 2–5 cm wider")
                        ListItem("Loosen the roots")
                        ListItem("Water well afterwards")
                    }
                } footer: {
                    Small("Best done in spring.").class("muted")
                }
                // end-snippet
            },

            Example(
                "modifiers",
                title: "Modifiers on your own views",
                summary: "Modifiers on a custom view reach the first element it renders, so components can be styled from outside without extra parameters."
            ) {
                // snippet: modifiers
                Panel(title: "Highlighted panel") {
                    Paragraph("This panel got a background and an id from its caller.")
                }
                .background(.hex("fff1e8"))
                .id("featured-panel")
                // end-snippet
            },

            Example(
                "composition",
                title: "Components built from components",
                summary: "Small views combine into bigger ones. PlantSummary uses Panel, StatusBadge and a description list."
            ) {
                // snippet: composition
                HStack(alignment: .top, spacing: 12) {
                    PlantSummary(name: "Calathea", status: .thirsty, lastWatered: "5 days ago")
                    PlantSummary(name: "Jade plant", status: .happy, lastWatered: "Yesterday")
                }
                // end-snippet
            },

            Example(
                "fragments",
                title: "Fragments for partial updates",
                summary: "A component does not need a full document. Return one from a route on its own and it is sent as an HTML fragment, ready for htmx-style partial page updates."
            ) {
                // snippet: fragments
                StatTile(label: "Fragments rendered", value: "1")
                // end-snippet
            },
        ]
    )
}

// snippet: properties
/// A number with a label and an optional trend.
struct StatTile: View {

    // MARK: - Properties

    /// What the number measures.
    let label: String

    /// The number.
    let value: String

    /// An optional note on the trend, such as `+3 this week`.
    var trend: String? = nil

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        VStack(spacing: 2) {
            Small(label).class("muted")
            Strong(value).font(.title2)
            if let trend {
                Small(trend)
                    .foregroundColor(trend.hasPrefix("-") ? .red : .green)
            }
        }
        .class("card")
        .frame(width: 140)
    }
}
// end-snippet

// snippet: content
/// A titled panel with a body and an optional footer.
struct Panel<Content: View, FooterContent: View>: View {

    // MARK: - Properties

    /// The panel's heading.
    let title: String

    /// The panel's body.
    let content: Content

    /// The panel's footer.
    let footer: FooterContent

    // MARK: - Initializer

    /// Creates a panel with a footer.
    /// - Parameters:
    ///   - title: The panel's heading.
    ///   - content: A view builder that creates the panel's body.
    ///   - footer: A view builder that creates the panel's footer.
    init(
        title: String,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> FooterContent
    ) {
        self.title = title
        self.content = content()
        self.footer = footer()
    }

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Article {
            Heading(title, level: .h3)
            content
            footer
        }
        .class("card")
    }
}

/// Initializers for an element with no content.
extension Panel where FooterContent == EmptyView {

    /// Creates a panel with no footer.
    /// - Parameters:
    ///   - title: The panel's heading.
    ///   - content: A view builder that creates the panel's body.
    init(title: String, @ViewBuilder content: () -> Content) {
        self.init(title: title, content: content, footer: { EmptyView() })
    }
}
// end-snippet

// snippet: composition
/// How a plant is doing.
enum PlantStatus: Sendable {

    /// The plant is doing well.
    case happy

    /// The plant needs water.
    case thirsty

    /// The status as shown to people.
    var label: String { self == .happy ? "Happy" : "Thirsty" }

    /// The CSS class for the status badge.
    var badgeClass: String { self == .happy ? "badge-green" : "badge-orange" }
}

/// A coloured badge for a plant's status.
struct StatusBadge: View {

    // MARK: - Properties

    /// The plant's status.
    let status: PlantStatus

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Span(status.label).class("badge", status.badgeClass)
    }
}

/// A plant's name, status and when it was last watered.
struct PlantSummary: View {

    // MARK: - Properties

    /// The plant's name.
    let name: String

    /// The plant's status.
    let status: PlantStatus

    /// When it was last watered.
    let lastWatered: String

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Panel(title: name) {
            StatusBadge(status: status)
            DescriptionList {
                DescriptionTerm("Last watered")
                DescriptionDetail(lastWatered)
            }
        }
    }
}
// end-snippet

// snippet: fragments
// In main.swift:
/// Registers the fragment routes the component examples load.
/// - Parameter app: The application to add the routes to.
func registerComponentRoutes(_ app: Application) {
    app.get("fragments", "stat") { _ in
        StatTile(label: "Fragments rendered", value: "1")
    }
}
// end-snippet
