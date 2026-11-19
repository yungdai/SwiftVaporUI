/// The level of a `Heading`, from `<h1>` to `<h6>`.
public enum HeadingLevel: Int, Sendable, CaseIterable {

    /// The page title level (`<h1>`).
    case h1 = 1

    /// A section heading (`<h2>`).
    case h2

    /// A subsection heading (`<h3>`).
    case h3

    /// A fourth-level heading (`<h4>`).
    case h4

    /// A fifth-level heading (`<h5>`).
    case h5

    /// A sixth-level heading (`<h6>`).
    case h6

}

/// A section heading (`<h1>` to `<h6>`).
///
/// ```swift
/// Heading("Getting started", level: .h2)
/// Heading(level: .h3) { "Step "; Strong("one") }
/// ```
public struct Heading<Content: View>: View {

    // MARK: - Properties

    /// The heading level, from `.h1` to `.h6`.
    public let level: HeadingLevel

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates a heading of the given level from the views built by `content`.
    ///
    /// - Parameters:
    ///   - level: The heading level, from `.h1` to `.h6`.
    ///   - content: The element's content.
    public init(level: HeadingLevel = .h1, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("h\(level.rawValue)", wrapping: content)
    }

}

extension Heading where Content == Text {

    // MARK: - Initializers

    /// Creates a heading of the given level containing escaped `text`.
    ///
    /// - Parameters:
    ///   - text: The text, which is escaped when rendered.
    ///   - level: The heading level, from `.h1` to `.h6`.
    public init(_ text: String, level: HeadingLevel = .h1) {
        self.init(level: level) { Text(text) }
    }

}

/// A hyperlink (`<a>`).
///
/// ```swift
/// Link("Docs", destination: "/docs")
/// Link(destination: "/") { Image(src: "/logo.svg", alt: "Home") }
/// ```
public struct Link<Label: View>: View {

    // MARK: - Properties

    /// The URL the link points to. It is escaped but not validated.
    public let destination: String

    /// Where to open the link, or `nil` for the current tab.
    public let target: LinkTarget?

    /// The relationship to the linked page (`rel`), such as `"nofollow"`.
    public let relationship: String?

    /// The link's visible content.
    public let label: Label

    // MARK: - Initializers

    /// Creates a link to `destination` whose visible content is built by `label`.
    ///
    /// - Parameters:
    ///   - destination: The URL.
    ///   - target: Where to open it. `.blank` opens a new tab and, unless you
    ///     pass a `relationship`, adds `rel="noopener"`.
    ///   - relationship: The `rel` attribute.
    ///   - label: A view builder that creates the link's content.
    public init(
        destination: String,
        target: LinkTarget? = nil,
        relationship: String? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.target = target
        self.relationship = relationship
        self.label = label()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Label> {
        var attributes: HTMLAttributes = ["href": destination]
        attributes["target"] = target?.rawValue
        attributes["rel"] = relationship ?? (target == .blank ? "noopener" : nil)
        return Element("a", attributes: attributes, wrapping: label)
    }

}

extension Link where Label == Text {

    // MARK: - Initializers

    /// Creates a link to `destination` with escaped `title` as its text.
    ///
    /// - Parameters:
    ///   - title: The link text, which is escaped when rendered.
    ///   - destination: The URL the link points to. It is escaped but not validated.
    ///   - target: Where to open the link, or `nil` for the current tab.
    ///   - relationship: The relationship to the linked page (`rel`), such as `"nofollow"`.
    public init(_ title: String, destination: String, target: LinkTarget? = nil, relationship: String? = nil) {
        self.init(destination: destination, target: target, relationship: relationship) { Text(title) }
    }

}

/// Where a `Link` opens (the `target` attribute).
public struct LinkTarget: RawRepresentable, Sendable, Hashable, ExpressibleByStringLiteral {

    // MARK: - Static Properties

    /// A new tab or window.
    public static let blank: LinkTarget = "_blank"

    /// The current frame (the default).
    public static let current: LinkTarget = "_self"

    /// The parent frame.
    public static let parent: LinkTarget = "_parent"

    /// The whole window, breaking out of all frames.
    public static let top: LinkTarget = "_top"

    // MARK: - Properties

    /// The value written to `target`.
    public let rawValue: String

    // MARK: - Initializers

    /// Creates a target from its value, such as the name of an `IFrame`.
    ///
    /// - Parameter rawValue: The value written to `target`.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Creates a target from a string literal.
    ///
    /// - Parameter value: The target name.
    public init(stringLiteral value: String) { self.rawValue = value }

}

/// A `<ul>` with one `<li>` per element of a collection.
///
/// ```swift
/// List(plants) { plant in
///     Link(plant.name, destination: "/plants/\(plant.slug)")
/// }
/// ```
public struct List<Row: View>: View {

    // MARK: - Properties

    /// The rendered rows, one per element of the data.
    public let rows: [Row]

    // MARK: - Initializers

    /// Creates a list with one row, built by `row`, for each element of `data`.
    ///
    /// - Parameters:
    ///   - data: The elements to render a row for.
    ///   - row: A view builder that creates the row for one element.
    public init<Data: Sequence>(_ data: Data, @ViewBuilder row: (Data.Element) throws -> Row) rethrows {
        self.rows = try data.map(row)
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        UnorderedList {
            ForEach(rows) { row in
                ListItem { row }
            }
        }
    }

}

/// An image (`<img>`). `alt` is required to encourage accessible markup;
/// pass an empty string for purely decorative images.
public struct Image: View {

    // MARK: - Properties

    /// The image URL.
    public let src: String

    /// Alternative text for screen readers and when the image fails to load.
    public let alt: String

    /// The intrinsic width in pixels, if known.
    public var width: Int?

    /// The intrinsic height in pixels, if known.
    public var height: Int?

    // MARK: - Initializers

    /// Creates an image. Pass `width` and `height` when you know them, so the
    /// browser can reserve space before the image loads.
    ///
    /// - Parameters:
    ///   - src: The image URL.
    ///   - alt: Alternative text for screen readers and when the image fails to load.
    ///   - width: The intrinsic width in pixels, if known.
    ///   - height: The intrinsic height in pixels, if known.
    public init(src: String, alt: String, width: Int? = nil, height: Int? = nil) {
        self.src = src
        self.alt = alt
        self.width = width
        self.height = height
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes: HTMLAttributes = ["src": src, "alt": alt]
        attributes["width"] = width.map(String.init)
        attributes["height"] = height.map(String.init)
        return VoidElement("img", attributes: attributes)
    }

}

/// A line break (`<br>`).
public struct LineBreak: View {

    // MARK: - Initializers

    /// Creates a line break.
    public init() {}

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement { VoidElement("br") }

}

/// A thematic break (`<hr>`).
public struct Divider: View {

    // MARK: - Initializers

    /// Creates a thematic break.
    public init() {}

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement { VoidElement("hr") }

}
