/// A complete HTML page, with `<!DOCTYPE html>`, `<head>` and `<body>`.
///
/// ```swift
/// HTMLDocument(title: "Home") {
///     Stylesheet(href: "/styles.css")
/// } body: {
///     Main { Heading(.h1, "Welcome") }
/// }
/// ```
///
/// Attribute modifiers on a document apply to the `<html>` element.
public struct HTMLDocument<Head: View, Content: View>: View {
    public let title: String
    public let language: String
    public let head: Head
    public let content: Content

    public init(
        title: String,
        language: String = "en",
        @ViewBuilder head: () -> Head,
        @ViewBuilder body: () -> Content
    ) {
        self.title = title
        self.language = language
        self.head = head()
        self.content = body()
    }

    public var body: some View {
        RawHTML("<!DOCTYPE html>")
        Element("html", attributes: ["lang": language]) {
            Element("head") {
                Meta(charset: "utf-8")
                Meta(name: "viewport", content: "width=device-width, initial-scale=1")
                Element("title") { Text(title) }
                head
            }
            Element("body", wrapping: content)
        }
    }
}

extension HTMLDocument where Head == EmptyView {
    public init(title: String, language: String = "en", @ViewBuilder body: () -> Content) {
        self.init(title: title, language: language, head: { EmptyView() }, body: body)
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
