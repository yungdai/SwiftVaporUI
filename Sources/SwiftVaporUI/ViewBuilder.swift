/// Builds views from closures, supporting `if`/`else`, `switch`,
/// `if let`, `for` loops and bare string literals (rendered as `Text`).
@resultBuilder
public enum ViewBuilder {
    /// Passes a view through unchanged.
    public static func buildExpression<Content: View>(_ content: Content) -> Content {
        content
    }

    /// Turns a string literal or expression into escaped `Text`.
    public static func buildExpression(_ string: String) -> Text {
        Text(string)
    }

    /// Builds an empty block.
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    /// Builds the first view of a block.
    public static func buildPartialBlock<Content: View>(first content: Content) -> Content {
        content
    }

    /// Adds the next view of a block to the views before it.
    public static func buildPartialBlock<Accumulated: View, Next: View>(
        accumulated: Accumulated,
        next: Next
    ) -> TupleView<Accumulated, Next> {
        TupleView(accumulated, next)
    }

    /// Builds an `if` without an `else`.
    public static func buildOptional<Content: View>(_ content: Content?) -> OptionalView<Content> {
        OptionalView(content)
    }

    /// Builds the first branch of an `if`/`else` or `switch`.
    public static func buildEither<TrueContent: View, FalseContent: View>(
        first: TrueContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        ConditionalView(storage: .first(first))
    }

    /// Builds the second branch of an `if`/`else` or `switch`.
    public static func buildEither<TrueContent: View, FalseContent: View>(
        second: FalseContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        ConditionalView(storage: .second(second))
    }

    /// Builds a `for` loop.
    public static func buildArray<Content: View>(_ components: [Content]) -> ForEach<Content> {
        ForEach(views: components)
    }

    /// Builds an `if #available` block.
    public static func buildLimitedAvailability<Content: View>(_ content: Content) -> AnyView {
        AnyView(content)
    }
}

/// Sibling views produced by a `ViewBuilder` block. Longer blocks nest:
/// `TupleView<TupleView<A, B>, C>`.
public struct TupleView<First: View, Second: View>: View {
    public typealias Body = Never
    /// The first view.
    public let first: First
    /// The second view.
    public let second: Second

    /// Creates a pair of sibling views.
    public init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    public func _render(into renderer: inout HTMLRenderer) {
        first._render(into: &renderer)
        second._render(into: &renderer)
    }
}

/// The result of an `if` without an `else` in a `ViewBuilder`.
public struct OptionalView<Wrapped: View>: View {
    public typealias Body = Never
    /// The view to render, or `nil` to render nothing.
    public let wrapped: Wrapped?

    /// Wraps an optional view.
    public init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }

    public func _render(into renderer: inout HTMLRenderer) {
        wrapped?._render(into: &renderer)
    }
}

/// The result of an `if`/`else` or `switch` in a `ViewBuilder`.
public struct ConditionalView<TrueContent: View, FalseContent: View>: View {
    public typealias Body = Never

    /// Which branch was taken.
    enum Storage: Sendable {
        /// The `if` branch, or the first `switch` case.
        case first(TrueContent)
        /// The `else` branch, or a later `switch` case.
        case second(FalseContent)
    }

    /// The branch that was taken, with its view.
    let storage: Storage

    public func _render(into renderer: inout HTMLRenderer) {
        switch storage {
        case let .first(view): view._render(into: &renderer)
        case let .second(view): view._render(into: &renderer)
        }
    }
}
