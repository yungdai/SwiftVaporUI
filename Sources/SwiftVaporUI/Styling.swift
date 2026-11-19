/// A CSS color, with SwiftUI-style named colors.
public struct Color: Sendable, Hashable {
    /// The CSS value, such as `#2f6b3a` or `rgb(0 0 0 / 50%)`.
    public let css: String

    public init(css: String) {
        self.css = css
    }

    /// A color from hex digits, with or without a leading `#`.
    public static func hex(_ value: String) -> Color {
        Color(css: value.hasPrefix("#") ? value : "#" + value)
    }

    /// A color from 0–255 red, green and blue components and a 0–1 opacity.
    public static func rgb(_ red: Int, _ green: Int, _ blue: Int, opacity: Double = 1) -> Color {
        Color(css: "rgb(\(red) \(green) \(blue) / \(cssNumber(opacity * 100))%)")
    }

    public static let black = Color(css: "black")
    public static let white = Color(css: "white")
    public static let gray = Color(css: "gray")
    public static let red = Color(css: "crimson")
    public static let orange = Color(css: "darkorange")
    public static let yellow = Color(css: "gold")
    public static let green = Color(css: "seagreen")
    public static let blue = Color(css: "royalblue")
    public static let purple = Color(css: "rebeccapurple")
    public static let clear = Color(css: "transparent")
    /// The surrounding text color (`currentColor`).
    public static let current = Color(css: "currentColor")
}

/// A text style, in the spirit of SwiftUI's built-in fonts.
public struct Font: Sendable, Hashable {
    /// The CSS declarations for this style.
    public let css: String

    public init(css: String) {
        self.css = css
    }

    /// A font of a given size in pixels and optional weight.
    public static func system(size: Double, weight: Weight = .regular) -> Font {
        Font(css: "font-size: \(cssNumber(size))px; font-weight: \(weight.rawValue)")
    }

    public static let largeTitle = system(size: 34, weight: .bold)
    public static let title = system(size: 28, weight: .bold)
    public static let title2 = system(size: 22, weight: .bold)
    public static let headline = system(size: 17, weight: .semibold)
    public static let body = system(size: 17)
    public static let callout = system(size: 16)
    public static let footnote = system(size: 13)
    public static let caption = system(size: 12)

    /// A CSS font weight.
    public enum Weight: Int, Sendable {
        case light = 300, regular = 400, medium = 500, semibold = 600, bold = 700, heavy = 800
    }
}

/// The edges `padding(_:_:)` can apply to.
public struct Edge: OptionSet, Sendable, Hashable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let top = Edge(rawValue: 1)
    public static let bottom = Edge(rawValue: 2)
    public static let leading = Edge(rawValue: 4)
    public static let trailing = Edge(rawValue: 8)
    public static let horizontal: Edge = [.leading, .trailing]
    public static let vertical: Edge = [.top, .bottom]
    public static let all: Edge = [.horizontal, .vertical]
}

/// SwiftUI-style styling modifiers. Each one adds inline CSS to the view's
/// element (wrapping bare text in a `<span>`), rather than adding a new
/// wrapper element, so they combine with `.class` and with each other.
extension View {
    /// Adds padding, in pixels, on the given edges.
    public func padding(_ edges: Edge = .all, _ length: Double = 16) -> ModifiedView<Self> {
        let value = "\(cssNumber(length))px"
        if edges == .all {
            return style("padding", value)
        }
        // Logical properties follow the writing direction, like SwiftUI's
        // leading and trailing.
        var declarations: [String] = []
        if edges.contains(.top) { declarations.append("padding-top: \(value)") }
        if edges.contains(.bottom) { declarations.append("padding-bottom: \(value)") }
        if edges.contains(.leading) { declarations.append("padding-inline-start: \(value)") }
        if edges.contains(.trailing) { declarations.append("padding-inline-end: \(value)") }
        return style(declarations.joined(separator: "; "))
    }

    /// Adds the same padding, in pixels, on every edge.
    public func padding(_ length: Double) -> ModifiedView<Self> {
        padding(.all, length)
    }

    /// Sets the text style.
    public func font(_ font: Font) -> ModifiedView<Self> {
        style(font.css)
    }

    /// Sets the font weight.
    public func fontWeight(_ weight: Font.Weight) -> ModifiedView<Self> {
        style("font-weight", String(weight.rawValue))
    }

    /// Makes the text bold.
    public func bold() -> ModifiedView<Self> {
        fontWeight(.bold)
    }

    /// Makes the text italic.
    public func italic() -> ModifiedView<Self> {
        style("font-style", "italic")
    }

    /// Sets the text color.
    public func foregroundColor(_ color: Color) -> ModifiedView<Self> {
        style("color", color.css)
    }

    /// Sets the background color.
    public func background(_ color: Color) -> ModifiedView<Self> {
        style("background", color.css)
    }

    /// Rounds the corners, in pixels.
    public func cornerRadius(_ radius: Double) -> ModifiedView<Self> {
        style("border-radius", "\(cssNumber(radius))px")
    }

    /// Sets the opacity, from 0 to 1.
    public func opacity(_ value: Double) -> ModifiedView<Self> {
        style("opacity", cssNumber(min(max(value, 0), 1)))
    }

    /// Fixes the width and/or height, in pixels.
    public func frame(width: Double? = nil, height: Double? = nil) -> ModifiedView<Self> {
        var declarations: [String] = []
        if let width { declarations.append("width: \(cssNumber(width))px") }
        if let height { declarations.append("height: \(cssNumber(height))px") }
        return style(declarations.joined(separator: "; "))
    }

    /// Limits the width and/or height, in pixels.
    public func frame(maxWidth: Double? = nil, maxHeight: Double? = nil) -> ModifiedView<Self> {
        var declarations: [String] = []
        if let maxWidth { declarations.append("max-width: \(cssNumber(maxWidth))px") }
        if let maxHeight { declarations.append("max-height: \(cssNumber(maxHeight))px") }
        return style(declarations.joined(separator: "; "))
    }
}
