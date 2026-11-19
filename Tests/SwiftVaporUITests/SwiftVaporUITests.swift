import XCTest
@testable import SwiftVaporUI

final class SwiftVaporUITests: XCTestCase {
    func testPageRendersTitleAndBody() {
        let html = Page(title: "Hello", body: "<p>World</p>").render()
        XCTAssertTrue(html.contains("<title>Hello</title>"))
        XCTAssertTrue(html.contains("<p>World</p>"))
    }
}
