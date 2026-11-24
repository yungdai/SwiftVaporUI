// SwiftUI-style containers: ZStack, Grid, LazyVGrid, ScrollView, TabView,
// DisclosureGroup, Menu and NavigationLink.

// MARK: - Support styles

/// A few lines of CSS a built-in view needs, written once per page.
struct SupportStyle: Sendable {

    // MARK: - Static Properties

    /// Layers every child of a `ZStack` in the same grid cell.
    static let zStack = SupportStyle(
        key: "zstack",
        css: ".svui-zstack{display:grid}.svui-zstack>*{grid-area:1/1}"
    )

    /// Lays out `Grid` rows and cells like a table.
    static let grid = SupportStyle(
        key: "grid",
        css: ".svui-grid{display:table}.svui-grid-row{display:table-row}"
            + ".svui-grid-row>*{display:table-cell;vertical-align:var(--svui-valign,middle)}"
    )

    /// Shows the panel of the checked tab of a `TabView`.
    static let tabs = SupportStyle(
        key: "tabs",
        css: ".svui-tabs{display:flex;flex-wrap:wrap;position:relative}"
            + ".svui-tab-input{position:absolute;opacity:0;width:1px;height:1px;margin:0;pointer-events:none}"
            + ".svui-tab{cursor:pointer;padding:8px 14px;border-bottom:2px solid transparent}"
            + ".svui-tab-input:checked+.svui-tab{border-bottom-color:currentColor;font-weight:600}"
            + ".svui-tab-input:focus-visible+.svui-tab{outline:2px solid;outline-offset:2px}"
            + ".svui-tab-panel{order:1;flex-basis:100%;display:none}"
            + ".svui-tab-input:checked+.svui-tab+.svui-tab-panel{display:block}"
    )

    /// Drops the items of a `Menu` down below its button.
    static let menu = SupportStyle(
        key: "menu",
        css: ".svui-menu{position:relative;display:inline-block}"
            + ".svui-menu>summary{cursor:pointer;list-style:none}"
            + ".svui-menu>summary::-webkit-details-marker{display:none}"
            + ".svui-menu-items{position:absolute;z-index:10;top:100%;left:0;min-width:100%;"
            + "display:flex;flex-direction:column;background:Canvas;color:CanvasText;"
            + "border:1px solid GrayText;border-radius:6px;padding:4px;margin-top:4px}"
    )

    /// Every support style, in the order `SupportStyles` writes them.
    static let all: [SupportStyle] = [.zStack, .grid, .tabs, .menu]

    // MARK: - Properties

    /// A unique name, so the style is written once per page.
    let key: String

    /// The CSS rules.
    let css: String

    // MARK: - Methods

    /// Builds one `<style>` element holding several support styles. It
    /// carries the environment's ``EnvironmentValues/cspNonce``, if any, so a
    /// Content Security Policy with a nonce allows it.
    /// - Parameter styles: The styles to write.
    /// - Returns: The `<style>` element, or an empty string when there are no styles.
    static func styleElement(for styles: [SupportStyle]) -> String {
        guard !styles.isEmpty else { return "" }
        return Style(styles.map(\.css).joined()).render()
    }

}

/// The CSS that `ZStack`, `Grid`, `TabView` and `Menu` rely on, as one
/// `<style>` element.
///
/// You rarely need this. Inside an `HTMLDocument`, the styles those views use
/// are written in the `<head>` for you. In a fragment rendered on its own,
/// each view writes the CSS it needs inline, once, the first time it appears.
/// Use `SupportStyles()` when you build the document yourself from `Head`
/// and want every support style in the head, or when you need a fixed style
/// sheet, for example for a Content Security Policy hash.
public struct SupportStyles: View {

    // MARK: - Initializer

    /// Creates the support style sheet.
    public init() {}

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        // Modifiers pass on to the next element, as with `RawHTML`.
        let missing = SupportStyle.all.filter { !renderer.writtenSupportStyles.contains($0.key) }
        for style in missing {
            renderer.writtenSupportStyles.insert(style.key)
        }
        renderer.write(SupportStyle.styleElement(for: missing))
    }

}

/// Writes a support style, then renders `content`.
struct WithSupportStyle<Content: View>: View {

    // MARK: - Properties

    /// The style the content needs.
    let style: SupportStyle

    /// The view to render after the style.
    let content: Content

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    func _render(into renderer: inout HTMLRenderer) {
        renderer.writeSupportStyle(style)
        content._render(into: &renderer)
    }

}

// MARK: - ZStack

/// Where content sits inside a `ZStack`.
public enum Alignment: Sendable, CaseIterable {

    /// The top-left corner in left-to-right text.
    case topLeading

    /// The middle of the top edge.
    case top

    /// The top-right corner in left-to-right text.
    case topTrailing

    /// The middle of the leading edge.
    case leading

    /// The centre.
    case center

    /// The middle of the trailing edge.
    case trailing

    /// The bottom-left corner in left-to-right text.
    case bottomLeading

    /// The middle of the bottom edge.
    case bottom

    /// The bottom-right corner in left-to-right text.
    case bottomTrailing

    /// The CSS `place-items` value: block axis, then inline axis.
    var placeItems: String {
        let vertical: String
        switch self {
        case .topLeading, .top, .topTrailing: vertical = "start"
        case .leading, .center, .trailing: vertical = "center"
        case .bottomLeading, .bottom, .bottomTrailing: vertical = "end"
        }
        let horizontal: String
        switch self {
        case .topLeading, .leading, .bottomLeading: horizontal = "start"
        case .top, .center, .bottom: horizontal = "center"
        case .topTrailing, .trailing, .bottomTrailing: horizontal = "end"
        }
        return "\(vertical) \(horizontal)"
    }

}

/// Layers its children on top of each other, like SwiftUI's `ZStack`.
///
/// Later children are drawn above earlier ones. The stack is as big as its
/// largest child. It uses a one-cell CSS grid, so no absolute positioning.
///
/// ```swift
/// ZStack(alignment: .bottomLeading) {
///     Image(src: "/img/stall.jpg", alt: "")
///     Span("Open late").class("badge")
/// }
/// ```
public struct ZStack<Content: View>: View {

    // MARK: - Properties

    /// Where children sit inside the stack.
    public let alignment: Alignment

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a stack whose layers are built by `content`.
    /// - Parameters:
    ///   - alignment: Where children sit inside the stack.
    ///   - content: The element's content.
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        WithSupportStyle(
            style: .zStack,
            content: Element(
                "div",
                attributes: ["class": "svui-zstack", "style": "place-items: \(alignment.placeItems)"],
                wrapping: content
            )
        )
    }

}

// MARK: - Grid

/// A grid of rows whose columns line up, like SwiftUI's `Grid`.
///
/// Each `GridRow` is one row, and each child of a row is one cell. Columns
/// size to their widest cell, as in a table, so you do not have to say how
/// many columns there are.
///
/// ```swift
/// Grid(horizontalSpacing: 16) {
///     GridRow { Strong("Stall"); Strong("Opens") }
///     GridRow { "Dumplings"; "17:00" }
///     GridRow { "Bubble tea"; "18:30" }
/// }
/// ```
public struct Grid<Content: View>: View {

    // MARK: - Properties

    /// How cells are aligned vertically within their row, unless the row says otherwise.
    public let alignment: VerticalAlignment

    /// The gap between columns, in pixels.
    public let horizontalSpacing: Double

    /// The gap between rows, in pixels.
    public let verticalSpacing: Double

    /// The rows.
    public let content: Content

    // MARK: - Initializer

    /// Creates a grid whose rows are built by `content`.
    /// - Parameters:
    ///   - alignment: How cells are aligned vertically within their row, unless the row says otherwise.
    ///   - horizontalSpacing: The gap between columns, in pixels.
    ///   - verticalSpacing: The gap between rows, in pixels.
    ///   - content: The rows.
    public init(
        alignment: VerticalAlignment = .center,
        horizontalSpacing: Double = 8,
        verticalSpacing: Double = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        let style = "border-spacing: \(cssNumber(horizontalSpacing))px \(cssNumber(verticalSpacing))px; "
            + "--svui-valign: \(alignment.tableValue)"
        return WithSupportStyle(
            style: .grid,
            content: Element("div", attributes: ["class": "svui-grid", "style": style], wrapping: content)
        )
    }

}

/// One row of a `Grid`. Each child is one cell.
public struct GridRow<Content: View>: View {

    // MARK: - Properties

    /// How this row's cells are aligned vertically, or `nil` to use the grid's.
    public let alignment: VerticalAlignment?

    /// The cells.
    public let content: Content

    // MARK: - Initializer

    /// Creates a row whose cells are built by `content`.
    /// - Parameters:
    ///   - alignment: How this row's cells are aligned vertically, or `nil` to use the grid's.
    ///   - content: The cells.
    public init(alignment: VerticalAlignment? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes: HTMLAttributes = ["class": "svui-grid-row"]
        if let alignment {
            attributes["style"] = "--svui-valign: \(alignment.tableValue)"
        }
        return Element("div", attributes: attributes, wrapping: content)
    }

}

/// Table-cell alignment for `Grid`.
extension VerticalAlignment {

    /// The CSS `vertical-align` value for a table cell.
    var tableValue: String {
        switch self {
        case .top: "top"
        case .center, .stretch: "middle"
        case .bottom: "bottom"
        case .baseline: "baseline"
        }
    }

}

/// The size of one column of a `LazyVGrid`.
public struct GridItem: Sendable, Hashable {

    // MARK: - Nested Types

    /// How a column is sized.
    public enum Size: Sendable, Hashable {

        /// Exactly this many pixels wide.
        case fixed(Double)

        /// A share of the free space, at least `minimum` pixels and at most
        /// `maximum` pixels wide.
        case flexible(minimum: Double = 0, maximum: Double = .infinity)

        /// As many columns as fit, each at least `minimum` pixels wide. Used
        /// with other columns, it is one column of that size instead, because
        /// CSS cannot repeat it alongside them.
        case adaptive(minimum: Double, maximum: Double = .infinity)

    }

    // MARK: - Properties

    /// How the column is sized.
    public let size: Size

    // MARK: - Computed Properties

    /// The track size for a column used with other columns: an adaptive
    /// column becomes one flexible track.
    var singleTrackCSS: String {
        if case let .adaptive(minimum, maximum) = size {
            return "minmax(\(cssNumber(minimum))px, \(Self.maximum(maximum)))"
        }
        return css
    }

    /// The CSS track size for `grid-template-columns`.
    var css: String {
        switch size {
        case let .fixed(width):
            return "\(cssNumber(width))px"
        case let .flexible(minimum, maximum):
            return "minmax(\(cssNumber(minimum))px, \(Self.maximum(maximum)))"
        case let .adaptive(minimum, maximum):
            return "repeat(auto-fill, minmax(\(cssNumber(minimum))px, \(Self.maximum(maximum))))"
        }
    }

    // MARK: - Initializer

    /// Creates a column. The default shares the free space equally.
    /// - Parameter size: How the column is sized.
    public init(_ size: Size = .flexible()) {
        self.size = size
    }

    // MARK: - Methods

    /// Formats a column's largest width.
    /// - Parameter value: The width in pixels, or infinity for no limit.
    /// - Returns: The width in pixels, or `1fr` when there is no limit.
    private static func maximum(_ value: Double) -> String {
        value.isFinite ? "\(cssNumber(value))px" : "1fr"
    }

}

/// A grid that flows its children into columns, like SwiftUI's
/// `LazyVGrid`. Uses CSS grid.
///
/// ```swift
/// // Three equal columns.
/// LazyVGrid(columns: Array(repeating: GridItem(), count: 3)) { ... }
///
/// // As many 160 pixel columns as fit; reflows on small screens.
/// LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) { ... }
/// ```
///
/// HTML has no lazy loading for markup, so every child is rendered.
public struct LazyVGrid<Content: View>: View {

    // MARK: - Properties

    /// The columns.
    public let columns: [GridItem]

    /// The gap between cells, in pixels.
    public let spacing: Double?

    /// How children are aligned within their cells, or `nil` to stretch them.
    public let alignment: HorizontalAlignment?

    /// The cells.
    public let content: Content

    // MARK: - Initializer

    /// Creates a grid whose cells are built by `content`.
    /// - Parameters:
    ///   - columns: The columns.
    ///   - alignment: How children are aligned within their cells, or `nil` to stretch them.
    ///   - spacing: The gap between cells, in pixels.
    ///   - content: The cells.
    public init(
        columns: [GridItem],
        alignment: HorizontalAlignment? = nil,
        spacing: Double? = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.columns = columns
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        let template: String
        if columns.isEmpty {
            template = "1fr"
        } else if columns.count == 1 {
            template = columns[0].css
        } else {
            // CSS allows a repeating, as-many-as-fit track only on its own,
            // so with several columns an adaptive one becomes a single track.
            template = columns.map(\.singleTrackCSS).joined(separator: " ")
        }
        var style = "display: grid; grid-template-columns: \(template)"
        if let spacing { style += "; gap: \(cssNumber(spacing))px" }
        if let alignment { style += "; justify-items: \(alignment.rawValue)" }
        return Element("div", attributes: ["style": style], wrapping: content)
    }

}

// MARK: - ScrollView

/// A direction content can scroll in.
public enum Axis: Sendable, Hashable {

    /// A set of directions.
    public struct Set: OptionSet, Sendable, Hashable {

        // MARK: - Static Properties

        /// Left and right.
        public static let horizontal = Set(rawValue: 1)

        /// Up and down.
        public static let vertical = Set(rawValue: 2)

        // MARK: - Properties

        /// The bit mask of directions.
        public let rawValue: Int

        // MARK: - Initializer

        /// Creates a set of directions from a bit mask.
        /// - Parameter rawValue: The bit mask of directions.
        public init(rawValue: Int) { self.rawValue = rawValue }

    }

    /// Left and right.
    case horizontal

    /// Up and down.
    case vertical

}

/// A region that scrolls when its content is too big, like SwiftUI's
/// `ScrollView`.
///
/// Give it a size with `.frame(maxHeight:)` or CSS, or it simply grows to
/// fit its content. It is focusable, so keyboard users can scroll it.
///
/// ```swift
/// ScrollView(.horizontal) {
///     HStack { ForEach(stalls) { StallCard(stall: $0) } }
/// }
/// ```
public struct ScrollView<Content: View>: View {

    // MARK: - Properties

    /// The directions the content can scroll in.
    public let axes: Axis.Set

    /// Whether to show scroll bars.
    public let showsIndicators: Bool

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a scrolling region.
    /// - Parameters:
    ///   - axes: The directions the content can scroll in.
    ///   - showsIndicators: Whether to show scroll bars.
    ///   - content: The element's content.
    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var style: String
        switch (axes.contains(.horizontal), axes.contains(.vertical)) {
        case (true, true): style = "overflow: auto"
        case (true, false): style = "overflow-x: auto; overflow-y: hidden"
        case (false, true): style = "overflow-x: hidden; overflow-y: auto"
        case (false, false): style = "overflow: hidden"
        }
        if !showsIndicators { style += "; scrollbar-width: none" }
        return Element("div", attributes: ["style": style, "tabindex": "0"], wrapping: content)
    }

}

// MARK: - TabView

/// The `TabView` being rendered: its id, which tab is chosen, and how many
/// tabs have been written so far.
struct TabGroupState: Sendable {

    /// The tab view's `id`, used as the radio group name.
    let id: String

    /// The index of the tab shown first.
    let selection: Int

    /// How many tabs have been written so far.
    var count = 0

}

/// Tabs that switch between panels, like SwiftUI's `TabView`, with no
/// JavaScript.
///
/// Each `Tab` becomes a radio button, a label styled as a tab, and a panel.
/// CSS shows the panel of the checked tab. Arrow keys move between tabs.
///
/// ```swift
/// TabView(id: "stall-info") {
///     Tab("Menu") { MenuList() }
///     Tab("Hours") { HoursTable() }
///     Tab("Find us") { MapLink() }
/// }
/// ```
///
/// The `id` must be unique in the page; it names the radio group. Modifiers
/// apply to the tab view's container.
public struct TabView<Content: View>: View {

    // MARK: - Properties

    /// The container `id` and radio group name.
    public let id: String

    /// The index of the tab shown first, counting from 0.
    public let selection: Int

    /// The tabs.
    public let content: Content

    // MARK: - Initializer

    /// Creates a tab view whose tabs are built by `content`.
    /// - Parameters:
    ///   - id: The container `id` and radio group name.
    ///   - selection: The index of the tab shown first, counting from 0.
    ///   - content: The tabs.
    public init(id: String, selection: Int = 0, @ViewBuilder content: () -> Content) {
        self.id = id
        self.selection = selection
        self.content = content()
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        renderer.writeSupportStyle(.tabs)

        var attributes: HTMLAttributes = ["class": "svui-tabs", "id": id]
        renderer.takePending(applyingTo: &attributes)
        renderer.writeOpeningTag("div", attributes: attributes)
        let outer = renderer.tabGroup
        renderer.tabGroup = TabGroupState(id: id, selection: selection)
        content._render(into: &renderer)
        renderer.tabGroup = outer
        renderer.write("</div>")
    }

}

/// One tab of a `TabView`: its label and its panel.
///
/// Modifiers apply to the panel. Outside a `TabView`, a tab renders as a
/// `<section>` with its label as a heading.
public struct Tab<TabLabel: View, Content: View>: View {

    // MARK: - Properties

    /// The tab's label.
    public let label: TabLabel

    /// The panel content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a tab with a custom label.
    /// - Parameters:
    ///   - content: A view builder that creates the panel content.
    ///   - label: A view builder that creates the tab's label.
    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> TabLabel) {
        self.label = label()
        self.content = content()
    }

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        guard var group = renderer.tabGroup else {
            Section {
                Heading(level: .h3) { label }
                content
            }
            ._render(into: &renderer)
            return
        }
        let index = group.count
        group.count += 1
        renderer.tabGroup = group

        let inputID = "\(group.id)-tab-\(index)"
        let pending = renderer.pending
        renderer.pending = []

        var input: HTMLAttributes = [
            "type": "radio",
            "class": "svui-tab-input",
            "name": group.id,
            "id": inputID,
        ]
        if index == group.selection { input.setFlag("checked") }
        renderer.writeOpeningTag("input", attributes: input)
        // Tabs inside this tab's label or panel belong to no tab view of ours,
        // so hide the group from them while they render.
        renderer.tabGroup = nil
        renderer.writeOpeningTag("label", attributes: ["class": "svui-tab", "for": inputID])
        label._render(into: &renderer)
        renderer.pending = []
        renderer.write("</label>")

        renderer.pending = pending
        Element(
            "div",
            attributes: ["class": "svui-tab-panel", "role": "tabpanel", "aria-labelledby": inputID],
            wrapping: content
        )
        ._render(into: &renderer)
        renderer.tabGroup = group
    }

}

/// Initializers that take plain text.
extension Tab where TabLabel == Text {

    /// Creates a tab with escaped `title` as its label.
    /// - Parameters:
    ///   - title: The tab's label, which is escaped when rendered.
    ///   - content: The panel content.
    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(title) }
    }

}

// MARK: - Disclosure, menu and navigation

/// Content that shows and hides under a label, like SwiftUI's
/// `DisclosureGroup`. Renders `<details>` and `<summary>`, so it needs no
/// JavaScript.
///
/// ```swift
/// DisclosureGroup("Allergens") {
///     Paragraph("Contains peanuts and sesame.")
/// }
/// ```
public struct DisclosureGroup<TitleLabel: View, Content: View>: View {

    // MARK: - Properties

    /// Whether it starts open.
    public let isExpanded: Bool

    /// The always-visible label.
    public let label: TitleLabel

    /// The content shown when open.
    public let content: Content

    // MARK: - Initializer

    /// Creates a disclosure group with a custom label.
    /// - Parameters:
    ///   - isExpanded: Whether it starts open.
    ///   - content: A view builder that creates the content shown when open.
    ///   - label: A view builder that creates the always-visible label.
    public init(isExpanded: Bool = false, @ViewBuilder content: () -> Content, @ViewBuilder label: () -> TitleLabel) {
        self.isExpanded = isExpanded
        self.label = label()
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        Element("details", attributes: isExpanded ? ["open": ""] : [:]) {
            Summary { label }
            content
        }
    }

}

/// Initializers that take plain text.
extension DisclosureGroup where TitleLabel == Text {

    /// Creates a disclosure group with escaped `title` as its label.
    /// - Parameters:
    ///   - title: The always-visible label, which is escaped when rendered.
    ///   - isExpanded: Whether it starts open.
    ///   - content: The content shown when open.
    public init(_ title: String, isExpanded: Bool = false, @ViewBuilder content: () -> Content) {
        self.init(isExpanded: isExpanded, content: content) { Text(title) }
    }

}

/// A button that opens a list of actions, like SwiftUI's `Menu`.
///
/// Built on `<details>`, so it opens and closes without JavaScript. Fill it
/// with `Link`s or `Button`s.
///
/// ```swift
/// Menu("Share") {
///     Link("Copy link", destination: "#")
///     Link("Email", destination: "mailto:?subject=Night%20market")
/// }
/// ```
public struct Menu<MenuLabel: View, Content: View>: View {

    // MARK: - Properties

    /// The button that opens the menu.
    public let label: MenuLabel

    /// The menu's items.
    public let content: Content

    // MARK: - Initializer

    /// Creates a menu with a custom label.
    /// - Parameters:
    ///   - content: A view builder that creates the menu's items.
    ///   - label: A view builder that creates the button that opens the menu.
    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> MenuLabel) {
        self.label = label()
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        WithSupportStyle(
            style: .menu,
            content: Element("details", attributes: ["class": "svui-menu"]) {
                Summary { label }
                Element("div", attributes: ["class": "svui-menu-items", "role": "menu"], wrapping: content)
            }
        )
    }

}

/// Initializers that take plain text.
extension Menu where MenuLabel == Text {

    /// Creates a menu with escaped `title` as its label.
    /// - Parameters:
    ///   - title: The menu button's text, which is escaped when rendered.
    ///   - content: The menu's items.
    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(title) }
    }

}

/// A link to another page of your site, like SwiftUI's `NavigationLink`.
///
/// Mark the link to the page being shown with `isActive`; it gets
/// `aria-current="page"` so screen readers announce it and CSS can style it
/// with `[aria-current]`.
///
/// ```swift
/// NavigationBar {
///     NavigationLink("Stalls", destination: "/stalls", isActive: path == "/stalls")
///     NavigationLink("Map", destination: "/map", isActive: path == "/map")
/// }
/// ```
public struct NavigationLink<LinkLabel: View>: View {

    // MARK: - Properties

    /// The URL of the page.
    public let destination: String

    /// Whether this link points at the current page.
    public let isActive: Bool

    /// The link's visible content.
    public let label: LinkLabel

    // MARK: - Initializer

    /// Creates a navigation link with a custom label.
    /// - Parameters:
    ///   - destination: The URL of the page.
    ///   - isActive: Whether this link points at the current page.
    ///   - label: The link's visible content.
    public init(destination: String, isActive: Bool = false, @ViewBuilder label: () -> LinkLabel) {
        self.destination = destination
        self.isActive = isActive
        self.label = label()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<LinkLabel> {
        var attributes: HTMLAttributes = ["href": destination]
        if isActive { attributes["aria-current"] = "page" }
        return Element("a", attributes: attributes, wrapping: label)
    }

}

/// Initializers that take plain text.
extension NavigationLink where LinkLabel == Text {

    /// Creates a navigation link with escaped `title` as its text.
    /// - Parameters:
    ///   - title: The link text, which is escaped when rendered.
    ///   - destination: The URL of the page.
    ///   - isActive: Whether this link points at the current page.
    public init(_ title: String, destination: String, isActive: Bool = false) {
        self.init(destination: destination, isActive: isActive) { Text(title) }
    }

}
