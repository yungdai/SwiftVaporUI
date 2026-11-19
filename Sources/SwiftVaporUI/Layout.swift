/// Horizontal alignment of the children of a `VStack`.
public enum HorizontalAlignment: String, Sendable {

    /// Aligns children to the leading edge.
    case leading = "flex-start"

    /// Centres children.
    case center = "center"

    /// Aligns children to the trailing edge.
    case trailing = "flex-end"

    /// Stretches children to fill the stack.
    case stretch = "stretch"
}


/// Vertical alignment of the children of an `HStack`.
public enum VerticalAlignment: String, Sendable {

    /// Aligns children to the top.
    case top = "flex-start"

    /// Centres children.
    case center = "center"

    /// Aligns children to the bottom.
    case bottom = "flex-end"

    /// Stretches children to fill the stack.
    case stretch = "stretch"

    /// Lines up the first line of text in each child.
    case baseline = "baseline"
}

/// Arranges its children in a vertical column.
///
/// With no arguments it is a plain `<div>`, since block elements already
/// stack vertically; that leaves the layout to your CSS classes. Pass an
/// alignment or spacing to get a flexbox column.
public struct VStack<Content: View>: View {

    // MARK: - Properties

    /// How children are aligned across the column, or `nil` to leave it to CSS.
    public let alignment: HorizontalAlignment?

    /// The gap between children in pixels, or `nil` to leave it to CSS.
    public let spacing: Double?

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a vertical stack.
    /// - Parameters:
    ///   - alignment: How children are aligned across the column, or `nil` to leave it to CSS.
    ///   - spacing: The gap between children in pixels, or `nil` to leave it to CSS.
    ///   - content: The element's content.
    public init(alignment: HorizontalAlignment? = nil, spacing: Double? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        guard alignment != nil || spacing != nil else {
            return Element("div", wrapping: content)
        }
        return Element("div", attributes: ["style": stackStyle("column", alignment?.rawValue, spacing)], wrapping: content)
    }
}

/// Arranges its children in a horizontal row, using a flexbox `<div>`.
public struct HStack<Content: View>: View {

    // MARK: - Properties

    /// How children are aligned across the row.
    public let alignment: VerticalAlignment

    /// The gap between children in pixels. `nil` leaves it to CSS.
    public let spacing: Double?

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a horizontal stack. Children are vertically centred with an 8 pixel gap unless you say otherwise.
    /// - Parameters:
    ///   - alignment: How children are aligned across the row.
    ///   - spacing: The gap between children in pixels. `nil` leaves it to CSS.
    ///   - content: The element's content.
    public init(alignment: VerticalAlignment = .center, spacing: Double? = 8, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("div", attributes: ["style": stackStyle("row", alignment.rawValue, spacing)], wrapping: content)
    }
}

/// Expands to fill the free space along the main axis of an `HStack` or `VStack`.
public struct Spacer: View {

    // MARK: - Initializer

    /// Creates a spacer.
    public init() {}

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<EmptyView> {
        Element("div", attributes: ["style": "flex: 1"])
    }
}

/// A `<nav>` landmark that lays its links out in a row.
public struct NavigationBar<Content: View>: View {

    // MARK: - Properties

    /// The gap between links in pixels.
    public let spacing: Double

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a navigation bar whose links are built by `content`.
    /// - Parameters:
    ///   - spacing: The gap between links in pixels.
    ///   - content: The element's content.
    public init(spacing: Double = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("nav", attributes: ["style": stackStyle("row", VerticalAlignment.center.rawValue, spacing)], wrapping: content)
    }
}

func stackStyle(_ direction: String, _ alignment: String?, _ spacing: Double?) -> String {
    var style = "display: flex; flex-direction: \(direction)"
    if let alignment {
        style += "; align-items: \(alignment)"
    }
    if let spacing {
        style += "; gap: \(cssNumber(spacing))px"
    }
    return style
}

/// Formats a number for CSS, without a trailing `.0` for whole numbers.
func cssNumber(_ value: Double) -> String {
    if value.isFinite, value == value.rounded(), abs(value) < 1e15 {
        return String(Int(value))
    }
    return String(value)
}
