import SwiftVaporUI
import XCTVapor
import XCTest

// This file imports XCTVapor, which brings in `Vapor.View` too. One
// module-level typealias settles which `View` the module means. Files that
// import only SwiftVaporUI do not need this.
/// This file imports XCTVapor too, so name the `View` it means.
typealias View = SwiftVaporUI.View

/// A badge, for the composition tests.
private struct Badge: View {

    // MARK: - Properties

    /// The badge text.
    let label: String

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Span(label).class("badge")
    }
}

/// A titled card around content, for the composition tests.
private struct Card<Content: View>: View {

    // MARK: - Properties

    /// The card's heading.
    let title: String

    /// The card's body.
    let content: Content

    // MARK: - Initializer

    /// Creates a card.
    /// - Parameters:
    ///   - title: The card's heading.
    ///   - content: A view builder that creates the card's body.
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Article {
            Heading(title, level: .h2)
            content
        }
        .class("card")
    }
}

/// A list with an empty state, for the conditional tests.
private struct Checklist: View {

    // MARK: - Properties

    /// The items to list.
    let items: [String]

    /// Whether to show a message when there are no items.
    let showEmptyState: Bool

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        if items.isEmpty {
            if showEmptyState {
                Paragraph("Nothing to do")
            }
        } else {
            UnorderedList {
                for (index, item) in items.enumerated() {
                    ListItem(item).data("index", "\(index)")
                }
            }
        }
    }
}

/// Tests for rendering, escaping and the result builder.
final class RenderingTests: XCTestCase {

    /// Checks elements and text.
    func testElementsAndText() {
        let html = Div {
            Heading("Title")
            Paragraph {
                "Some "
                Strong("bold")
                " text"
            }
        }.render()
        XCTAssertEqual(html, "<div><h1>Title</h1><p>Some <strong>bold</strong> text</p></div>")
    }

    /// Checks empty block renders nothing inside.
    func testEmptyBlockRendersNothingInside() {
        XCTAssertEqual(Div {}.render(), "<div></div>")
        XCTAssertEqual(EmptyView().render(), "")
    }

    /// Checks text is escaped.
    func testTextIsEscaped() {
        let html = Paragraph("<script>alert('x') & \"y\"</script>").render()
        XCTAssertEqual(html, "<p>&lt;script&gt;alert('x') &amp; \"y\"&lt;/script&gt;</p>")
    }

    /// Checks attribute values are escaped.
    func testAttributeValuesAreEscaped() {
        let html = Div {}.attribute("title", "\" onmouseover=\"alert('x')").render()
        XCTAssertEqual(html, "<div title=\"&quot; onmouseover=&quot;alert(&#39;x&#39;)\"></div>")
    }

    /// Checks unsafe attribute names are dropped.
    func testUnsafeAttributeNamesAreDropped() {
        let html = Div {}
            .attribute("onclick=\"evil()\" x", "1")
            .attribute("data ok", "2")
            .attribute("hx-get", "/items")
            .render()
        XCTAssertEqual(html, "<div hx-get=\"/items\"></div>")
    }

    /// Checks invalid tag name renders content only.
    func testInvalidTagNameRendersContentOnly() {
        XCTAssertEqual(Element("div><script") { "hi" }.render(), "hi")
        XCTAssertEqual(Element("my-widget") { "hi" }.render(), "<my-widget>hi</my-widget>")
    }

    /// Checks raw HTML is not escaped.
    func testRawHTMLIsNotEscaped() {
        XCTAssertEqual(RawHTML("<b>trusted</b>").render(), "<b>trusted</b>")
    }

    /// Checks script and style cannot close early.
    func testScriptAndStyleCannotCloseEarly() {
        XCTAssertEqual(
            Script("let s = '</script><b>';").render(),
            "<script>let s = '<\\/script><b>';</script>"
        )
        XCTAssertEqual(Style("p{}</style>").render(), "<style>p{}<\\/style></style>")
    }

    /// Checks if else and loops.
    func testIfElseAndLoops() {
        XCTAssertEqual(
            Checklist(items: ["Water", "Feed"], showEmptyState: true).render(),
            "<ul><li data-index=\"0\">Water</li><li data-index=\"1\">Feed</li></ul>"
        )
        XCTAssertEqual(Checklist(items: [], showEmptyState: true).render(), "<p>Nothing to do</p>")
        XCTAssertEqual(Checklist(items: [], showEmptyState: false).render(), "")
    }

    /// Checks switch and if let.
    func testSwitchAndIfLet() {
        /// Describes a status code.
        /// - Parameter code: The code, or `nil`.
        /// - Returns: A view for the code.
        func status(_ code: Int?) -> some View {
            Div {
                if let code {
                    switch code {
                    case 200: Text("ok")
                    case 404: Strong("missing")
                    default: Emphasis("other")
                    }
                }
            }
        }
        XCTAssertEqual(status(200).render(), "<div>ok</div>")
        XCTAssertEqual(status(404).render(), "<div><strong>missing</strong></div>")
        XCTAssertEqual(status(500).render(), "<div><em>other</em></div>")
        XCTAssertEqual(status(nil).render(), "<div></div>")
    }

    /// Checks for each.
    func testForEach() {
        let html = OrderedList {
            ForEach(1...3) { number in
                ListItem("Step \(number)")
            }
        }.render()
        XCTAssertEqual(html, "<ol><li>Step 1</li><li>Step 2</li><li>Step 3</li></ol>")
    }

    /// Checks custom views compose.
    func testCustomViewsCompose() {
        let html = Card(title: "Plants") {
            Badge(label: "new")
        }.render()
        XCTAssertEqual(html, "<article class=\"card\"><h2>Plants</h2><span class=\"badge\">new</span></article>")
    }

    /// Checks any view.
    func testAnyView() {
        let views: [AnyView] = [AnyView(Text("a")), AnyView(Strong("b"))]
        XCTAssertEqual(ForEach(views) { $0 }.render(), "a<strong>b</strong>")
    }
}

/// Tests for attribute modifiers.
final class ModifierTests: XCTestCase {

    /// Checks classes accumulate and deduplicate.
    func testClassesAccumulateAndDeduplicate() {
        let html = Div {}.class("a b").class("b", "c").class("hidden", when: false).render()
        XCTAssertEqual(html, "<div class=\"a b c\"></div>")
    }

    /// Checks modifiers on custom view reach its element.
    func testModifiersOnCustomViewReachItsElement() {
        let html = Badge(label: "x").class("large").id("main-badge").render()
        XCTAssertEqual(html, "<span class=\"badge large\" id=\"main-badge\">x</span>")
    }

    /// Checks last modifier wins.
    func testLastModifierWins() {
        XCTAssertEqual(Div {}.id("a").id("b").render(), "<div id=\"b\"></div>")
        XCTAssertEqual(
            Link("Home", destination: "/").attribute("href", "/start").render(),
            "<a href=\"/start\">Home</a>"
        )
    }

    /// Checks attribute removal.
    func testAttributeRemoval() {
        XCTAssertEqual(Link("Home", destination: "/").attribute("href", nil).render(), "<a>Home</a>")
    }

    /// Checks boolean attributes.
    func testBooleanAttributes() {
        let html = Button("Save").disabled().hidden(false).render()
        XCTAssertEqual(html, "<button type=\"submit\" disabled>Save</button>")
    }

    /// Checks role aria data and style.
    func testRoleAriaDataAndStyle() {
        let html = Nav {}
            .role("navigation")
            .aria("label", "Main")
            .data("state", "open")
            .style("color", "red")
            .style("margin: 0;")
            .render()
        XCTAssertEqual(
            html,
            "<nav role=\"navigation\" aria-label=\"Main\" data-state=\"open\" style=\"color: red; margin: 0\"></nav>"
        )
    }

    /// Checks modifier on text wraps in span.
    func testModifierOnTextWrapsInSpan() {
        XCTAssertEqual(Text("hi").class("note").render(), "<span class=\"note\">hi</span>")
    }

    /// Checks modifier does not leak to children or siblings.
    func testModifierDoesNotLeakToChildrenOrSiblings() {
        let html = Div {
            Group {
                EmptyView()
            }
            .id("ghost")
            Span("after")
        }
        .class("outer")
        .render()
        XCTAssertEqual(html, "<div class=\"outer\"><span>after</span></div>")
    }

    /// Checks modifier on group applies to first element.
    func testModifierOnGroupAppliesToFirstElement() {
        let html = Group {
            Paragraph("one")
            Paragraph("two")
        }
        .class("first")
        .render()
        XCTAssertEqual(html, "<p class=\"first\">one</p><p>two</p>")
    }
}

/// Tests for the element views.
final class ElementTests: XCTestCase {

    /// Checks form controls.
    func testFormControls() {
        let html = Form(action: "/signup") {
            Label("Email", for: "email")
            TextField("you@example.com", name: "email", text: "a&b", type: .email).id("email").required()
            SecureField("Password", name: "password")
            Select(name: "plan") {
                Option("Free", value: "free")
                Option("Pro", value: "pro", selected: true)
            }
            TextArea(name: "bio", text: "<hi>", rows: 3)
            Button("Join")
        }.render()
        XCTAssertEqual(
            html,
            "<form method=\"post\" action=\"/signup\">"
                + "<label for=\"email\">Email</label>"
                + "<input type=\"email\" name=\"email\" value=\"a&amp;b\" placeholder=\"you@example.com\" id=\"email\" required>"
                + "<input type=\"password\" name=\"password\" placeholder=\"Password\">"
                + "<select name=\"plan\"><option value=\"free\">Free</option><option value=\"pro\" selected>Pro</option></select>"
                + "<textarea name=\"bio\" rows=\"3\">&lt;hi&gt;</textarea>"
                + "<button type=\"submit\">Join</button>"
                + "</form>"
        )
    }

    /// Checks image and void elements.
    func testImageAndVoidElements() {
        XCTAssertEqual(
            Image(src: "/a.png", alt: "A \"cat\"", width: 10).render(),
            "<img src=\"/a.png\" alt=\"A &quot;cat&quot;\" width=\"10\">"
        )
        XCTAssertEqual(LineBreak().render(), "<br>")
        XCTAssertEqual(Divider().class("thin").render(), "<hr class=\"thin\">")
    }

    /// Checks stacks.
    func testStacks() {
        XCTAssertEqual(
            HStack(spacing: 8) { Span("a"); Spacer(); Span("b") }.render(),
            "<div style=\"display: flex; flex-direction: row; align-items: center; gap: 8px\">"
                + "<span>a</span><div style=\"flex: 1\"></div><span>b</span></div>"
        )
        XCTAssertEqual(
            VStack(alignment: .leading) {}.style("padding", "4px").render(),
            "<div style=\"display: flex; flex-direction: column; align-items: flex-start; padding: 4px\"></div>"
        )
        XCTAssertEqual(VStack { Span("a") }.class("stack").render(), "<div class=\"stack\"><span>a</span></div>")
        XCTAssertEqual(
            VStack(spacing: 4.5) {}.render(),
            "<div style=\"display: flex; flex-direction: column; gap: 4.5px\"></div>"
        )
        XCTAssertEqual(
            NavigationBar { Link("Home", destination: "/") }.render(),
            "<nav style=\"display: flex; flex-direction: row; align-items: center; gap: 16px\"><a href=\"/\">Home</a></nav>"
        )
    }

    /// Checks button actions.
    func testButtonActions() {
        XCTAssertEqual(Button("Go").render(), "<button type=\"submit\">Go</button>")
        XCTAssertEqual(Button("Clear", action: .reset).render(), "<button type=\"reset\">Clear</button>")
        XCTAssertEqual(Button("Menu", action: .plain).render(), "<button type=\"button\">Menu</button>")
        XCTAssertEqual(
            Button("Back", action: .navigate(to: "/?a=1&b=2")).class("btn").render(),
            "<a href=\"/?a=1&amp;b=2\" class=\"btn\">Back</a>"
        )
        XCTAssertEqual(
            Button("Hi", action: .script("alert(\"hi\")")).render(),
            "<button type=\"button\" onclick=\"alert(&quot;hi&quot;)\">Hi</button>"
        )
    }

    /// Checks text field without placeholder.
    func testTextFieldWithoutPlaceholder() {
        XCTAssertEqual(
            TextField(name: "user", id: "user", autocomplete: "username").render(),
            "<input type=\"text\" name=\"user\" id=\"user\" autocomplete=\"username\">"
        )
        XCTAssertEqual(
            SecureField(name: "pw", id: "pw", autocomplete: "current-password").render(),
            "<input type=\"password\" name=\"pw\" id=\"pw\" autocomplete=\"current-password\">"
        )
    }

    /// Checks list and description list.
    func testListAndDescriptionList() {
        XCTAssertEqual(
            List(["a", "<b>"]) { Text($0) }.class("items").render(),
            "<ul class=\"items\"><li>a</li><li>&lt;b&gt;</li></ul>"
        )
        XCTAssertEqual(
            DescriptionList {
                DescriptionTerm("Light")
                DescriptionDetail("Bright")
            }.render(),
            "<dl><dt>Light</dt><dd>Bright</dd></dl>"
        )
        XCTAssertEqual(Template { Span("x") }.render(), "<template><span>x</span></template>")
    }

    /// Checks hand built document and page.
    func testHandBuiltDocumentAndPage() {
        let html = Document {
            HTMLRoot(language: "fr") {
                Head {
                    Title("A < B")
                    ResourceLink(relationship: "icon", destination: "/favicon.svg")
                }
                DocumentBody { "Bonjour" }.class("home")
            }
        }.render()
        XCTAssertEqual(
            html,
            "<!DOCTYPE html><html lang=\"fr\"><head><title>A &lt; B</title>"
                + "<link rel=\"icon\" href=\"/favicon.svg\"></head><body class=\"home\">Bonjour</body></html>"
        )
        XCTAssertTrue(Page(title: "Hi") { Paragraph("x") }.render().hasSuffix("<body><p>x</p></body></html>"))
    }

    /// Checks document.
    func testDocument() {
        let html = HTMLDocument(title: "Tom & Jerry") {
            Stylesheet(href: "/app.css")
        } body: {
            Main { Heading("Hi") }
        }
        .class("dark")
        .render()
        XCTAssertEqual(
            html,
            "<!DOCTYPE html><html lang=\"en\" class=\"dark\"><head>"
                + "<meta charset=\"utf-8\">"
                + "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
                + "<title>Tom &amp; Jerry</title>"
                + "<link rel=\"stylesheet\" href=\"/app.css\">"
                + "</head><body><main><h1>Hi</h1></main></body></html>"
        )
    }
}

/// Tests for the styling modifiers.
final class StylingTests: XCTestCase {

    /// Checks styling modifiers add inline style.
    func testStylingModifiersAddInlineStyle() {
        let html = Div {}
            .padding()
            .background(.hex("eef"))
            .cornerRadius(8)
            .frame(width: 120.5)
            .render()
        XCTAssertEqual(
            html,
            "<div style=\"padding: 16px; background: #eef; border-radius: 8px; width: 120.5px\"></div>"
        )
    }

    /// Checks padding edges.
    func testPaddingEdges() {
        XCTAssertEqual(
            Div {}.padding(.vertical, 4).render(),
            "<div style=\"padding-top: 4px; padding-bottom: 4px\"></div>"
        )
        XCTAssertEqual(
            Div {}.padding(.leading, 2).render(),
            "<div style=\"padding-inline-start: 2px\"></div>"
        )
    }

    /// Checks text styling wraps in span.
    func testTextStylingWrapsInSpan() {
        XCTAssertEqual(
            Text("Hi").font(.headline).foregroundColor(.red).render(),
            "<span style=\"font-size: 17px; font-weight: 600; color: crimson\">Hi</span>"
        )
        XCTAssertEqual(Strong("x").italic().opacity(2).render(), "<strong style=\"font-style: italic; opacity: 1\">x</strong>")
    }

    /// Checks styles are attribute escaped.
    func testStylesAreAttributeEscaped() {
        XCTAssertEqual(
            Div {}.foregroundColor(Color(css: "red\" onclick=\"x")).render(),
            "<div style=\"color: red&quot; onclick=&quot;x\"></div>"
        )
    }
}

/// Tests for returning views from Vapor routes.
final class VaporIntegrationTests: XCTestCase {

    /// Checks route returning view is HTML.
    func testRouteReturningViewIsHTML() async throws {
        let app = try await Application.make(.testing)
        app.get("badge") { _ in Badge(label: "<ok>") }
        app.get("missing") { _ in
            HTMLResponse(status: .notFound) { Paragraph("Not here") }
        }

        try await app.test(.GET, "badge") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .html)
            XCTAssertEqual(res.body.string, "<span class=\"badge\">&lt;ok&gt;</span>")
        }
        try await app.test(.GET, "missing") { res async in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.headers.contentType, .html)
            XCTAssertEqual(res.body.string, "<p>Not here</p>")
        }
        try await app.asyncShutdown()
    }
}
