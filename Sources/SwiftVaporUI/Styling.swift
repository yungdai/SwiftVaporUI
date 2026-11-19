/// A CSS color, with SwiftUI-style named colors.
public struct Color: Sendable, Hashable {

    // MARK: - Static Properties

    /// Black.
    public static let black = Color(css: "black")

    /// White.
    public static let white = Color(css: "white")

    /// Gray.
    public static let gray = Color(css: "gray")

    /// Red (CSS `crimson`).
    public static let red = Color(css: "crimson")

    /// Orange (CSS `darkorange`).
    public static let orange = Color(css: "darkorange")

    /// Yellow (CSS `gold`).
    public static let yellow = Color(css: "gold")

    /// Green (CSS `seagreen`).
    public static let green = Color(css: "seagreen")

    /// Blue (CSS `royalblue`).
    public static let blue = Color(css: "royalblue")

    /// Purple (CSS `rebeccapurple`).
    public static let purple = Color(css: "rebeccapurple")

    /// Fully transparent.
    public static let clear = Color(css: "transparent")

    /// The surrounding text color (`currentColor`).
    public static let current = Color(css: "currentColor")

    // MARK: - Properties

    /// The CSS value, such as `#2f6b3a` or `rgb(0 0 0 / 50%)`.
    public let css: String

    // MARK: - Initializer

    /// Creates a color from any CSS color value.
    /// - Parameter css: The CSS value, such as `#2f6b3a` or `rgb(0 0 0 / 50%)`.
    public init(css: String) {
        self.css = css
    }

    // MARK: - Methods

    /// A color from hex digits, with or without a leading `#`.
    /// - Parameter value: Hex digits such as `2f6b3a`, with or without a leading `#`.
    /// - Returns: The color.
    public static func hex(_ value: String) -> Color {
        Color(css: value.hasPrefix("#") ? value : "#" + value)
    }

    /// A color from 0–255 red, green and blue components and a 0–1 opacity.
    /// - Parameters:
    ///   - red: The red component, from 0 to 255.
    ///   - green: The green component, from 0 to 255.
    ///   - blue: The blue component, from 0 to 255.
    ///   - opacity: The opacity, from 0 to 1.
    /// - Returns: The color.
    public static func rgb(_ red: Int, _ green: Int, _ blue: Int, opacity: Double = 1) -> Color {
        Color(css: "rgb(\(red) \(green) \(blue) / \(cssNumber(opacity * 100))%)")
    }
}

/// A text style, in the spirit of SwiftUI's built-in fonts.
public struct Font: Sendable, Hashable {

    // MARK: - Nested Types

    /// A CSS font weight.
    public enum Weight: Int, Sendable {

        /// Light (300).
        case light = 300

        /// Regular (400).
        case regular = 400

        /// Medium (500).
        case medium = 500

        /// Semibold (600).
        case semibold = 600

        /// Bold (700).
        case bold = 700

        /// Heavy (800).
        case heavy = 800
    }

    // MARK: - Static Properties

    /// 34 pixels, bold.
    public static let largeTitle = system(size: 34, weight: .bold)

    /// 28 pixels, bold.
    public static let title = system(size: 28, weight: .bold)

    /// 22 pixels, bold.
    public static let title2 = system(size: 22, weight: .bold)

    /// 17 pixels, semibold.
    public static let headline = system(size: 17, weight: .semibold)

    /// 17 pixels, regular.
    public static let body = system(size: 17)

    /// 16 pixels, regular.
    public static let callout = system(size: 16)

    /// 13 pixels, regular.
    public static let footnote = system(size: 13)

    /// 12 pixels, regular.
    public static let caption = system(size: 12)

    // MARK: - Properties

    /// The CSS declarations for this style.
    public let css: String

    // MARK: - Initializer

    /// Creates a font from CSS declarations, such as `"font: 600 15px/1.4 Georgia"`.
    /// - Parameter css: The CSS declarations for this style.
    public init(css: String) {
        self.css = css
    }

    // MARK: - Methods

    /// A font of a given size in pixels and optional weight.
    /// - Parameters:
    ///   - size: The font size in pixels.
    ///   - weight: The font weight.
    /// - Returns: The font.
    public static func system(size: Double, weight: Weight = .regular) -> Font {
        Font(css: "font-size: \(cssNumber(size))px; font-weight: \(weight.rawValue)")
    }
}

/// The edges `padding(_:_:)` can apply to.
public struct Edge: OptionSet, Sendable, Hashable {

    // MARK: - Static Properties

    /// The top edge.
    public static let top = Edge(rawValue: 1)

    /// The bottom edge.
    public static let bottom = Edge(rawValue: 2)

    /// The leading edge: left in left-to-right text, right in right-to-left text.
    public static let leading = Edge(rawValue: 4)

    /// The trailing edge: right in left-to-right text, left in right-to-left text.
    public static let trailing = Edge(rawValue: 8)

    /// The leading and trailing edges.
    public static let horizontal: Edge = [.leading, .trailing]

    /// The top and bottom edges.
    public static let vertical: Edge = [.top, .bottom]

    /// Every edge.
    public static let all: Edge = [.horizontal, .vertical]

    // MARK: - Properties

    /// The bit mask of edges.
    public let rawValue: Int

    // MARK: - Initializer

    /// Creates a set of edges from a bit mask.
    /// - Parameter rawValue: The bit mask of edges.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// SwiftUI-style styling modifiers. Each one adds inline CSS to the view's
/// element (wrapping bare text in a `<span>`), rather than adding a new
/// wrapper element, so they combine with `.class` and with each other.
extension View {

    /// Adds padding, in pixels, on the given edges.
    /// - Parameters:
    ///   - edges: The edges to pad.
    ///   - length: The padding in pixels.
    /// - Returns: A view with the change applied.
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
    /// - Parameter length: The padding in pixels.
    /// - Returns: A view with the change applied.
    public func padding(_ length: Double) -> ModifiedView<Self> {
        padding(.all, length)
    }

    /// Sets the text style.
    /// - Parameter font: The text style.
    /// - Returns: A view with the change applied.
    public func font(_ font: Font) -> ModifiedView<Self> {
        style(font.css)
    }

    /// Sets the font weight.
    /// - Parameter weight: The font weight.
    /// - Returns: A view with the change applied.
    public func fontWeight(_ weight: Font.Weight) -> ModifiedView<Self> {
        style("font-weight", String(weight.rawValue))
    }

    /// Makes the text bold.
    /// - Returns: A view with the change applied.
    public func bold() -> ModifiedView<Self> {
        fontWeight(.bold)
    }

    /// Makes the text italic.
    /// - Returns: A view with the change applied.
    public func italic() -> ModifiedView<Self> {
        style("font-style", "italic")
    }

    /// Sets the text color.
    /// - Parameter color: The color to use.
    /// - Returns: A view with the change applied.
    public func foregroundColor(_ color: Color) -> ModifiedView<Self> {
        style("color", color.css)
    }

    /// Sets the background color.
    /// - Parameter color: The color to use.
    /// - Returns: A view with the change applied.
    public func background(_ color: Color) -> ModifiedView<Self> {
        style("background", color.css)
    }

    /// Rounds the corners, in pixels.
    /// - Parameter radius: The radius in pixels.
    /// - Returns: A view with the change applied.
    public func cornerRadius(_ radius: Double) -> ModifiedView<Self> {
        style("border-radius", "\(cssNumber(radius))px")
    }

    /// Sets the opacity, from 0 to 1.
    /// - Parameter value: The value to set.
    /// - Returns: A view with the change applied.
    public func opacity(_ value: Double) -> ModifiedView<Self> {
        style("opacity", cssNumber(min(max(value, 0), 1)))
    }

    /// Draws a solid border around the element.
    ///
    /// ```swift
    /// Div { "Boxed" }.border(.gray, width: 2)
    /// ```
    /// - Parameters:
    ///   - color: The color to use.
    ///   - width: The width in pixels.
    /// - Returns: A view with the change applied.
    public func border(_ color: Color, width: Double = 1) -> ModifiedView<Self> {
        style("border", "\(cssNumber(width))px solid \(color.css)")
    }

    /// Adds a drop shadow behind the element, like SwiftUI's `shadow`.
    /// - Parameters:
    ///   - color: The shadow color. Defaults to black at 33% opacity.
    ///   - radius: The blur radius in pixels.
    ///   - x: The horizontal offset in pixels.
    ///   - y: The vertical offset in pixels.
    /// - Returns: A view with the change applied.
    public func shadow(
        color: Color = .rgb(0, 0, 0, opacity: 0.33),
        radius: Double,
        x: Double = 0,
        y: Double = 0
    ) -> ModifiedView<Self> {
        style("box-shadow", "\(cssNumber(x))px \(cssNumber(y))px \(cssNumber(radius))px \(color.css)")
    }

    /// Fixes the width and/or height, in pixels.
    /// - Parameters:
    ///   - width: The width in pixels.
    ///   - height: The height in pixels, or `nil` to leave it.
    /// - Returns: A view with the change applied.
    public func frame(width: Double? = nil, height: Double? = nil) -> ModifiedView<Self> {
        var declarations: [String] = []
        if let width { declarations.append("width: \(cssNumber(width))px") }
        if let height { declarations.append("height: \(cssNumber(height))px") }
        return style(declarations.joined(separator: "; "))
    }

    /// Limits the width and/or height, in pixels.
    /// - Parameters:
    ///   - maxWidth: The largest width in pixels, or `nil` to leave it.
    ///   - maxHeight: The largest height in pixels, or `nil` to leave it.
    /// - Returns: A view with the change applied.
    public func frame(maxWidth: Double? = nil, maxHeight: Double? = nil) -> ModifiedView<Self> {
        var declarations: [String] = []
        if let maxWidth { declarations.append("max-width: \(cssNumber(maxWidth))px") }
        if let maxHeight { declarations.append("max-height: \(cssNumber(maxHeight))px") }
        return style(declarations.joined(separator: "; "))
    }
}
