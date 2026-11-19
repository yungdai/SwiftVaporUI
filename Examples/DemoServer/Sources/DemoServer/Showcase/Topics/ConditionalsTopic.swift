import SwiftVaporUI

// snippet: if
/// Someone visiting the site, who may be signed in.
struct Visitor: Sendable {

    /// The visitor's name, if they are signed in.
    var name: String?

    /// How many unread messages they have.
    var unread: Int
}
// end-snippet

// snippet: switch
/// How wet a plant's soil is.
enum SoilMoisture: Sendable, CaseIterable {

    /// The soil needs water.
    case dry

    /// The soil is just right.
    case moist

    /// The soil is too wet.
    case soaked
}

/// A soil reading, with advice that depends on it.
struct MoistureReading: View {

    // MARK: - Properties

    /// The reading to show.
    let moisture: SoilMoisture

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        switch moisture {
        case .dry:
            Paragraph("Dry: water today.").class("warning")
        case .moist:
            Paragraph("Moist: all good.").class("notice")
        case .soaked:
            Paragraph {
                Strong("Soaked: ")
                "skip the next watering."
            }
        }
    }
}
// end-snippet

/// The "Conditionals" showcase page.
enum ConditionalsTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "conditionals",
        title: "Conditionals",
        tagline: "if, if let, switch and conditional attributes.",
        intro: [
            "View builders understand Swift's control flow. An if without an else renders nothing when the condition is false, if/else and switch pick one branch, and if let unwraps optionals.",
            "Only the chosen branch is rendered, so there is no hidden markup to leak. For content that should stay in the page but be invisible, use .hidden().",
        ],
        examples: [
            Example(
                "if",
                title: "if and if/else",
                summary: "Change the visitor in the snippet and run again to see the other branches. if let unwraps the optional name."
            ) {
                // snippet: if
                let visitor = Visitor(name: "Sam", unread: 2)   // try name: nil, unread: 0

                if let name = visitor.name {
                    Paragraph("Welcome back, \(name)!")
                } else {
                    Link("Sign in", destination: "/login")
                }

                if visitor.unread > 0 {
                    Paragraph("You have \(visitor.unread) new messages.").class("notice")
                }
                // end-snippet
            },

            Example(
                "if-let",
                title: "if let",
                summary: "Unwrap an optional and use the value. Here one plant has a nickname and one does not."
            ) {
                // snippet: if-let
                let nicknames: [String: String] = ["Monstera": "Swiss cheese plant"]

                ForEach(["Monstera", "Pothos"]) { plant in
                    Paragraph {
                        Strong(plant)
                        if let nickname = nicknames[plant] {
                            " also known as "
                            Emphasis(nickname)
                        } else {
                            Small(" (no nickname)").class("muted")
                        }
                    }
                }
                // end-snippet
            },

            Example(
                "switch",
                title: "switch",
                summary: "Switch over an enum, inside a custom view, to render one of several layouts."
            ) {
                // snippet: switch
                ForEach(SoilMoisture.allCases) { reading in
                    MoistureReading(moisture: reading)
                }
                // end-snippet
            },

            Example(
                "conditional-attributes",
                title: "Conditional attributes",
                summary: "Use .class(_:when:) and the Bool parameters of .disabled, .hidden and .required to toggle attributes without branching."
            ) {
                // snippet: conditional-attributes
                let canWater = false
                let showTip = false

                HStack {
                    Button("Water", action: .plain)
                        .class("button")
                        .disabled(!canWater)
                    Span("Out of water")
                        .class("badge")
                        .class("badge-orange", when: !canWater)
                        .hidden(canWater)
                }
                Paragraph("Tip: water in the morning.").hidden(!showTip)
                // end-snippet
            },

            Example(
                "ternary",
                title: "Inline choices",
                summary: "For a small piece of text, a ternary expression reads well. Both sides must have the same type, such as String."
            ) {
                // snippet: ternary
                let count = 1

                Paragraph {
                    Strong("\(count)")
                    count == 1 ? " plant needs" : " plants need"
                    " repotting."
                }
                // end-snippet
            },
        ]
    )
}
