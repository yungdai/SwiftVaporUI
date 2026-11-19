import SwiftVaporUI
import XCTVapor
import XCTest

// This file imports XCTVapor, which brings in `Vapor.View` too. One
// module-level typealias settles which `View` the module means. Files that
// import only SwiftVaporUI do not need this.
typealias View = SwiftVaporUI.View

private struct Badge: View {
    let label: String

    var body: some View {
        Span(label).class("badge")
    }
}

private struct Card<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        Article {
            Heading(title, level: .h2)
            content
        }
        .class("card")
    }
}

private struct Checklist: View {
    let items: [String]
    let showEmptyState: Bool

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

final class RenderingTests: XCTestCase {
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

    func testEmptyBlockRendersNothingInside() {
        XCTAssertEqual(Div {}.render(), "<div></div>")
        XCTAssertEqual(EmptyView().render(), "")
    }

    func testTextIsEscaped() {
        let html = Paragraph("<script>alert('x') & \"y\"</script>").render()
        XCTAssertEqual(html, "<p>&lt;script&gt;alert('x') &amp; \"y\"&lt;/script&gt;</p>")
    }

    func testAttributeValuesAreEscaped() {
        let html = Div {}.attribute("title", "\" onmouseover=\"alert('x')").render()
        XCTAssertEqual(html, "<div title=\"&quot; onmouseover=&quot;alert(&#39;x&#39;)\"></div>")
    }

    func testUnsafeAttributeNamesAreDropped() {
        let html = Div {}
            .attribute("onclick=\"evil()\" x", "1")
            .attribute("data ok", "2")
            .attribute("hx-get", "/items")
            .render()
        XCTAssertEqual(html, "<div hx-get=\"/items\"></div>")
    }

    func testInvalidTagNameRendersContentOnly() {
        XCTAssertEqual(Element("div><script") { "hi" }.render(), "hi")
        XCTAssertEqual(Element("my-widget") { "hi" }.render(), "<my-widget>hi</my-widget>")
    }

    func testRawHTMLIsNotEscaped() {
        XCTAssertEqual(RawHTML("<b>trusted</b>").render(), "<b>trusted</b>")
    }

    func testScriptAndStyleCannotCloseEarly() {
        XCTAssertEqual(
            Script("let s = '</script><b>';").render(),
            "<script>let s = '<\\/script><b>';</script>"
        )
        XCTAssertEqual(Style("p{}</style>").render(), "<style>p{}<\\/style></style>")
    }

    func testIfElseAndLoops() {
        XCTAssertEqual(
            Checklist(items: ["Water", "Feed"], showEmptyState: true).render(),
            "<ul><li data-index=\"0\">Water</li><li data-index=\"1\">Feed</li></ul>"
        )
        XCTAssertEqual(Checklist(items: [], showEmptyState: true).render(), "<p>Nothing to do</p>")
        XCTAssertEqual(Checklist(items: [], showEmptyState: false).render(), "")
    }

    func testSwitchAndIfLet() {
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

    func testForEach() {
        let html = OrderedList {
            ForEach(1...3) { number in
                ListItem("Step \(number)")
            }
        }.render()
        XCTAssertEqual(html, "<ol><li>Step 1</li><li>Step 2</li><li>Step 3</li></ol>")
    }

    func testCustomViewsCompose() {
        let html = Card(title: "Plants") {
            Badge(label: "new")
        }.render()
        XCTAssertEqual(html, "<article class=\"card\"><h2>Plants</h2><span class=\"badge\">new</span></article>")
    }

    func testAnyView() {
        let views: [AnyView] = [AnyView(Text("a")), AnyView(Strong("b"))]
        XCTAssertEqual(ForEach(views) { $0 }.render(), "a<strong>b</strong>")
    }
}

final class ModifierTests: XCTestCase {
    func testClassesAccumulateAndDeduplicate() {
        let html = Div {}.class("a b").class("b", "c").class("hidden", when: false).render()
        XCTAssertEqual(html, "<div class=\"a b c\"></div>")
    }

    func testModifiersOnCustomViewReachItsElement() {
        let html = Badge(label: "x").class("large").id("main-badge").render()
        XCTAssertEqual(html, "<span class=\"badge large\" id=\"main-badge\">x</span>")
    }

    func testLastModifierWins() {
        XCTAssertEqual(Div {}.id("a").id("b").render(), "<div id=\"b\"></div>")
        XCTAssertEqual(
            Link("Home", destination: "/").attribute("href", "/start").render(),
            "<a href=\"/start\">Home</a>"
        )
    }

    func testAttributeRemoval() {
        XCTAssertEqual(Link("Home", destination: "/").attribute("href", nil).render(), "<a>Home</a>")
    }

    func testBooleanAttributes() {
        let html = Button("Save").disabled().hidden(false).render()
        XCTAssertEqual(html, "<button type=\"submit\" disabled>Save</button>")
    }

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

    func testModifierOnTextWrapsInSpan() {
        XCTAssertEqual(Text("hi").class("note").render(), "<span class=\"note\">hi</span>")
    }

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

final class ElementTests: XCTestCase {
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

    func testImageAndVoidElements() {
        XCTAssertEqual(
            Image(src: "/a.png", alt: "A \"cat\"", width: 10).render(),
            "<img src=\"/a.png\" alt=\"A &quot;cat&quot;\" width=\"10\">"
        )
        XCTAssertEqual(LineBreak().render(), "<br>")
        XCTAssertEqual(Divider().class("thin").render(), "<hr class=\"thin\">")
    }

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

final class StylingTests: XCTestCase {
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

    func testTextStylingWrapsInSpan() {
        XCTAssertEqual(
            Text("Hi").font(.headline).foregroundColor(.red).render(),
            "<span style=\"font-size: 17px; font-weight: 600; color: crimson\">Hi</span>"
        )
        XCTAssertEqual(Strong("x").italic().opacity(2).render(), "<strong style=\"font-style: italic; opacity: 1\">x</strong>")
    }

    func testStylesAreAttributeEscaped() {
        XCTAssertEqual(
            Div {}.foregroundColor(Color(css: "red\" onclick=\"x")).render(),
            "<div style=\"color: red&quot; onclick=&quot;x\"></div>"
        )
    }
}

final class VaporIntegrationTests: XCTestCase {
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
