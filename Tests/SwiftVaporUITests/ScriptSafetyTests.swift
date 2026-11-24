import SwiftVaporUI
import XCTest
import XCTVapor

/// Tests for CSP nonces and Subresource Integrity on scripts and styles.
final class ScriptSafetyTests: XCTestCase {

    /// Checks integrity hashes add `crossorigin="anonymous"` unless told otherwise.
    func testIntegrity() {
        XCTAssertEqual(
            Script(src: "https://cdn.example.com/a.js", defer: true, integrity: "sha384-abc").render(),
            #"<script src="https://cdn.example.com/a.js" defer integrity="sha384-abc" crossorigin="anonymous"></script>"#
        )
        XCTAssertEqual(
            Script(src: "/a.js", crossOrigin: .useCredentials).render(),
            #"<script src="/a.js" crossorigin="use-credentials"></script>"#
        )
        XCTAssertEqual(Script(src: "/a.js").render(), #"<script src="/a.js"></script>"#)
        XCTAssertEqual(
            Stylesheet(href: "https://cdn.example.com/a.css", integrity: "sha384-abc").render(),
            #"<link rel="stylesheet" href="https://cdn.example.com/a.css" integrity="sha384-abc" crossorigin="anonymous">"#
        )
        XCTAssertEqual(Stylesheet(href: "/a.css").render(), #"<link rel="stylesheet" href="/a.css">"#)
    }

    /// Checks an explicit nonce is written on inline and external scripts and on styles.
    func testExplicitNonce() {
        XCTAssertEqual(Script("go()", nonce: "n1").render(), #"<script nonce="n1">go()</script>"#)
        XCTAssertEqual(Script(src: "/a.js", nonce: "n1").render(), #"<script src="/a.js" nonce="n1"></script>"#)
        XCTAssertEqual(Style("p{}", nonce: "n1").render(), #"<style nonce="n1">p{}</style>"#)
        XCTAssertEqual(Style("p{}").render(), "<style>p{}</style>")
    }

    /// Checks the environment's nonce reaches scripts, styles and support styles, and an explicit one wins.
    func testEnvironmentNonce() {
        let html = Group {
            Script("go()")
            Style("p{}")
            Script("other()", nonce: "own")
            ZStack { Text("A") }
        }
        .environment(\.cspNonce, "env")
        .render()
        XCTAssertTrue(html.contains(#"<script nonce="env">go()</script>"#), html)
        XCTAssertTrue(html.contains(#"<style nonce="env">p{}</style>"#), html)
        XCTAssertTrue(html.contains(#"<script nonce="own">other()</script>"#), html)
        XCTAssertTrue(html.contains(#"<style nonce="env">.svui-zstack"#), html)
    }

    /// Checks an empty nonce, given or from the environment, writes no attribute.
    func testEmptyNonceOptsOut() {
        let html = Group {
            Script("a()", nonce: "")
            Style("p{}")
        }
        .environment(\.cspNonce, "env")
        .render()
        XCTAssertTrue(html.contains("<script>a()</script>"), html)
        XCTAssertEqual(Style("p{}").environment(\.cspNonce, "").render(), "<style>p{}</style>")
    }

    /// Checks the nonce reaches the head's support styles when it is set inside the body.
    func testBodyEnvironmentNonceReachesHead() {
        let html = Page(title: "T") {
            ZStack { Text("A") }.environment(\.cspNonce, "inner")
        }
        .render()
        XCTAssertTrue(html.contains(#"<head>"#), html)
        XCTAssertTrue(html.contains(#"<style nonce="inner">.svui-zstack"#), html)
    }

    /// Checks the support styles `HTMLDocument` collects into the head carry the nonce.
    func testDocumentHeadSupportStylesNonce() {
        let html = Page(title: "T") { ZStack { Text("A") } }
            .environment(\.cspNonce, "env")
            .render()
        XCTAssertTrue(html.contains(#"<style nonce="env">.svui-zstack"#), html)
    }

    /// Checks nonces are random, Base64 and 16 bytes.
    func testGeneratedNonces() {
        let nonces = (0..<20).map { _ in CSPNonce.generate() }
        XCTAssertEqual(Set(nonces).count, 20)
        for nonce in nonces {
            XCTAssertEqual(Data(base64Encoded: nonce)?.count, 16)
        }
    }

    /// Checks a request keeps one nonce for its whole lifetime.
    func testRequestNonceIsStable() async throws {
        let app = try await Application.make(.testing)
        app.get("nonce") { req in
            req.cspNonce == req.cspNonce ? req.cspNonce : "changed"
        }
        var first = ""
        try await app.test(.GET, "nonce") { res async in
            first = res.body.string
            XCTAssertEqual(Data(base64Encoded: first)?.count, 16)
        }
        try await app.test(.GET, "nonce") { res async in
            XCTAssertNotEqual(res.body.string, first)
        }
        try await app.asyncShutdown()
    }

}
