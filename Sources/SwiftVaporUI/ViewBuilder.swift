/// Builds views from closures, supporting `if`/`else`, `switch`,
/// `if let`, `for` loops and bare string literals (rendered as `Text`).
@resultBuilder
public enum ViewBuilder {

    // MARK: - Methods

    /// Passes a view through unchanged.
    ///
    /// - Parameter content: The view to pass through.
    /// - Returns: The view to place in the block.
    public static func buildExpression<Content: View>(_ content: Content) -> Content {
        content
    }

    /// Turns a string literal or expression into escaped `Text`.
    ///
    /// - Parameter string: The string to show.
    /// - Returns: The view to place in the block.
    public static func buildExpression(_ string: String) -> Text {
        Text(string)
    }

    /// Builds an empty block.
    ///
    /// - Returns: An empty view.
    public static func buildBlock() -> EmptyView {
        EmptyView()
    }

    /// Builds the first view of a block.
    ///
    /// - Parameter content: The view to pass through.
    /// - Returns: The views of the block so far.
    public static func buildPartialBlock<Content: View>(first content: Content) -> Content {
        content
    }

    /// Adds the next view of a block to the views before it.
    ///
    /// - Parameters:
    ///   - accumulated: The views built so far.
    ///   - next: The next view in the block.
    /// - Returns: The views of the block so far.
    public static func buildPartialBlock<Accumulated: View, Next: View>(
        accumulated: Accumulated,
        next: Next
    ) -> TupleView<Accumulated, Next> {
        TupleView(accumulated, next)
    }

    /// Builds an `if` without an `else`.
    ///
    /// - Parameter content: The view to pass through.
    /// - Returns: A view that renders the content if there is any.
    public static func buildOptional<Content: View>(_ content: Content?) -> OptionalView<Content> {
        OptionalView(content)
    }

    /// Builds the first branch of an `if`/`else` or `switch`.
    ///
    /// - Parameter first: The view built by the first branch.
    /// - Returns: A view that renders the chosen branch.
    public static func buildEither<TrueContent: View, FalseContent: View>(
        first: TrueContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        ConditionalView(storage: .first(first))
    }

    /// Builds the second branch of an `if`/`else` or `switch`.
    ///
    /// - Parameter second: The view built by the second branch.
    /// - Returns: A view that renders the chosen branch.
    public static func buildEither<TrueContent: View, FalseContent: View>(
        second: FalseContent
    ) -> ConditionalView<TrueContent, FalseContent> {
        ConditionalView(storage: .second(second))
    }

    /// Builds a `for` loop.
    ///
    /// - Parameter components: The views built by each pass of the loop.
    /// - Returns: A view that renders each view in order.
    public static func buildArray<Content: View>(_ components: [Content]) -> ForEach<Content> {
        ForEach(views: components)
    }

    /// Builds an `if #available` block.
    ///
    /// - Parameter content: The view to pass through.
    /// - Returns: The content, type-erased.
    public static func buildLimitedAvailability<Content: View>(_ content: Content) -> AnyView {
        AnyView(content)
    }

}

/// Sibling views produced by a `ViewBuilder` block. Longer blocks nest:
/// `TupleView<TupleView<A, B>, C>`.
public struct TupleView<First: View, Second: View>: View {

    // MARK: - Properties

    /// The first view.
    public let first: First

    /// The second view.
    public let second: Second

    // MARK: - Initializers

    /// Creates a pair of sibling views.
    ///
    /// - Parameters:
    ///   - first: The first view.
    ///   - second: The second view.
    public init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    ///
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        first._render(into: &renderer)
        second._render(into: &renderer)
    }

}

/// The result of an `if` without an `else` in a `ViewBuilder`.
public struct OptionalView<Wrapped: View>: View {

    // MARK: - Properties

    /// The view to render, or `nil` to render nothing.
    public let wrapped: Wrapped?

    // MARK: - Initializers

    /// Wraps an optional view.
    ///
    /// - Parameter wrapped: The view to render, or `nil` to render nothing.
    public init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    ///
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        wrapped?._render(into: &renderer)
    }

}

/// The result of an `if`/`else` or `switch` in a `ViewBuilder`.
public struct ConditionalView<TrueContent: View, FalseContent: View>: View {

    // MARK: - Nested Types

    /// Which branch was taken.
    enum Storage: Sendable {
        /// The `if` branch, or the first `switch` case.
        case first(TrueContent)
        /// The `else` branch, or a later `switch` case.
        case second(FalseContent)
    }

    // MARK: - Properties

    /// The branch that was taken, with its view.
    let storage: Storage

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    ///
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        switch storage {
        case let .first(view): view._render(into: &renderer)
        case let .second(view): view._render(into: &renderer)
        }
    }

}
