// Table elements. Each renders its content inside one tag.

/// A table (`<table>`).
public struct Table<Content: View>: View {

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
    public var body: Element<Content> {
        Element("table", wrapping: content)
    }

}

/// The header rows of a table (`<thead>`).
public struct TableHead<Content: View>: View {

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
    public var body: Element<Content> {
        Element("thead", wrapping: content)
    }

}

/// The body rows of a table (`<tbody>`).
public struct TableBody<Content: View>: View {

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
    public var body: Element<Content> {
        Element("tbody", wrapping: content)
    }

}

/// The footer rows of a table (`<tfoot>`).
public struct TableFooter<Content: View>: View {

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
    public var body: Element<Content> {
        Element("tfoot", wrapping: content)
    }

}

/// A table row (`<tr>`).
public struct TableRow<Content: View>: View {

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
    public var body: Element<Content> {
        Element("tr", wrapping: content)
    }

}

/// A header cell (`<th>`).
///
/// Pass `columnSpan` or `rowSpan` to make the cell cover more than one
/// column or row (`colspan` and `rowspan`).
public struct TableHeaderCell<Content: View>: View {

    // MARK: - Properties

    /// How many columns the cell covers, or `nil` for one.
    public let columnSpan: Int?

    /// How many rows the cell covers, or `nil` for one.
    public let rowSpan: Int?

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates the element with the content built by `content`.
    /// - Parameters:
    ///   - columnSpan: How many columns the cell covers, or `nil` for one.
    ///   - rowSpan: How many rows the cell covers, or `nil` for one.
    ///   - content: The element's content.
    public init(columnSpan: Int? = nil, rowSpan: Int? = nil, @ViewBuilder content: () -> Content) {
        self.columnSpan = columnSpan
        self.rowSpan = rowSpan
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["colspan"] = columnSpan.map(String.init)
        attributes["rowspan"] = rowSpan.map(String.init)
        return Element("th", attributes: attributes, wrapping: content)
    }

}

/// Initializers that take plain text.
extension TableHeaderCell where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameters:
    ///   - text: The text, which is escaped when rendered.
    ///   - columnSpan: How many columns the cell covers, or `nil` for one.
    ///   - rowSpan: How many rows the cell covers, or `nil` for one.
    public init(_ text: String, columnSpan: Int? = nil, rowSpan: Int? = nil) {
        self.init(columnSpan: columnSpan, rowSpan: rowSpan) { Text(text) }
    }

}

/// A data cell (`<td>`).
///
/// Pass `columnSpan` or `rowSpan` to make the cell cover more than one
/// column or row (`colspan` and `rowspan`).
public struct TableCell<Content: View>: View {

    // MARK: - Properties

    /// How many columns the cell covers, or `nil` for one.
    public let columnSpan: Int?

    /// How many rows the cell covers, or `nil` for one.
    public let rowSpan: Int?

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates the element with the content built by `content`.
    /// - Parameters:
    ///   - columnSpan: How many columns the cell covers, or `nil` for one.
    ///   - rowSpan: How many rows the cell covers, or `nil` for one.
    ///   - content: The element's content.
    public init(columnSpan: Int? = nil, rowSpan: Int? = nil, @ViewBuilder content: () -> Content) {
        self.columnSpan = columnSpan
        self.rowSpan = rowSpan
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["colspan"] = columnSpan.map(String.init)
        attributes["rowspan"] = rowSpan.map(String.init)
        return Element("td", attributes: attributes, wrapping: content)
    }

}

/// Initializers that take plain text.
extension TableCell where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameters:
    ///   - text: The text, which is escaped when rendered.
    ///   - columnSpan: How many columns the cell covers, or `nil` for one.
    ///   - rowSpan: How many rows the cell covers, or `nil` for one.
    public init(_ text: String, columnSpan: Int? = nil, rowSpan: Int? = nil) {
        self.init(columnSpan: columnSpan, rowSpan: rowSpan) { Text(text) }
    }

}
