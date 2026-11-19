import Foundation
import SwiftVaporUI
import XCTest

// Tests for the HTML5 elements, SwiftUI-style containers and controls,
// ViewModifier and the environment.

/// A theme for the environment tests.
private struct Theme: Sendable, Equatable {

    /// The accent colour's name.
    var accent: String
}

/// The environment key for `Theme`.
private struct ThemeKey: EnvironmentKey {

    /// The theme when none is set.
    static let defaultValue = Theme(accent: "blue")
}

/// The `theme` environment value used by the tests.
extension EnvironmentValues {

    /// The theme for this part of the tree.
    fileprivate var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

/// An environment key whose default value is not `nil`.
private struct GreetingKey: EnvironmentKey {

    /// The greeting when none is set.
    static let defaultValue: String? = "Hello"
}

/// Shows the theme's accent, read from the environment.
private struct AccentLabel: View {

    // MARK: - Properties

    /// The theme from the environment.
    @ViewEnvironment(\.theme) var theme

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Span(theme.accent)
    }
}

/// Wraps content in a classed box, for the ViewModifier tests.
private struct Boxed: ViewModifier {

    // MARK: - Properties

    /// An extra class for the box.
    let tone: String

    // MARK: - ViewModifier

    /// Wraps `content` in a box.
    /// - Parameter content: The view the modifier is applied to.
    /// - Returns: The boxed content.
    func body(content: Self.Content) -> some View {
        Div { content }.class("box", tone)
    }
}

/// Tests for the HTML5 elements, inputs and attributes.
final class HTML5ElementTests: XCTestCase {

    /// Checks inline text elements.
    func testInlineTextElements() {
        let html = Paragraph {
            Mark("hit")
            Keyboard("⌘K")
            "H"
            Subscript("2")
            "O x"
            Superscript("2")
            Abbreviation("CSS", title: "Cascading Style Sheets")
            Time("Saturday", dateTime: "2026-11-21")
        }
        .render()
        XCTAssertEqual(
            html,
            "<p><mark>hit</mark><kbd>⌘K</kbd>H<sub>2</sub>O x<sup>2</sup>"
                + "<abbr title=\"Cascading Style Sheets\">CSS</abbr>"
                + "<time datetime=\"2026-11-21\">Saturday</time></p>"
        )
    }

    /// Checks dialog.
    func testDialog() {
        XCTAssertEqual(Dialog(isPresented: true) { "Hi" }.render(), "<dialog open>Hi</dialog>")
        XCTAssertEqual(Dialog { "Hi" }.id("d").render(), "<dialog id=\"d\">Hi</dialog>")
        XCTAssertEqual(Form(method: .dialog) { Button("Close") }.render(),
                       "<form method=\"dialog\"><button type=\"submit\">Close</button></form>")
    }

    /// Checks table caption and spans.
    func testTableCaptionAndSpans() {
        let html = Table {
            TableCaption("Totals")
            TableRow {
                TableHeaderCell("Day", rowSpan: 2)
                TableCell("Sum", columnSpan: 3)
            }
        }
        .render()
        XCTAssertEqual(
            html,
            "<table><caption>Totals</caption><tr><th rowspan=\"2\">Day</th><td colspan=\"3\">Sum</td></tr></table>"
        )
    }

    /// Checks option group and data list.
    func testOptionGroupAndDataList() {
        let select = Select(name: "s") {
            OptionGroup("Hot") { Option("Tea") }
        }
        .render()
        XCTAssertEqual(select, "<select name=\"s\"><optgroup label=\"Hot\"><option value=\"Tea\">Tea</option></optgroup></select>")

        let field = TextField("Herb", name: "herb", list: "herbs").render()
        XCTAssertEqual(field, "<input type=\"text\" name=\"herb\" placeholder=\"Herb\" list=\"herbs\">")
        XCTAssertEqual(DataList(id: "herbs") { Option("Basil") }.render(),
                       "<datalist id=\"herbs\"><option value=\"Basil\">Basil</option></datalist>")
    }

    /// Checks meter and output.
    func testMeterAndOutput() {
        XCTAssertEqual(
            Meter(value: 0.7, low: 0.3, high: 0.8, optimum: 0.1, label: "70%").render(),
            "<meter value=\"0.7\" min=\"0\" max=\"1\" low=\"0.3\" high=\"0.8\" optimum=\"0.1\">70%</meter>"
        )
        XCTAssertEqual(Output("5", name: "sum", for: ["a", "b"]).render(), "<output name=\"sum\" for=\"a b\">5</output>")
    }

    /// Checks media.
    func testMedia() {
        let video = Video(poster: "/p.jpg", options: [.controls, .muted, .playsInline]) {
            Source(src: "/v.webm", type: "video/webm")
            Track(src: "/v.vtt", language: "en", label: "English", isDefault: true)
            "Fallback"
        }
        .render()
        XCTAssertEqual(
            video,
            "<video poster=\"/p.jpg\" controls muted playsinline>"
                + "<source src=\"/v.webm\" type=\"video/webm\">"
                + "<track src=\"/v.vtt\" kind=\"captions\" srclang=\"en\" label=\"English\" default>"
                + "Fallback</video>"
        )
        XCTAssertEqual(Audio(src: "/a.mp3", options: [.controls, .playsInline]).render(), "<audio src=\"/a.mp3\" controls></audio>")

        let picture = Picture {
            Source(srcset: "/a.avif", type: "image/avif")
            Image(src: "/a.jpg", alt: "A")
        }
        .render()
        XCTAssertEqual(picture, "<picture><source srcset=\"/a.avif\" type=\"image/avif\"><img src=\"/a.jpg\" alt=\"A\"></picture>")
    }

    /// Checks iframe and svg.
    func testIFrameAndSVG() {
        XCTAssertEqual(
            IFrame(src: "/map", title: "Map", height: 200, sandbox: "").render(),
            "<iframe src=\"/map\" title=\"Map\" height=\"200\" loading=\"lazy\" sandbox=\"\"></iframe>"
        )
        let svg = SVG(viewBox: "0 0 10 10", width: 10, label: "Dot") {
            Element("circle", attributes: ["r": "5"])
        }
        .render()
        XCTAssertEqual(
            svg,
            "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 10 10\" width=\"10\" role=\"img\" aria-label=\"Dot\"><circle r=\"5\"></circle></svg>"
        )
        XCTAssertTrue(SVG(viewBox: "0 0 1 1") { EmptyView() }.render().contains("aria-hidden=\"true\""))
    }

    /// Checks typed inputs.
    func testTypedInputs() {
        XCTAssertEqual(Checkbox(name: "a", isChecked: true).render(), "<input type=\"checkbox\" name=\"a\" value=\"on\" checked>")
        XCTAssertEqual(RadioButton(name: "r", value: "x", id: "rx").render(), "<input type=\"radio\" name=\"r\" id=\"rx\" value=\"x\">")
        XCTAssertEqual(NumberField(name: "n", value: 2, min: 0, max: 10, step: 0.5).render(),
                       "<input type=\"number\" name=\"n\" value=\"2\" min=\"0\" max=\"10\" step=\"0.5\">")
        XCTAssertEqual(RangeField(name: "v", value: 5, in: 0...10).render(),
                       "<input type=\"range\" name=\"v\" min=\"0\" max=\"10\" value=\"5\">")
        XCTAssertEqual(DateField(name: "d", value: "2026-11-21", min: "2026-11-01").render(),
                       "<input type=\"date\" name=\"d\" value=\"2026-11-21\" min=\"2026-11-01\">")
        XCTAssertEqual(EmailField(name: "e", multiple: true).render(),
                       "<input type=\"email\" name=\"e\" autocomplete=\"email\" multiple>")
        XCTAssertEqual(FileField(name: "f", accept: ["image/*", ".pdf"], multiple: true).render(),
                       "<input type=\"file\" name=\"f\" accept=\"image/*,.pdf\" multiple>")
    }

    /// Checks attribute modifiers.
    func testAttributeModifiers() {
        let html = Div { "x" }.title("Tip").tabIndex(0).lang("fr").hidden().disabled().render()
        XCTAssertEqual(html, "<div title=\"Tip\" tabindex=\"0\" lang=\"fr\" hidden disabled>x</div>")
        XCTAssertEqual(Div { "x" }.hidden(false).render(), "<div>x</div>")
    }

    /// Checks link target and rel.
    func testLinkTargetAndRel() {
        XCTAssertEqual(Link("A", destination: "/a", target: .blank).render(),
                       "<a href=\"/a\" target=\"_blank\" rel=\"noopener\">A</a>")
        XCTAssertEqual(Link("A", destination: "/a", target: .blank, relationship: "external nofollow").render(),
                       "<a href=\"/a\" target=\"_blank\" rel=\"external nofollow\">A</a>")
        XCTAssertEqual(Link("A", destination: "/a", relationship: "me").render(), "<a href=\"/a\" rel=\"me\">A</a>")
    }
}

/// Tests for the SwiftUI-style containers, controls and modifiers.
final class SwiftUIStyleTests: XCTestCase {

    /// Checks ZStack writes support style once.
    func testZStackWritesSupportStyleOnce() {
        let html = Div {
            ZStack(alignment: .bottomLeading) { "a"; "b" }.class("hero")
            ZStack { "c" }
        }
        .render()
        XCTAssertEqual(html.components(separatedBy: "<style>").count - 1, 1)
        XCTAssertTrue(html.contains("<div class=\"svui-zstack hero\" style=\"place-items: end start\">ab</div>"))
        XCTAssertTrue(html.contains("<div class=\"svui-zstack\" style=\"place-items: center center\">c</div>"))
    }

    /// Checks support styles in head suppresses inline styles.
    func testSupportStylesInHeadSuppressesInlineStyles() {
        let html = Div {
            SupportStyles()
            ZStack { "a" }
            Menu("M") { "x" }
        }
        .render()
        XCTAssertEqual(html.components(separatedBy: "<style>").count - 1, 1)
    }

    /// Checks grid.
    func testGrid() {
        let html = Grid(horizontalSpacing: 16, verticalSpacing: 4) {
            GridRow { "a"; "b" }
            GridRow(alignment: .top) { "c"; "d" }
        }
        .render()
        XCTAssertTrue(html.hasPrefix("<style>"))
        XCTAssertTrue(html.contains(
            "<div class=\"svui-grid\" style=\"border-spacing: 16px 4px; --svui-valign: middle\">"
                + "<div class=\"svui-grid-row\">ab</div>"
                + "<div class=\"svui-grid-row\" style=\"--svui-valign: top\">cd</div></div>"
        ))
    }

    /// Checks lazy v grid.
    func testLazyVGrid() {
        XCTAssertEqual(
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120, maximum: 200))]) { "a" }.render(),
            "<div style=\"display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 200px)); gap: 8px\">a</div>"
        )
        let html = LazyVGrid(columns: [GridItem(.fixed(100)), GridItem(), GridItem(.adaptive(minimum: 120, maximum: 200))]) {
            "a"
        }
        .render()
        XCTAssertEqual(
            html,
            "<div style=\"display: grid; grid-template-columns: 100px minmax(0px, 1fr) "
                + "minmax(120px, 200px); gap: 8px\">a</div>"
        )
    }

    /// Checks scroll view.
    func testScrollView() {
        XCTAssertEqual(ScrollView { "a" }.render(),
                       "<div style=\"overflow-x: hidden; overflow-y: auto\" tabindex=\"0\">a</div>")
        XCTAssertEqual(ScrollView([.horizontal, .vertical], showsIndicators: false) { "a" }.render(),
                       "<div style=\"overflow: auto; scrollbar-width: none\" tabindex=\"0\">a</div>")
    }

    /// Checks divider.
    func testDivider() {
        XCTAssertEqual(Divider().render(), "<hr>")
    }

    /// Checks toggle applies modifiers to the control.
    func testToggleAppliesModifiersToTheControl() {
        XCTAssertEqual(
            Toggle("Notify me", name: "notify", isOn: true).disabled().render(),
            "<label class=\"svui-control\"><input type=\"checkbox\" name=\"notify\" value=\"on\" checked disabled>"
                + "<span class=\"svui-control-title\">Notify me</span></label>"
        )
    }

    /// Checks picker styles.
    func testPickerStyles() {
        let menu = Picker("Spice", name: "spice", selection: "hot", options: ["mild", PickerOption("Hot!", value: "hot")])
            .class("wide")
            .render()
        XCTAssertEqual(
            menu,
            "<label class=\"svui-control\"><span class=\"svui-control-title\">Spice</span>"
                + "<select name=\"spice\" class=\"wide\"><option value=\"mild\">mild</option>"
                + "<option value=\"hot\" selected>Hot!</option></select></label>"
        )

        let radios = Picker("Size", name: "size", selection: "s", style: .radioGroup, options: ["s", "m"]).render()
        XCTAssertTrue(radios.hasPrefix("<fieldset class=\"svui-radio-group\"><legend>Size</legend>"))
        XCTAssertTrue(radios.contains("<input type=\"radio\" name=\"size\" value=\"s\" checked>"))
        XCTAssertTrue(radios.contains("<input type=\"radio\" name=\"size\" value=\"m\">"))
    }

    /// Checks slider and stepper.
    func testSliderAndStepper() {
        let slider = Slider("Volume", name: "v", value: 40, showsValue: true).render()
        XCTAssertTrue(slider.contains(
            "<input type=\"range\" name=\"v\" min=\"0\" max=\"100\" value=\"40\" oninput=\"this.nextElementSibling.value=this.value\"><output>40</output>"
        ))
        let stepper = Stepper("Guests", name: "g", value: 2, in: 1...12, step: 2).render()
        XCTAssertTrue(stepper.contains("<input type=\"number\" name=\"g\" value=\"2\" min=\"1\" max=\"12\" step=\"2\">"))
    }

    /// Checks date picker.
    func testDatePicker() throws {
        let date = try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-11-21T18:05:00Z"))
        XCTAssertTrue(DatePicker("Day", name: "d", selection: date).render()
            .contains("<input type=\"date\" name=\"d\" value=\"2026-11-21\">"))
        XCTAssertTrue(DatePicker("At", name: "t", selection: date, displayedComponents: .hourAndMinute).render()
            .contains("<input type=\"time\" name=\"t\" value=\"18:05\">"))
        XCTAssertTrue(DatePicker("When", name: "w", selection: date, in: date...date, displayedComponents: [.date, .hourAndMinute]).render()
            .contains("<input type=\"datetime-local\" name=\"w\" value=\"2026-11-21T18:05\" min=\"2026-11-21T18:05\" max=\"2026-11-21T18:05\">"))
    }

    /// Checks progress view.
    func testProgressView() {
        XCTAssertEqual(ProgressView().render(), "<progress></progress>")
        XCTAssertEqual(ProgressView(value: 3, total: 8).render(), "<progress value=\"3\" max=\"8\">38%</progress>")
        XCTAssertEqual(ProgressView(value: 2, total: 0).render(), "<progress value=\"0\" max=\"0\"></progress>")
        XCTAssertTrue(ProgressView("Upload", value: 0.5).render().contains("<span class=\"svui-control-title\">Upload</span>"))
    }

    /// Checks disclosure group menu and navigation link.
    func testDisclosureGroupMenuAndNavigationLink() {
        XCTAssertEqual(DisclosureGroup("More", isExpanded: true) { "x" }.render(),
                       "<details open=\"\"><summary>More</summary>x</details>")
        XCTAssertTrue(Menu("Share") { Link("A", destination: "/a") }.render().hasSuffix(
            "<details class=\"svui-menu\"><summary>Share</summary><div class=\"svui-menu-items\" role=\"menu\"><a href=\"/a\">A</a></div></details>"
        ))
        XCTAssertEqual(NavigationLink("Map", destination: "/map", isActive: true).render(),
                       "<a href=\"/map\" aria-current=\"page\">Map</a>")
    }

    /// Checks tab view.
    func testTabView() {
        let html = TabView(id: "info", selection: 1) {
            Tab("Menu") { "m" }
            Tab("Hours") { "h" }.class("hours")
        }
        .class("tabs")
        .render()
        XCTAssertTrue(html.hasPrefix("<style>"))
        XCTAssertTrue(html.contains(
            "<div class=\"svui-tabs tabs\" id=\"info\">"
                + "<input type=\"radio\" class=\"svui-tab-input\" name=\"info\" id=\"info-tab-0\">"
                + "<label class=\"svui-tab\" for=\"info-tab-0\">Menu</label>"
                + "<div class=\"svui-tab-panel\" role=\"tabpanel\" aria-labelledby=\"info-tab-0\">m</div>"
                + "<input type=\"radio\" class=\"svui-tab-input\" name=\"info\" id=\"info-tab-1\" checked>"
                + "<label class=\"svui-tab\" for=\"info-tab-1\">Hours</label>"
                + "<div class=\"svui-tab-panel hours\" role=\"tabpanel\" aria-labelledby=\"info-tab-1\">h</div></div>"
        ))
    }

    /// Checks tab outside tab view is a section.
    func testTabOutsideTabViewIsASection() {
        XCTAssertEqual(Tab("Alone") { "x" }.render(), "<section><h3>Alone</h3>x</section>")
    }

    /// Checks nested tab views keep their own counts.
    func testNestedTabViewsKeepTheirOwnCounts() {
        let html = TabView(id: "outer") {
            Tab("A") {
                TabView(id: "inner") { Tab("X") { "x" }; Tab("Y") { "y" } }
            }
            Tab("B") { "b" }
        }
        .render()
        XCTAssertTrue(html.contains("id=\"outer-tab-1\""))
        XCTAssertTrue(html.contains("id=\"inner-tab-1\""))
        XCTAssertFalse(html.contains("outer-tab-2"))
    }

    /// Checks border and shadow.
    func testBorderAndShadow() {
        XCTAssertEqual(Div { "x" }.border(.gray, width: 2).shadow(radius: 4, y: 2).render(),
                       "<div style=\"border: 2px solid gray; box-shadow: 0px 2px 4px rgb(0 0 0 / 33%)\">x</div>")
    }

    /// Checks opacity.
    func testOpacity() {
        XCTAssertEqual(Span("x").opacity(0.5).render(), "<span style=\"opacity: 0.5\">x</span>")
    }
}

/// Tests for ViewModifier, AnyView and the environment.
final class CompositionTests: XCTestCase {

    /// Checks view modifier.
    func testViewModifier() {
        XCTAssertEqual(Paragraph("Hi").modifier(Boxed(tone: "warm")).render(),
                       "<div class=\"box warm\"><p>Hi</p></div>")
        XCTAssertEqual(Paragraph("Hi").modifier(Boxed(tone: "warm")).id("b").render(),
                       "<div class=\"box warm\" id=\"b\"><p>Hi</p></div>")
    }

    /// Checks any view erases different types.
    func testAnyViewErasesDifferentTypes() {
        let views: [AnyView] = [AnyView(Strong("a")), AnyView(Text("b")), AnyView(AnyView(Emphasis("c")))]
        XCTAssertEqual(ForEach(views) { $0 }.render(), "<strong>a</strong>b<em>c</em>")
    }

    /// Checks environment flows down and is scoped.
    func testEnvironmentFlowsDownAndIsScoped() {
        let html = Div {
            AccentLabel()
            Div {
                AccentLabel()
                Div { AccentLabel() }.environment(\.theme, Theme(accent: "green"))
            }
            .environment(\.theme, Theme(accent: "purple"))
            AccentLabel()
            EnvironmentReader(\.theme) { theme in Text(theme.accent) }
        }
        .render()
        XCTAssertEqual(
            html,
            "<div><span>blue</span><div><span>purple</span><div><span>green</span></div></div><span>blue</span>blue</div>"
        )
    }

    /// Checks environment modifier keeps attribute modifiers.
    func testEnvironmentModifierKeepsAttributeModifiers() {
        XCTAssertEqual(AccentLabel().environment(\.theme, Theme(accent: "red")).class("x").render(),
                       "<span class=\"x\">red</span>")
    }

    /// Checks an optional environment value falls back to its default.
    func testOptionalEnvironmentDefault() {
        XCTAssertEqual(EnvironmentValues()[GreetingKey.self], "Hello")
        var values = EnvironmentValues()
        values[GreetingKey.self] = nil
        XCTAssertNil(values[GreetingKey.self])
    }
}

/// Tests for the fixes from code review.
final class ReviewFixTests: XCTestCase {

    /// Checks a tab inside another tab's panel does not join the outer tab view.
    func testTabInsidePanelDoesNotJoinOuterGroup() {
        let html = TabView(id: "outer") {
            Tab("A") { Tab("Inner") { "i" } }
            Tab("B") { "b" }
        }
        .render()
        XCTAssertTrue(html.contains("<section><h3>Inner</h3>i</section>"))
        XCTAssertTrue(html.contains("id=\"outer-tab-1\""))
        XCTAssertFalse(html.contains("outer-tab-2"))
    }

    /// Checks an adaptive column used with other columns becomes one valid track.
    func testLazyVGridMixedAdaptiveColumns() {
        let html = LazyVGrid(columns: [GridItem(.adaptive(minimum: 100)), GridItem()]) { "a" }.render()
        XCTAssertTrue(html.contains("grid-template-columns: minmax(100px, 1fr) minmax(0px, 1fr)"))
        XCTAssertFalse(html.contains("repeat("))
    }

    /// Checks a scroll view with no axes does not scroll.
    func testScrollViewWithNoAxes() {
        XCTAssertTrue(ScrollView([]) { "a" }.render().contains("style=\"overflow: hidden\""))
    }

    /// Checks SupportStyles passes modifiers on to the next element.
    func testSupportStylesKeepsModifiers() {
        let html = Group {
            SupportStyles()
            Div { "x" }
        }
        .class("page")
        .render()
        XCTAssertTrue(html.hasSuffix("<div class=\"page\">x</div>"))
    }

    /// Checks a document puts the support styles its body needs in the head.
    func testDocumentWritesSupportStylesInHead() {
        let html = Page(title: "T") {
            ZStack { "a" }
            ZStack { "b" }
        }
        .render()
        let head = html.components(separatedBy: "</head>")[0]
        let body = html.components(separatedBy: "</head>")[1]
        XCTAssertTrue(head.contains(".svui-zstack{display:grid}"))
        XCTAssertFalse(body.contains("<style>"))
        XCTAssertEqual(html.components(separatedBy: "<style>").count - 1, 1)
    }

    /// Checks support styles written inside a template are written again outside it.
    func testTemplateDoesNotUseUpSupportStyles() {
        let html = Div {
            Template { ZStack { "a" } }
            ZStack { "b" }
        }
        .render()
        XCTAssertEqual(html.components(separatedBy: "<style>").count - 1, 2)
    }
}
