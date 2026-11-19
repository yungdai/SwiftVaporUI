/// The level of a `Heading`, from `<h1>` to `<h6>`.
public enum HeadingLevel: Int, Sendable, CaseIterable {
    case h1 = 1, h2, h3, h4, h5, h6
}

/// A section heading (`<h1>` to `<h6>`).
///
/// ```swift
/// Heading(.h2, "Getting started")
/// ```
public struct Heading<Content: View>: View {
    public let level: HeadingLevel
    public let content: Content

    public init(_ level: HeadingLevel = .h1, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }

    public var body: Element<Content> {
        Element("h\(level.rawValue)", wrapping: content)
    }
}

extension Heading where Content == Text {
    public init(_ level: HeadingLevel = .h1, _ text: String) {
        self.init(level) { Text(text) }
    }
}

/// A hyperlink (`<a>`).
///
/// ```swift
/// Link("Docs", href: "/docs")
/// Link(href: "/") { Image(src: "/logo.svg", alt: "Home") }
/// ```
public struct Link<Content: View>: View {
    public let href: String
    public let content: Content

    public init(href: String, @ViewBuilder content: () -> Content) {
        self.href = href
        self.content = content()
    }

    public var body: Element<Content> {
        Element("a", attributes: ["href": href], wrapping: content)
    }
}

extension Link where Content == Text {
    public init(_ title: String, href: String) {
        self.init(href: href) { Text(title) }
    }
}

/// An image (`<img>`). `alt` is required to encourage accessible markup;
/// pass an empty string for purely decorative images.
public struct Image: View {
    public let src: String
    public let alt: String
    public var width: Int?
    public var height: Int?

    public init(src: String, alt: String, width: Int? = nil, height: Int? = nil) {
        self.src = src
        self.alt = alt
        self.width = width
        self.height = height
    }

    public var body: VoidElement {
        var attributes: HTMLAttributes = ["src": src, "alt": alt]
        attributes["width"] = width.map(String.init)
        attributes["height"] = height.map(String.init)
        return VoidElement("img", attributes: attributes)
    }
}

/// A line break (`<br>`).
public struct LineBreak: View {
    public init() {}
    public var body: VoidElement { VoidElement("br") }
}

/// A thematic break (`<hr>`).
public struct Divider: View {
    public init() {}
    public var body: VoidElement { VoidElement("hr") }
}
