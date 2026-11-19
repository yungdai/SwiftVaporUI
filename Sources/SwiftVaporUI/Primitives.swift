/// A view that renders nothing.
public struct EmptyView: View {
    public typealias Body = Never

    public init() {}

    public func _render(into renderer: inout HTMLRenderer) {}
}

/// Plain text. The string is HTML-escaped when rendered.
///
/// Text has no tag of its own. If you apply an attribute modifier to it, it
/// is wrapped in a `<span>` to carry the attributes.
public struct Text: View {
    public typealias Body = Never
    public let content: String

    public init(_ content: String) {
        self.content = content
    }

    public init<S: CustomStringConvertible>(_ value: S) {
        self.content = value.description
    }

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
    public typealias Body = Never
    public let html: String

    public init(_ html: String) {
        self.html = html
    }

    public func _render(into renderer: inout HTMLRenderer) {
        renderer.write(html)
    }
}

/// A type-erased view.
public struct AnyView: View {
    public typealias Body = Never
    let view: any View

    public init<Content: View>(_ view: Content) {
        if let erased = view as? AnyView {
            self = erased
        } else {
            self.view = view
        }
    }

    public func _render(into renderer: inout HTMLRenderer) {
        view._render(into: &renderer)
    }
}

/// Groups views without adding an element around them.
public struct Group<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

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
    public typealias Body = Never
    public let views: [Content]

    public init<Data: Sequence>(_ data: Data, @ViewBuilder content: (Data.Element) throws -> Content) rethrows {
        self.views = try data.map(content)
    }

    init(views: [Content]) {
        self.views = views
    }

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
    public typealias Body = Never
    public let tag: String
    public let attributes: HTMLAttributes
    public let content: Content

    public init(_ tag: String, attributes: HTMLAttributes = [:], @ViewBuilder content: () -> Content) {
        self.init(tag, attributes: attributes, wrapping: content())
    }

    public init(_ tag: String, attributes: HTMLAttributes = [:], wrapping content: Content) {
        self.tag = tag
        self.attributes = attributes
        self.content = content
    }

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

extension Element where Content == EmptyView {
    public init(_ tag: String, attributes: HTMLAttributes = [:]) {
        self.init(tag, attributes: attributes, wrapping: EmptyView())
    }
}

/// An HTML element with no content and no closing tag, such as `<img>`.
public struct VoidElement: View {
    public typealias Body = Never
    public let tag: String
    public let attributes: HTMLAttributes

    public init(_ tag: String, attributes: HTMLAttributes = [:]) {
        self.tag = tag
        self.attributes = attributes
    }

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
