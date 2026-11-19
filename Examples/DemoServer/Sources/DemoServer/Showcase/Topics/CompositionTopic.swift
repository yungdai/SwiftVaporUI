import SwiftVaporUI

// snippet: view-modifier
/// Draws content as a card, optionally highlighted.
struct CardStyle: ViewModifier {

    // MARK: - Properties

    /// Whether to draw the card with an accent border.
    var isHighlighted = false

    // MARK: - ViewModifier

    /// Wraps the content in a padded, rounded, shadowed box.
    /// - Parameter content: The view the modifier is applied to.
    /// - Returns: The content inside a card.
    func body(content: Self.Content) -> some View {
        Div { content }
            .padding(14)
            .background(.white)
            .border(isHighlighted ? .hex("e8590c") : .hex("e2e5eb"), width: isHighlighted ? 2 : 1)
            .cornerRadius(12)
            .shadow(color: .rgb(20, 24, 43, opacity: 0.08), radius: 12, y: 4)
    }

}

/// The card modifier, written like a built-in one.
extension View {

    /// Draws the view as a card.
    /// - Parameter isHighlighted: Whether to draw the card with an accent border.
    /// - Returns: The view inside a card.
    func cardStyle(highlighted isHighlighted: Bool = false) -> some View {
        modifier(CardStyle(isHighlighted: isHighlighted))
    }

}
// end-snippet

// snippet: environment
/// Colours that a page passes down to every view inside it.
struct ShowcaseTheme: Sendable {

    /// The accent colour for headings and highlights.
    var accent: Color

    /// The colour of quiet, secondary text.
    var muted: Color

}

/// The environment key for `ShowcaseTheme`.
private struct ShowcaseThemeKey: EnvironmentKey {

    /// The theme views see when nobody has set one.
    static let defaultValue = ShowcaseTheme(accent: .hex("e8590c"), muted: .gray)

}

/// The `theme` environment value.
extension EnvironmentValues {

    /// The theme for this part of the page.
    var theme: ShowcaseTheme {
        get { self[ShowcaseThemeKey.self] }
        set { self[ShowcaseThemeKey.self] = newValue }
    }

}

/// A heading in the theme's accent colour, with a caption under it.
struct ThemedTitle: View {

    // MARK: - Properties

    /// The theme from the environment.
    @ViewEnvironment(\.theme) var theme

    /// The heading text.
    let title: String

    /// The caption under the heading.
    let caption: String

    // MARK: - View

    /// A heading and a muted caption.
    var body: some View {
        VStack(spacing: 2) {
            Heading(title, level: .h4).foregroundColor(theme.accent).style("margin", "0")
            Small(caption).foregroundColor(theme.muted)
        }
    }

}
// end-snippet

// snippet: any-view
/// A notice that is a different kind of view depending on its level.
/// - Parameter level: How serious the notice is: `info`, `warning` or anything else.
/// - Returns: The notice, type-erased so every branch has the same type.
func notice(level: String) -> AnyView {
    switch level {
    case "info":
        AnyView(Paragraph("Stalls open at six.").class("notice"))
    case "warning":
        AnyView(Div { Strong("Heads up: "); "the bridge is closed." }.class("warning"))
    default:
        AnyView(Small("Nothing to report.").class("muted"))
    }
}
// end-snippet

/// The "Modifiers, AnyView and environment" showcase page.
enum CompositionTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "composition",
        title: "Modifiers and environment",
        tagline: "Your own ViewModifiers, AnyView, and values passed down the tree.",
        intro: [
            "A ViewModifier bundles modifiers and wrapping views into one reusable piece, applied with .modifier(_:) or your own extension method.",
            "The environment passes a value, such as a theme, to every view inside a subtree without threading it through each initializer. Set it with .environment(_:_:) and read it with @ViewEnvironment or EnvironmentReader.",
        ],
        examples: [
            Example(
                "view-modifier",
                title: "A custom ViewModifier",
                summary: "CardStyle is defined once and reused. Inside body(content:), write Self.Content: a bare Content would mean Vapor's Content protocol."
            ) {
                // snippet: view-modifier
                HStack(alignment: .top, spacing: 12) {
                    Paragraph("Dumpling House").cardStyle()
                    Paragraph("Lantern Tea, new tonight").cardStyle(highlighted: true)
                    Paragraph("Fixed via .modifier").modifier(CardStyle())
                }
                // end-snippet
            },

            Example(
                "environment",
                title: "Passing a theme down the tree",
                summary: "ThemedTitle reads the theme with @ViewEnvironment. Each .environment call changes it for that subtree only; siblings keep the default."
            ) {
                // snippet: environment
                VStack(spacing: 12) {
                    ThemedTitle(title: "Default theme", caption: "No one set a theme here.")

                    VStack(spacing: 12) {
                        ThemedTitle(title: "River theme", caption: "Set on this group.")
                        EnvironmentReader(\.theme) { theme in
                            Small("EnvironmentReader sees \(theme.accent.css) too.")
                        }
                    }
                    .environment(\.theme, ShowcaseTheme(accent: .hex("1b5f93"), muted: .hex("5b6474")))

                    ThemedTitle(title: "Back to default", caption: "The change did not leak out.")
                }
                // end-snippet
            },

            Example(
                "any-view",
                title: "AnyView",
                summary: "AnyView erases a view's type, so a function or array can hold different kinds of views. Prefer @ViewBuilder where you can; reach for AnyView when you must store views."
            ) {
                // snippet: any-view
                VStack(spacing: 8) {
                    ForEach(["info", "warning", "none"]) { level in
                        notice(level: level)
                    }
                }
                // end-snippet
            },
        ]
    )

}
