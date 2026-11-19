/// Horizontal alignment of the children of a `VStack`.
public enum HorizontalAlignment: String, Sendable {
    case leading = "flex-start"
    case center = "center"
    case trailing = "flex-end"
    case stretch = "stretch"
}

/// Vertical alignment of the children of an `HStack`.
public enum VerticalAlignment: String, Sendable {
    case top = "flex-start"
    case center = "center"
    case bottom = "flex-end"
    case stretch = "stretch"
    case baseline = "baseline"
}

/// Arranges its children in a vertical column, using a flexbox `<div>`.
public struct VStack<Content: View>: View {
    public let alignment: HorizontalAlignment
    public let spacing: Int?
    public let content: Content

    public init(alignment: HorizontalAlignment = .stretch, spacing: Int? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Element<Content> {
        Element("div", attributes: ["style": stackStyle("column", alignment.rawValue, spacing)], wrapping: content)
    }
}

/// Arranges its children in a horizontal row, using a flexbox `<div>`.
public struct HStack<Content: View>: View {
    public let alignment: VerticalAlignment
    public let spacing: Int?
    public let content: Content

    public init(alignment: VerticalAlignment = .center, spacing: Int? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: Element<Content> {
        Element("div", attributes: ["style": stackStyle("row", alignment.rawValue, spacing)], wrapping: content)
    }
}

/// Expands to fill the free space along the main axis of an `HStack` or `VStack`.
public struct Spacer: View {
    public init() {}

    public var body: Element<EmptyView> {
        Element("div", attributes: ["style": "flex: 1 1 auto"])
    }
}

private func stackStyle(_ direction: String, _ alignment: String, _ spacing: Int?) -> String {
    var style = "display: flex; flex-direction: \(direction); align-items: \(alignment)"
    if let spacing {
        style += "; gap: \(spacing)px"
    }
    return style
}
