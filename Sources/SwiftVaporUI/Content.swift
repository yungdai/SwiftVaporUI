/// The level of a `Heading`, from `<h1>` to `<h6>`.
public enum HeadingLevel: Int, Sendable, CaseIterable {
    case h1 = 1, h2, h3, h4, h5, h6
}

/// A section heading (`<h1>` to `<h6>`).
///
/// ```swift
/// Heading("Getting started", level: .h2)
/// Heading(level: .h3) { "Step "; Strong("one") }
/// ```
public struct Heading<Content: View>: View {
    /// The heading level, from `.h1` to `.h6`.
    public let level: HeadingLevel
    /// The element's content.
    public let content: Content

    /// Creates a heading of the given level from the views built by `content`.
    public init(level: HeadingLevel = .h1, @ViewBuilder content: () -> Content) {
        self.level = level
        self.content = content()
    }

    public var body: Element<Content> {
        Element("h\(level.rawValue)", wrapping: content)
    }
}

extension Heading where Content == Text {
    /// Creates a heading of the given level containing escaped `text`.
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
    /// The URL the link points to. It is escaped but not validated.
    public let destination: String
    /// The link's visible content.
    public let label: Label

    /// Creates a link to `destination` whose visible content is built by `label`.
    public init(destination: String, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    public var body: Element<Label> {
        Element("a", attributes: ["href": destination], wrapping: label)
    }
}

extension Link where Label == Text {
    /// Creates a link to `destination` with escaped `title` as its text.
    public init(_ title: String, destination: String) {
        self.init(destination: destination) { Text(title) }
    }
}

/// A `<ul>` with one `<li>` per element of a collection.
///
/// ```swift
/// List(plants) { plant in
///     Link(plant.name, destination: "/plants/\(plant.slug)")
/// }
/// ```
public struct List<Row: View>: View {
    /// The rendered rows, one per element of the data.
    public let rows: [Row]

    /// Creates a list with one row, built by `row`, for each element of `data`.
    public init<Data: Sequence>(_ data: Data, @ViewBuilder row: (Data.Element) throws -> Row) rethrows {
        self.rows = try data.map(row)
    }

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
    /// The image URL.
    public let src: String
    /// Alternative text for screen readers and when the image fails to load.
    public let alt: String
    /// The intrinsic width in pixels, if known.
    public var width: Int?
    /// The intrinsic height in pixels, if known.
    public var height: Int?

    /// Creates an image. Pass `width` and `height` when you know them, so the
    /// browser can reserve space before the image loads.
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
    /// Creates a line break.
    public init() {}
    public var body: VoidElement { VoidElement("br") }
}

/// A thematic break (`<hr>`).
public struct Divider: View {
    /// Creates a thematic break.
    public init() {}
    public var body: VoidElement { VoidElement("hr") }
}
