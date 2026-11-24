import SwiftVaporUI
import XCTest
import XCTVapor

/// Tests for the htmx modifiers, `HTMXScript` and the request helpers.
final class HTMXTests: XCTestCase {

    /// Checks the request modifiers write their `hx-*` attributes.
    func testRequestModifiers() {
        let html = Button("Load", action: .plain)
            .hxGet("/plants?page=2")
            .hxTarget("#list")
            .hxSwap(.beforeEnd)
            .hxIndicator("#spinner")
            .render()
        XCTAssertEqual(
            html,
            ##"<button type="button" hx-get="/plants?page=2" hx-target="#list" hx-swap="beforeend" hx-indicator="#spinner">Load</button>"##
        )
        XCTAssertTrue(Div {}.hxPost("/a").render().contains(#"hx-post="/a""#))
        XCTAssertTrue(Div {}.hxPut("/a").render().contains(#"hx-put="/a""#))
        XCTAssertTrue(Div {}.hxPatch("/a").render().contains(#"hx-patch="/a""#))
        XCTAssertTrue(Div {}.hxDelete("/a").render().contains(#"hx-delete="/a""#))
    }

    /// Checks swap options are appended in order.
    func testSwapOptions() {
        XCTAssertEqual(HTMXSwap.outerHTML.transition().rawValue, "outerHTML transition:true")
        XCTAssertEqual(
            HTMXSwap.innerHTML.swapDelay(.milliseconds(100)).settle(.seconds(1)).rawValue,
            "innerHTML swap:100ms settle:1s"
        )
        XCTAssertEqual(HTMXSwap.afterBegin.scroll(.top).show(.bottom).rawValue, "afterbegin scroll:top show:bottom")
        XCTAssertEqual(HTMXSwap.innerHTML.ignoringTitle().rawValue, "innerHTML ignoreTitle:true")
        let custom: HTMXSwap = "morph"
        XCTAssertEqual(custom.rawValue, "morph")
    }

    /// Checks triggers, their options, and joining several with commas.
    func testTriggers() {
        XCTAssertEqual(HTMXTrigger.every(.seconds(5)).rawValue, "every 5s")
        XCTAssertEqual(HTMXTrigger.every(.milliseconds(1500)).rawValue, "every 1500ms")
        XCTAssertEqual(HTMXTrigger.input.changed().delay(.milliseconds(300)).rawValue, "input changed delay:300ms")
        XCTAssertEqual(HTMXTrigger.click.once().rawValue, "click once")
        XCTAssertEqual(HTMXTrigger.keyup.filter("key=='Enter'").from("body").rawValue, "keyup[key=='Enter'] from:body")
        XCTAssertEqual(HTMXTrigger.click.once().filter("ctrlKey").rawValue, "click[ctrlKey] once")
        XCTAssertEqual(HTMXTrigger.event("plant-added").throttle(.seconds(2)).rawValue, "plant-added throttle:2s")
        let html = Input(name: "q").hxTrigger(.input.changed().delay(.milliseconds(300)), .search).render()
        XCTAssertTrue(html.contains(#"hx-trigger="input changed delay:300ms, search""#), html)
    }

    /// Checks durations are written in whole seconds or milliseconds.
    func testTimingFormat() {
        XCTAssertEqual(HTMXTrigger.every(.zero).rawValue, "every 0s")
        XCTAssertEqual(HTMXTrigger.every(.milliseconds(250)).rawValue, "every 250ms")
        XCTAssertEqual(HTMXTrigger.every(.seconds(2)).rawValue, "every 2s")
        XCTAssertEqual(HTMXTrigger.every(.seconds(-1)).rawValue, "every 0s")
        XCTAssertEqual(HTMXTrigger.every(.microseconds(500)).rawValue, "every 1ms")
        XCTAssertEqual(HTMXTrigger.every(.seconds(Int64.max / 100)).rawValue, "every 1000000000s")
    }

    /// Checks the other modifiers, including JSON for `hx-vals` and escaping.
    func testOtherModifiers() {
        let html = Div {}
            .hxSelect("#main")
            .hxPushURL()
            .hxConfirm("Delete \"Fern\"?")
            .hxInclude("closest form")
            .hxVals(["b": "2", "a": "x/y"])
            .hxBoost()
            .hxDisabledElement()
            .hx("sync", "closest form:abort")
            .render()
        XCTAssertTrue(html.contains(##"hx-select="#main""##), html)
        XCTAssertTrue(html.contains(#"hx-push-url="true""#), html)
        XCTAssertTrue(html.contains(#"hx-confirm="Delete &quot;Fern&quot;?""#), html)
        XCTAssertTrue(html.contains(#"hx-include="closest form""#), html)
        XCTAssertTrue(html.contains(#"hx-vals="{&quot;a&quot;:&quot;x/y&quot;,&quot;b&quot;:&quot;2&quot;}""#), html)
        XCTAssertTrue(html.contains(#"hx-boost="true""#), html)
        XCTAssertTrue(html.contains(#"hx-disabled-elt="this""#), html)
        XCTAssertTrue(html.contains(#"hx-sync="closest form:abort""#), html)
        XCTAssertTrue(Div {}.hxPushURL("/plants?page=2").render().contains(#"hx-push-url="/plants?page=2""#))
        XCTAssertTrue(Div {}.hxSwapOOB().render().contains(#"hx-swap-oob="true""#))
        XCTAssertTrue(Div {}.hxSwapOOB(.beforeEnd).render().contains(#"hx-swap-oob="beforeend""#))
    }

    /// Checks the script tag, by version and by URL, with the pinned integrity hash.
    func testHTMXScript() {
        let hash = HTMXScript.knownIntegrity[HTMXScript.defaultVersion] ?? ""
        XCTAssertTrue(hash.hasPrefix("sha384-"), "the default version needs a known hash")
        XCTAssertEqual(
            HTMXScript().render(),
            #"<script src="https://cdn.jsdelivr.net/npm/htmx.org@\#(HTMXScript.defaultVersion)/dist/htmx.min.js" defer "#
                + #"integrity="\#(hash)" crossorigin="anonymous"></script>"#
        )
        XCTAssertFalse(HTMXScript(version: "2.0.0").render().contains("integrity"))
        XCTAssertFalse(HTMXScript(integrity: "").render().contains("integrity"))
        XCTAssertFalse(HTMXScript(integrity: "").render().contains("crossorigin"))
        XCTAssertTrue(HTMXScript(version: "2.0.0", integrity: "sha384-x").render().contains(#"integrity="sha384-x""#))
        XCTAssertEqual(HTMXScript(src: "/js/htmx.min.js").render(), #"<script src="/js/htmx.min.js" defer></script>"#)
    }

    /// Checks a CSP nonce reaches the script, and never appears outside a `nonce` attribute.
    func testHTMXScriptNonce() {
        let html = HTMXScript(src: "/htmx.js").environment(\.cspNonce, "abc").render()
        XCTAssertEqual(html, #"<script src="/htmx.js" defer nonce="abc"></script>"#)
    }

    /// Checks the request headers are read, and when a fragment is wanted.
    func testRequestDetails() {
        let plain = HTMXRequestDetails(headers: [:])
        XCTAssertFalse(plain.isHTMX)
        XCTAssertFalse(plain.wantsFragment)

        let partial = HTMXRequestDetails(headers: [
            "HX-Request": "true",
            "HX-Target": "plant-count",
            "HX-Trigger": "refresh",
            "HX-Trigger-Name": "refresh-button",
            "HX-Current-URL": "http://localhost/plants",
            "HX-Prompt": "Fern",
        ])
        XCTAssertTrue(partial.isHTMX)
        XCTAssertTrue(partial.wantsFragment)
        XCTAssertEqual(partial.target, "plant-count")
        XCTAssertEqual(partial.trigger, "refresh")
        XCTAssertEqual(partial.triggerName, "refresh-button")
        XCTAssertEqual(partial.currentURL, "http://localhost/plants")
        XCTAssertEqual(partial.prompt, "Fern")

        XCTAssertFalse(HTMXRequestDetails(headers: ["HX-Request": "true", "HX-Boosted": "true"]).wantsFragment)
        XCTAssertFalse(HTMXRequestDetails(headers: ["HX-Request": "true", "HX-History-Restore-Request": "true"]).wantsFragment)
    }

    /// Checks a route answers htmx with the fragment and browsers with the page.
    func testFragmentOrPage() async throws {
        let app = try await Application.make(.testing)
        app.get("count") { req in
            req.fragmentOrPage(Paragraph("3 plants").id("count")) { fragment in
                Page(title: "Count") { fragment }
            }
        }
        try await app.test(.GET, "count", headers: ["HX-Request": "true"]) { res async in
            XCTAssertEqual(res.body.string, #"<p id="count">3 plants</p>"#)
            XCTAssertEqual(res.headers.first(name: .vary), "HX-Request, HX-Boosted, HX-History-Restore-Request")
            XCTAssertEqual(res.headers.contentType, .html)
        }
        try await app.test(.GET, "count") { res async in
            XCTAssertTrue(res.body.string.hasPrefix("<!DOCTYPE html>"), res.body.string)
            XCTAssertTrue(res.body.string.contains(#"<p id="count">3 plants</p>"#))
        }
        try await app.test(.GET, "count", beforeRequest: { req in
            req.headers.replaceOrAdd(name: .hxRequest, value: "true")
            req.headers.replaceOrAdd(name: .hxBoosted, value: "true")
        }, afterResponse: { res async in
            XCTAssertTrue(res.body.string.hasPrefix("<!DOCTYPE html>"))
        })
        try await app.asyncShutdown()
    }

}
