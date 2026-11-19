/// A complete HTML page, with `<!DOCTYPE html>`, `<head>` and `<body>`.
///
/// ```swift
/// HTMLDocument(title: "Home") {
///     Stylesheet(href: "/styles.css")
/// } body: {
///     Main { Heading("Welcome") }
/// }
/// ```
///
/// Attribute modifiers on a document apply to the `<html>` element. For
/// full control over the structure, build it yourself from `Document`,
/// `HTMLRoot`, `Head`, `Title` and `DocumentBody`.
public struct HTMLDocument<HeadContent: View, Content: View>: View {
    public let title: String
    public let language: String
    public let head: HeadContent
    public let content: Content

    public init(
        title: String,
        language: String = "en",
        @ViewBuilder head: () -> HeadContent,
        @ViewBuilder body: () -> Content
    ) {
        self.title = title
        self.language = language
        self.head = head()
        self.content = body()
    }

    public var body: some View {
        Document {
            HTMLRoot(language: language) {
                Head {
                    Meta(charset: "utf-8")
                    Meta(name: "viewport", content: "width=device-width, initial-scale=1")
                    Title(title)
                    head
                }
                DocumentBody { content }
            }
        }
    }
}

extension HTMLDocument where HeadContent == EmptyView {
    public init(title: String, language: String = "en", @ViewBuilder body: () -> Content) {
        self.init(title: title, language: language, head: { EmptyView() }, body: body)
    }
}

/// A page with only a title and body content: shorthand for an
/// `HTMLDocument` with an empty head.
///
/// ```swift
/// app.get { _ in
///     Page(title: "Hello") { Heading("Hello") }
/// }
/// ```
public typealias Page<Content: View> = HTMLDocument<EmptyView, Content>

/// Writes `<!DOCTYPE html>` followed by its content, normally an `HTMLRoot`.
public struct Document<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        RawHTML("<!DOCTYPE html>")
        content
    }
}

/// The root `<html>` element.
public struct HTMLRoot<Content: View>: View {
    public let language: String?
    public let content: Content

    public init(language: String? = "en", @ViewBuilder content: () -> Content) {
        self.language = language
        self.content = content()
    }

    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["lang"] = language
        return Element("html", attributes: attributes, wrapping: content)
    }
}

/// The document `<title>`. The text is escaped.
public struct Title: View {
    public let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: Element<Text> {
        Element("title", wrapping: Text(text))
    }
}

/// A `<link>` relating the document to another resource, such as an icon
/// or a stylesheet.
public struct ResourceLink: View {
    public let relationship: String
    public let destination: String

    public init(relationship: String, destination: String) {
        self.relationship = relationship
        self.destination = destination
    }

    public var body: VoidElement {
        VoidElement("link", attributes: ["rel": relationship, "href": destination])
    }
}

/// A `<meta>` tag for the document head.
public struct Meta: View {
    let attributes: HTMLAttributes

    public init(charset: String) {
        attributes = ["charset": charset]
    }

    public init(name: String, content: String) {
        attributes = ["name": name, "content": content]
    }

    public init(property: String, content: String) {
        attributes = ["property": property, "content": content]
    }

    public var body: VoidElement { VoidElement("meta", attributes: attributes) }
}

/// Links an external stylesheet (`<link rel="stylesheet">`).
public struct Stylesheet: View {
    public let href: String

    public init(href: String) {
        self.href = href
    }

    public var body: VoidElement {
        VoidElement("link", attributes: ["rel": "stylesheet", "href": href])
    }
}

/// Inline CSS (`<style>`). The CSS is not escaped, but any `</style` inside
/// it is neutralised so it cannot close the tag early.
public struct Style: View {
    public let css: String

    public init(_ css: String) {
        self.css = css
    }

    public var body: Element<RawHTML> {
        Element("style", wrapping: RawHTML(css.replacingOccurrences(of: "</", with: "<\\/")))
    }
}

/// A script, either external (`src`) or inline. Inline code is not escaped,
/// but any `</` inside it is written as `<\/` so it cannot close the tag early.
public struct Script: View {
    let attributes: HTMLAttributes
    let code: String

    public init(src: String, defer isDeferred: Bool = false, module: Bool = false) {
        var attributes: HTMLAttributes = ["src": src]
        if module { attributes["type"] = "module" }
        if isDeferred { attributes.setFlag("defer") }
        self.attributes = attributes
        self.code = ""
    }

    public init(_ code: String, module: Bool = false) {
        var attributes = HTMLAttributes()
        if module { attributes["type"] = "module" }
        self.attributes = attributes
        self.code = code.replacingOccurrences(of: "</", with: "<\\/")
    }

    public var body: Element<RawHTML> {
        Element("script", attributes: attributes, wrapping: RawHTML(code))
    }
}
