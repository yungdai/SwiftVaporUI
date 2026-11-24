import SwiftVaporUI
import XCTest

/// Tests for form encodings, field constraints and button overrides.
final class FormAttributeTests: XCTestCase {

    /// Checks `Form` writes `enctype` only when an encoding is given.
    func testFormEncoding() {
        XCTAssertEqual(Form(action: "/a") {}.render(), #"<form method="post" action="/a"></form>"#)
        XCTAssertEqual(
            Form(action: "/a", encoding: .multipart) {}.render(),
            #"<form method="post" action="/a" enctype="multipart/form-data"></form>"#
        )
        XCTAssertTrue(Form(encoding: .urlEncoded) {}.render().contains(#"enctype="application/x-www-form-urlencoded""#))
        XCTAssertTrue(Form(encoding: .plainText) {}.render().contains(#"enctype="text/plain""#))
    }

    /// Checks the field constraint and keyboard modifiers reach the input.
    func testFieldModifiers() {
        let html = TextField("Code", name: "code")
            .pattern("[A-Z]{2}[0-9]{4}")
            .minLength(6)
            .maxLength(6)
            .inputMode(.numeric)
            .enterKeyHint(.next)
            .render()
        XCTAssertEqual(
            html,
            #"<input type="text" name="code" placeholder="Code" pattern="[A-Z]{2}[0-9]{4}" minlength="6" maxlength="6" "#
                + #"inputmode="numeric" enterkeyhint="next">"#
        )
        XCTAssertTrue(Input(name: "x").minLength(-3).render().contains(#"minlength="0""#))
    }

    /// Checks every input mode and Enter key hint value.
    func testModeAndHintValues() {
        let modes: [InputMode] = [.none, .text, .decimal, .numeric, .tel, .search, .email, .url]
        XCTAssertEqual(modes.map(\.rawValue), ["none", "text", "decimal", "numeric", "tel", "search", "email", "url"])
        let hints: [EnterKeyHint] = [.enter, .done, .go, .next, .previous, .search, .send]
        XCTAssertEqual(hints.map(\.rawValue), ["enter", "done", "go", "next", "previous", "search", "send"])
    }

    /// Checks a pattern with quotes and angle brackets is escaped.
    func testPatternEscaping() {
        let html = Input(name: "x").pattern(#"[^"<>]+"#).render()
        XCTAssertTrue(html.contains(#"pattern="[^&quot;&lt;&gt;]+""#), html)
    }

    /// Checks the per-button overrides of the form's submission.
    func testButtonOverrides() {
        let html = Button("Delete")
            .formAction("/plants/fern/delete")
            .formMethod(.post)
            .formEncoding(.multipart)
            .formNoValidate()
            .render()
        XCTAssertEqual(
            html,
            #"<button type="submit" formaction="/plants/fern/delete" formmethod="post" formenctype="multipart/form-data" "#
                + #"formnovalidate>Delete</button>"#
        )
        XCTAssertFalse(Button("Save").formNoValidate(false).render().contains("formnovalidate"))
        XCTAssertTrue(Button("Close").formMethod(.dialog).render().contains(#"formmethod="dialog""#))
    }

}
