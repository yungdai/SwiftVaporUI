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
    @ViewBuilder func body(content: Content) -> Body
}

/// The view a ``ViewModifier`` is applied to, passed to its
/// `body(content:)`.
public struct ViewModifierContent: View {
    public typealias Body = Never
    /// The view the modifier is applied to.
    let view: AnyView

    /// Wraps the view a modifier is applied to.
    ///
    /// - Parameter view: The view, type-erased.
    init(_ view: AnyView) {
        self.view = view
    }

    public func _render(into renderer: inout HTMLRenderer) {
        view._render(into: &renderer)
    }
}

/// A view with a ``ViewModifier`` applied.
public struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {
    /// The original view.
    public let content: Content
    /// The modifier applied to it.
    public let modifier: Modifier

    /// Applies `modifier` to `content`.
    public init(content: Content, modifier: Modifier) {
        self.content = content
        self.modifier = modifier
    }

    public var body: Modifier.Body {
        modifier.body(content: ViewModifierContent(AnyView(content)))
    }
}

extension View {
    /// Applies a ``ViewModifier``.
    public func modifier<Modifier: ViewModifier>(_ modifier: Modifier) -> ModifiedContent<Self, Modifier> {
        ModifiedContent(content: self, modifier: modifier)
    }
}
