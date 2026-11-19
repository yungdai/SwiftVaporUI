/// A view that renders nothing.
public struct EmptyView: View {

    // MARK: - Initializer

    /// Creates a view that renders nothing.
    public init() {}

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {}

}

/// Plain text. The string is HTML-escaped when rendered.
///
/// Text has no tag of its own. If you apply an attribute modifier to it, it
/// is wrapped in a `<span>` to carry the attributes.
public struct Text: View {

    // MARK: - Properties

    /// The unescaped text.
    public let content: String

    // MARK: - Initializers

    /// Creates text from a string. It is escaped when rendered.
    /// - Parameter content: The unescaped text.
    public init(_ content: String) {
        self.content = content
    }

    /// Creates text from any value's `description`, such as a number.
    /// - Parameter value: The value whose `description` is shown.
    public init<S: CustomStringConvertible>(_ value: S) {
        self.content = value.description
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        if renderer.pending.isEmpty {
            renderer.writeEscapedText(content)
        } else {
            Element("span", wrapping: Text(content))._render(into: &renderer)
        }
    }

}

/// HTML that is written to the output exactly as given, with no escaping.
///
/// Only use this with markup you trust. Attribute modifiers have no effect on
/// raw HTML, and are passed on to the next element instead.
public struct RawHTML: View {

    // MARK: - Properties

    /// The markup, written without escaping.
    public let html: String

    // MARK: - Initializer

    /// Creates raw HTML. Only pass markup you trust.
    /// - Parameter html: The markup, written without escaping.
    public init(_ html: String) {
        self.html = html
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        renderer.write(html)
    }

}

/// A type-erased view.
public struct AnyView: View {

    // MARK: - Properties

    /// The wrapped view.
    let view: any View

    // MARK: - Initializer

    /// Wraps `view`, hiding its type.
    /// - Parameter view: The view to wrap.
    public init<Content: View>(_ view: Content) {
        if let erased = view as? AnyView {
            self = erased
        } else {
            self.view = view
        }
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

/// Groups views without adding an element around them.
public struct Group<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates the element with the content built by `content`.
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Content { content }

}

/// Renders a view for each element of a sequence.
///
/// ```swift
/// UnorderedList {
///     ForEach(items) { item in
///         ListItem(item.name)
///     }
/// }
/// ```
public struct ForEach<Content: View>: View {

    // MARK: - Properties

    /// The rendered views, one per element.
    public let views: [Content]

    // MARK: - Initializers

    /// Creates one view, built by `content`, for each element of `data`.
    /// - Parameters:
    ///   - data: The elements to render a view for.
    ///   - content: A view builder that creates the view for one element.
    public init<Data: Sequence>(_ data: Data, @ViewBuilder content: (Data.Element) throws -> Content) rethrows {
        self.views = try data.map(content)
    }

    /// Creates a view that renders `views` in order.
    /// - Parameter views: The views to render.
    init(views: [Content]) {
        self.views = views
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        for view in views {
            view._render(into: &renderer)
        }
    }

}

/// Any HTML element with an opening and closing tag.
///
/// The library's named elements (`Div`, `Paragraph`, ...) are built on this.
/// Use it directly for tags the library does not cover:
///
/// ```swift
/// Element("time", attributes: ["datetime": "2026-11-19"]) { "Today" }
/// ```
///
/// A tag name that is not a valid HTML name renders its content with no
/// element around it.
public struct Element<Content: View>: View {

    // MARK: - Properties

    /// The tag name, such as `"time"`.
    public let tag: String

    /// The element's own attributes. Modifiers add to these.
    public let attributes: HTMLAttributes

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates an element with the given tag, attributes and content.
    /// - Parameters:
    ///   - tag: The tag name, such as `"time"`.
    ///   - attributes: The element's own attributes. Modifiers add to these.
    ///   - content: The element's content.
    public init(_ tag: String, attributes: HTMLAttributes = [:], @ViewBuilder content: () -> Content) {
        self.init(tag, attributes: attributes, wrapping: content())
    }

    /// Creates an element that wraps an existing view.
    /// - Parameters:
    ///   - tag: The tag name, such as `"time"`.
    ///   - attributes: The element's own attributes. Modifiers add to these.
    ///   - content: The element's content.
    public init(_ tag: String, attributes: HTMLAttributes = [:], wrapping content: Content) {
        self.tag = tag
        self.attributes = attributes
        self.content = content
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        guard HTMLEscaping.isValidTagName(tag) else {
            content._render(into: &renderer)
            return
        }
        var attributes = attributes
        renderer.takePending(applyingTo: &attributes)
        renderer.writeOpeningTag(tag, attributes: attributes)
        content._render(into: &renderer)
        renderer.write("</\(tag)>")
    }

}

/// Initializers for an element with no content.
extension Element where Content == EmptyView {

    /// Creates an element with no content, such as `<div></div>`.
    /// - Parameters:
    ///   - tag: The tag name, such as `"time"`.
    ///   - attributes: The element's own attributes. Modifiers add to these.
    public init(_ tag: String, attributes: HTMLAttributes = [:]) {
        self.init(tag, attributes: attributes, wrapping: EmptyView())
    }

}

/// An HTML element with no content and no closing tag, such as `<img>`.
public struct VoidElement: View {

    // MARK: - Properties

    /// The tag name, such as `"wbr"`.
    public let tag: String

    /// The element's own attributes. Modifiers add to these.
    public let attributes: HTMLAttributes

    // MARK: - Initializer

    /// Creates a void element with the given tag and attributes.
    /// - Parameters:
    ///   - tag: The tag name, such as `"wbr"`.
    ///   - attributes: The element's own attributes. Modifiers add to these.
    public init(_ tag: String, attributes: HTMLAttributes = [:]) {
        self.tag = tag
        self.attributes = attributes
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        guard HTMLEscaping.isValidTagName(tag) else {
            renderer.pending.removeAll()
            return
        }
        var attributes = attributes
        renderer.takePending(applyingTo: &attributes)
        renderer.writeOpeningTag(tag, attributes: attributes)
    }

}
