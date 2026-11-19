@testable import DemoServer
import Foundation
import XCTest
import XCTVapor

/// Tests for the Plant Shelf store and its routes.
final class PlantShelfTests: XCTestCase {

    /// Checks names become slugs, with numbers for clashes and reserved routes.
    func testUniqueSlug() {
        XCTAssertEqual(PlantShelf.uniqueSlug(for: "Golden Pothos!", taken: []), "golden-pothos")
        XCTAssertEqual(PlantShelf.uniqueSlug(for: "🌿", taken: []), "plant")
        XCTAssertEqual(PlantShelf.uniqueSlug(for: "🌿", taken: ["plant"]), "plant-2")
        XCTAssertEqual(PlantShelf.uniqueSlug(for: "New", taken: []), "new-2")
        XCTAssertEqual(PlantShelf.uniqueSlug(for: "Fern", taken: ["fern", "fern-2"]), "fern-3")
    }

    /// Checks a name made only of newlines is rejected.
    func testNewlineOnlyNameIsInvalid() {
        var form = PlantForm()
        form.name = "\r\n"
        XCTAssertTrue(form.validate().contains("Give the plant a name."))
    }

    /// Checks adding a plant redirects to its page, which shows the confirmation.
    func testAddingAPlantRedirects() async throws {
        let app = try await Application.make(.testing)
        registerPlantShelfRoutes(app)
        try await app.test(.POST, "plants", beforeRequest: { req in
            try req.content.encode(["name": "New", "light": "low", "waterEveryDays": "5", "notes": ""], as: .urlEncodedForm)
        }, afterResponse: { res async throws in
            XCTAssertEqual(res.status, .seeOther)
            XCTAssertEqual(res.headers.first(name: .location), "/plants/new-2?added=1")
        })
        try await app.test(.GET, "plants/new-2?added=1") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertTrue(res.body.string.contains("New"))
        }
        try await app.asyncShutdown()
    }
}

/// Tests for the night market's form and data.
final class MarketTests: XCTestCase {

    /// Checks the visit form rejects blank names, including newline-only ones.
    func testVisitFormValidation() {
        XCTAssertNotNil(VisitForm(name: "\n\n", guests: "2", updates: nil).validate())
        XCTAssertNotNil(VisitForm(name: "Ada", guests: "9", updates: nil).validate())
        XCTAssertNil(VisitForm(name: "Ada", guests: "2", updates: nil).validate())
    }

    /// Checks schedule times convert to 24-hour `datetime` values.
    func testScheduleDateTime() {
        XCTAssertEqual(ScheduleSlot(time: "6:00 pm", title: "", place: "").dateTime, "18:00")
        XCTAssertEqual(ScheduleSlot(time: "12:30 am", title: "", place: "").dateTime, "00:30")
        XCTAssertEqual(ScheduleSlot(time: "11:00 am", title: "", place: "").dateTime, "11:00")
    }
}

/// Tests for the showcase's source reader and formatters.
final class ShowcaseToolTests: XCTestCase {

    /// Checks dedent removes shared indentation and blank edges.
    func testDedent() {
        XCTAssertEqual(SourceLibrary.dedent(["", "    a", "      b", ""]), ["a", "  b"])
    }

    /// Checks a snippet is read from this file between its markers.
    func testSnippetReadsMarkedRegion() {
        // snippet: test-region
        let marked = 1
        // end-snippet
        XCTAssertEqual(marked, 1)
        let snippet = SourceLibrary.shared.snippet("test-region", in: #filePath)
        XCTAssertEqual(snippet.code, "let marked = 1")
    }

    /// Checks an unreadable file does not reveal its absolute path.
    func testMissingFileHidesItsPath() {
        let snippet = SourceLibrary.shared.snippet("x", in: "/private/secret/Sources/DemoServer/Missing.swift")
        XCTAssertFalse(snippet.code.contains("/private/secret"))
        XCTAssertTrue(snippet.code.contains("Sources/DemoServer/Missing.swift"))
    }

    /// Checks number highlighting stops at member access and ranges.
    func testNumberHighlighting() {
        let html = SwiftHighlighter.highlight("$0.name; 1...3; 2.5")
        XCTAssertTrue(html.contains("<span class=\"tok-number\">0</span>"))
        XCTAssertTrue(html.contains("<span class=\"tok-number\">1</span>..."))
        XCTAssertTrue(html.contains("<span class=\"tok-number\">2.5</span>"))
    }
}
