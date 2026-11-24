import SwiftVaporUI
import XCTest

/// Tests for popovers, invoker commands and the popover `Menu`.
final class PopoverTests: XCTestCase {

    /// Checks the popover modifier writes each mode.
    func testPopoverModifier() {
        XCTAssertEqual(Div { "Hi" }.id("tip").popover().render(), #"<div id="tip" popover="auto">Hi</div>"#)
        XCTAssertEqual(Div {}.popover(.manual).render(), #"<div popover="manual"></div>"#)
        XCTAssertEqual(Div {}.popover(.hint).render(), #"<div popover="hint"></div>"#)
    }

    /// Checks popover buttons, leaving out the default toggle action.
    func testPopoverButtons() {
        XCTAssertEqual(
            Button("Help", action: .popover(target: "help")).render(),
            #"<button type="button" popovertarget="help">Help</button>"#
        )
        XCTAssertEqual(
            Button("Open", action: .popover(.show, target: "help")).render(),
            #"<button type="button" popovertarget="help" popovertargetaction="show">Open</button>"#
        )
        XCTAssertEqual(
            Button("Close", action: .popover(.hide, target: "help")).render(),
            #"<button type="button" popovertarget="help" popovertargetaction="hide">Close</button>"#
        )
    }

    /// Checks invoker command buttons, including custom commands.
    func testCommandButtons() {
        XCTAssertEqual(
            Button("Open", action: .command(.showModal, target: "special")).render(),
            #"<button type="button" commandfor="special" command="show-modal">Open</button>"#
        )
        let commands: [(InvokerCommand, String)] = [
            (.close, "close"),
            (.requestClose, "request-close"),
            (.togglePopover, "toggle-popover"),
            (.showPopover, "show-popover"),
            (.hidePopover, "hide-popover"),
            (.custom("rotate"), "--rotate"),
            (.custom("--spin"), "--spin"),
        ]
        for (command, value) in commands {
            XCTAssertEqual(command.rawValue, value)
            XCTAssertTrue(Button("Go", action: .command(command, target: "x")).render().contains(#"command="\#(value)""#))
        }
    }

    /// Checks command targets and values are escaped.
    func testCommandEscaping() {
        let html = Button("Go", action: .command(.custom("a\"b"), target: "x\"><script>")).render()
        XCTAssertFalse(html.contains("<script>"), html)
        XCTAssertTrue(html.contains(#"commandfor="x&quot;&gt;&lt;script&gt;""#), html)
    }

    /// Checks a menu with an `id` is built on the Popover API, and modifiers reach its wrapper.
    func testPopoverMenu() {
        let html = Menu("Share", id: "share") {
            Link("A", destination: "/a")
        }
        .class("tools")
        .render()
        XCTAssertTrue(html.hasPrefix("<style>"), html)
        XCTAssertTrue(html.contains(".svui-popover-menu"), html)
        XCTAssertTrue(
            html.hasSuffix(
                #"<div class="svui-popover-anchor tools"><button type="button" popovertarget="share">Share</button>"#
                    + #"<div class="svui-popover-menu" id="share" role="menu" popover="auto"><a href="/a">A</a></div></div>"#
            ),
            html
        )
    }

    /// Checks a menu without an `id` is still built on `<details>`.
    func testDetailsMenuIsUnchanged() {
        let html = Menu("Share") { Link("A", destination: "/a") }.render()
        XCTAssertTrue(html.contains(#"<details class="svui-menu">"#), html)
        XCTAssertFalse(html.contains("popover"), html)
    }

}
