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
    /// The text of the document's `<title>`.
    public let title: String
    /// The language of the page, written as the `lang` attribute of `<html>`.
    public let language: String
    /// Extra content for `<head>`, after the charset, viewport and title.
    public let head: HeadContent
    /// The element's content.
    public let content: Content

    /// Creates a document with a title, extra head content and body content.
    /// ///
    /// - Parameters:
    ///   - title: The document title.
    ///   - language: The page language, such as `"en"` or `"fr"`.
    ///   - head: Stylesheets, scripts and meta tags to add to `<head>`.
    ///   - body: The page content.
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
    /// Creates a document with a title and body content, and nothing extra in its head.
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
    /// The element's content.
    public let content: Content

    /// Creates the element with the content built by `content`.
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
    /// The page language, written as the `lang` attribute. `nil` leaves it out.
    public let language: String?
    /// The element's content.
    public let content: Content

    /// Creates the root element with the given language and content.
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
    /// The title text.
    public let text: String

    /// Creates a title containing escaped `text`.
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
    /// The relationship, written as the `rel` attribute, such as `"icon"`.
    public let relationship: String
    /// The linked resource's URL.
    public let destination: String

    /// Creates a link to a resource with the given relationship.
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
    /// The element's attributes.
    let attributes: HTMLAttributes

    /// Creates `<meta charset>`. `HTMLDocument` already adds `utf-8`.
    public init(charset: String) {
        attributes = ["charset": charset]
    }

    /// Creates `<meta name content>`, for example a description.
    public init(name: String, content: String) {
        attributes = ["name": name, "content": content]
    }

    /// Creates `<meta property content>`, as used by Open Graph tags.
    public init(property: String, content: String) {
        attributes = ["property": property, "content": content]
    }

    public var body: VoidElement { VoidElement("meta", attributes: attributes) }
}

/// Links an external stylesheet (`<link rel="stylesheet">`).
public struct Stylesheet: View {
    /// The stylesheet URL.
    public let href: String

    /// Creates a link to the stylesheet at `href`.
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
    /// The CSS, after neutralising any closing tag inside it.
    public let css: String

    /// Creates a `<style>` element containing `css`.
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
    /// The element's attributes.
    let attributes: HTMLAttributes
    /// The inline JavaScript, or an empty string for an external script.
    let code: String

    /// Creates a script that loads `src`.
    /// ///
    /// - Parameters:
    ///   - src: The script URL.
    ///   - isDeferred: Adds `defer`, so the script runs after the document is parsed.
    ///   - module: Adds `type="module"`.
    public init(src: String, defer isDeferred: Bool = false, module: Bool = false) {
        var attributes: HTMLAttributes = ["src": src]
        if module { attributes["type"] = "module" }
        if isDeferred { attributes.setFlag("defer") }
        self.attributes = attributes
        self.code = ""
    }

    /// Creates an inline script. Only pass code you trust.
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
