/// A key for a value passed down the view tree through ``EnvironmentValues``.
///
/// Declare a key, then a computed property on `EnvironmentValues` so views
/// can use a key path:
///
/// ```swift
/// struct Theme: Sendable {
///     var accent: Color
/// }
///
/// private struct ThemeKey: EnvironmentKey {
///     static let defaultValue = Theme(accent: .blue)
/// }
///
/// extension EnvironmentValues {
///     var theme: Theme {
///         get { self[ThemeKey.self] }
///         set { self[ThemeKey.self] = newValue }
///     }
/// }
/// ```
public protocol EnvironmentKey {

    /// The type of value the key stores.
    associatedtype Value: Sendable

    /// The value views read when no ancestor has set one.
    static var defaultValue: Value { get }

}

/// Values that flow down the view tree, like SwiftUI's environment.
///
/// Set a value for a subtree with ``View/environment(_:_:)`` and read it in
/// any view inside that subtree with ``ViewEnvironment`` or
/// ``EnvironmentReader``. Values are scoped to the render: they do not leak
/// to sibling views or to other requests.
public struct EnvironmentValues: Sendable {

    // MARK: - Static Properties

    /// The environment of the view currently being rendered.
    @TaskLocal static var current = EnvironmentValues()

    // MARK: - Properties

    /// The values that have been set, by key type.
    private var values: [ObjectIdentifier: any Sendable] = [:]

    // MARK: - Initializer

    /// Creates environment values where every key has its default value.
    public init() {}

    // MARK: - Subscripts

    /// Gets or sets the value for `key`.
    /// - Parameter key: The key whose value to get or set.
    public subscript<Key: EnvironmentKey>(key: Key.Type) -> Key.Value {
        get {
            // Look the key up first: casting a missing entry to an optional
            // value type would succeed with `nil` and skip the default.
            guard let stored = values[ObjectIdentifier(key)], let value = stored as? Key.Value else {
                return Key.defaultValue
            }
            return value
        }
        set { values[ObjectIdentifier(key)] = newValue }
    }

}

/// Reads a value from the environment inside a view's `body`.
///
/// It is named `ViewEnvironment` rather than `Environment` so it does not
/// clash with Vapor's `Environment` (development, production, ...).
///
/// ```swift
/// struct AccentHeading: View {
///     @ViewEnvironment(\.theme) var theme
///     let text: String
///
///     var body: some View {
///         Heading(text, level: .h2).foregroundColor(theme.accent)
///     }
/// }
/// ```
@propertyWrapper
public struct ViewEnvironment<Value>: @unchecked Sendable {

    // MARK: - Properties

    /// The key path of the value to read. Key paths are immutable, so
    /// sharing one across threads is safe.
    private let keyPath: KeyPath<EnvironmentValues, Value>

    // MARK: - Computed Properties

    /// The value in the environment of the view being rendered.
    public var wrappedValue: Value {
        EnvironmentValues.current[keyPath: keyPath]
    }

    // MARK: - Initializer

    /// Creates a property that reads the value at `keyPath`.
    /// - Parameter keyPath: The key path of the environment value to read.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

}

/// Builds content from an environment value, without declaring a view type.
///
/// ```swift
/// EnvironmentReader(\.theme) { theme in
///     Paragraph("Accent: \(theme.accent.css)")
/// }
/// ```
public struct EnvironmentReader<Value, Content: View>: View, @unchecked Sendable {

    // MARK: - Properties

    /// The key path of the value to read.
    private let keyPath: KeyPath<EnvironmentValues, Value>

    /// Builds the content from the value.
    private let content: @Sendable (Value) -> Content

    // MARK: - Initializer

    /// Creates a view whose content is built from the value at `keyPath`.
    /// - Parameters:
    ///   - keyPath: The key path of the environment value to read.
    ///   - content: A view builder that creates the content from the value.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>, @ViewBuilder content: @escaping @Sendable (Value) -> Content) {
        self.keyPath = keyPath
        self.content = content
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        content(EnvironmentValues.current[keyPath: keyPath])._render(into: &renderer)
    }

}

/// A view whose subtree sees a changed environment value.
public struct EnvironmentModifiedView<Content: View, Value: Sendable>: View, @unchecked Sendable {

    // MARK: - Properties

    /// The view that sees the changed value.
    public let content: Content

    /// The key path of the value to change.
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>

    /// The new value.
    private let value: Value

    // MARK: - Initializer

    /// Creates a view whose subtree sees `value` at `keyPath`.
    /// - Parameters:
    ///   - content: The view that sees the changed value.
    ///   - keyPath: The key path of the value to change.
    ///   - value: The new value.
    init(content: Content, keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.content = content
        self.keyPath = keyPath
        self.value = value
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        var environment = EnvironmentValues.current
        environment[keyPath: keyPath] = value
        EnvironmentValues.$current.withValue(environment) {
            content._render(into: &renderer)
        }
    }

}

/// The environment modifier.
extension View {

    /// Sets an environment value for this view and everything inside it.
    ///
    /// ```swift
    /// ProductPage()
    ///     .environment(\.theme, Theme(accent: .purple))
    /// ```
    /// - Parameters:
    ///   - keyPath: The key path of the environment value to set.
    ///   - value: The value to set.
    /// - Returns: A view with the change applied.
    public func environment<Value: Sendable>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> EnvironmentModifiedView<Self, Value> {
        EnvironmentModifiedView(content: self, keyPath: keyPath, value: value)
    }

}
