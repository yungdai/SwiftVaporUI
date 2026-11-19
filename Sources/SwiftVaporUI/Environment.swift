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
    /// The values that have been set, by key type.
    private var values: [ObjectIdentifier: any Sendable] = [:]

    /// Creates environment values where every key has its default value.
    public init() {}

    /// Gets or sets the value for `key`.
    public subscript<Key: EnvironmentKey>(key: Key.Type) -> Key.Value {
        get { values[ObjectIdentifier(key)] as? Key.Value ?? Key.defaultValue }
        set { values[ObjectIdentifier(key)] = newValue }
    }

    /// The environment of the view currently being rendered.
    @TaskLocal static var current = EnvironmentValues()
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
    /// The key path of the value to read. Key paths are immutable, so
    /// sharing one across threads is safe.
    private let keyPath: KeyPath<EnvironmentValues, Value>

    /// Creates a property that reads the value at `keyPath`.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    /// The value in the environment of the view being rendered.
    public var wrappedValue: Value {
        EnvironmentValues.current[keyPath: keyPath]
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
    public typealias Body = Never
    /// The key path of the value to read.
    private let keyPath: KeyPath<EnvironmentValues, Value>
    /// Builds the content from the value.
    private let content: (Value) -> Content

    /// Creates a view whose content is built from the value at `keyPath`.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>, @ViewBuilder content: @escaping (Value) -> Content) {
        self.keyPath = keyPath
        self.content = content
    }

    public func _render(into renderer: inout HTMLRenderer) {
        content(EnvironmentValues.current[keyPath: keyPath])._render(into: &renderer)
    }
}

/// A view whose subtree sees a changed environment value.
public struct EnvironmentModifiedView<Content: View, Value: Sendable>: View, @unchecked Sendable {
    public typealias Body = Never
    /// The view that sees the changed value.
    public let content: Content
    /// The key path of the value to change.
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>
    /// The new value.
    private let value: Value

    /// Creates a view whose subtree sees `value` at `keyPath`.
    ///
    /// - Parameters:
    ///   - content: The view that sees the changed value.
    ///   - keyPath: The key path of the value to change.
    ///   - value: The new value.
    init(content: Content, keyPath: WritableKeyPath<EnvironmentValues, Value>, value: Value) {
        self.content = content
        self.keyPath = keyPath
        self.value = value
    }

    public func _render(into renderer: inout HTMLRenderer) {
        var environment = EnvironmentValues.current
        environment[keyPath: keyPath] = value
        EnvironmentValues.$current.withValue(environment) {
            content._render(into: &renderer)
        }
    }
}

extension View {
    /// Sets an environment value for this view and everything inside it.
    ///
    /// ```swift
    /// ProductPage()
    ///     .environment(\.theme, Theme(accent: .purple))
    /// ```
    public func environment<Value: Sendable>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> EnvironmentModifiedView<Self, Value> {
        EnvironmentModifiedView(content: self, keyPath: keyPath, value: value)
    }
}
