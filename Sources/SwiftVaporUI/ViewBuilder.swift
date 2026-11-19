/// Builds views from closures, supporting `if`/`else`, `switch`,
/// `if let`, `for` loops and bare string literals (rendered as `Text`).
@resultBuilder
public enum ViewBuilder {
    public static func buildExpression<Content: View>(_ content: Content) -> Content {
        content
    }

    public static func buildExpression(_ string: String) -> Text {
        Text(string)
    }

    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    public static func buildPartialBlock<Content: View>(first content: Content) -> Content {
        content
    }

    public static func buildPartialBlock<Accumulated: View, Next: View>(
        accumulated: Accumulated,
        next: Next
    ) -> TupleView<Accumulated, Next> {
        TupleView(accumulated, next)
    }

    public static func buildOptional<Content: View>(_ content: Content?) -> OptionalView<Content> {
        OptionalView(content)
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        first: TrueContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        ConditionalView(storage: .first(first))
    }

    public static func buildEither<TrueContent: View, FalseContent: View>(
        second: FalseContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        ConditionalView(storage: .second(second))
    }

    public static func buildArray<Content: View>(_ components: [Content]) -> ForEach<Content> {
        ForEach(views: components)
    }

    public static func buildLimitedAvailability<Content: View>(_ content: Content) -> AnyView {
        AnyView(content)
    }
}

/// Sibling views produced by a `ViewBuilder` block. Longer blocks nest:
/// `TupleView<TupleView<A, B>, C>`.
public struct TupleView<First: View, Second: View>: View {
    public typealias Body = Never
    public let first: First
    public let second: Second

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
    public let wrapped: Wrapped?

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

    enum Storage: Sendable {
        case first(TrueContent)
        case second(FalseContent)
    }

    let storage: Storage

    public func _render(into renderer: inout HTMLRenderer) {
        switch storage {
        case let .first(view): view._render(into: &renderer)
        case let .second(view): view._render(into: &renderer)
        }
    }
}
