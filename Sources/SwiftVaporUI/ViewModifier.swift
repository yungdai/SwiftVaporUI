/// A reusable bundle of modifiers and wrapping views, like SwiftUI's
/// `ViewModifier`.
///
/// ```swift
/// struct CardStyle: ViewModifier {
///     var highlighted = false
///
///     func body(content: Self.Content) -> some View {
///         Div { content }
///             .class("card")
///             .border(highlighted ? .orange : .gray)
///             .cornerRadius(8)
///     }
/// }
///
/// Paragraph("Fresh today").modifier(CardStyle(highlighted: true))
/// ```
///
/// Write `Self.Content` (or `ViewModifierContent`), not plain `Content`:
/// Vapor's `Content` protocol is also in scope, and Swift picks that one.
///
/// Add an extension on `View` to make a modifier read like a built-in one:
///
/// ```swift
/// extension View {
///     func cardStyle(highlighted: Bool = false) -> some View {
///         modifier(CardStyle(highlighted: highlighted))
///     }
/// }
/// ```
public protocol ViewModifier: Sendable {

    /// The type of view the modifier produces.
    associatedtype Body: View

    /// The view the modifier is applied to. Refer to it as `Self.Content`,
    /// because a bare `Content` means Vapor's `Content` protocol.
    typealias Content = ViewModifierContent

    /// Builds the modified view from `content`.
    /// - Parameter content: The view the modifier is applied to.
    /// - Returns: The modified view.
    @ViewBuilder func body(content: Content) -> Body
}

/// The view a ``ViewModifier`` is applied to, passed to its
/// `body(content:)`.
public struct ViewModifierContent: View {

    // MARK: - Properties

    /// The view the modifier is applied to.
    let view: AnyView

    // MARK: - Initializer

    /// Wraps the view a modifier is applied to.
    /// - Parameter view: The view, type-erased.
    init(_ view: AnyView) {
        self.view = view
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        view._render(into: &renderer)
    }
}

/// A view with a ``ViewModifier`` applied.
public struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {

    // MARK: - Properties

    /// The original view.
    public let content: Content

    /// The modifier applied to it.
    public let modifier: Modifier

    // MARK: - Initializer

    /// Applies `modifier` to `content`.
    /// - Parameters:
    ///   - content: The original view.
    ///   - modifier: The modifier applied to it.
    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Modifier.Body {
        modifier.body(content: ViewModifierContent(AnyView(content)))
    }
}

/// Applying a custom modifier.
extension View {

    /// Applies a ``ViewModifier``.
    /// - Parameter modifier: The modifier to apply.
    /// - Returns: A view with the change applied.
    public func modifier<Modifier: ViewModifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> {
        ModifiedContent(content: self, modifier: modifier)
    }
}
