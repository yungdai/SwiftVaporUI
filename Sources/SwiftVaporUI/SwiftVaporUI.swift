import Vapor

/// A piece of HTML content, described declaratively in the style of SwiftUI.
///
/// This is a placeholder for the DSL; the full set of views and modifiers
/// will be built on top of it.
public protocol HTMLView: Sendable {
    /// Renders the view to an HTML string.
    func render() -> String
}

/// A full HTML page that can be returned directly from a Vapor route.
public struct Page: HTMLView, AsyncResponseEncodable {
    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }

    public func render() -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head><meta charset="utf-8"><title>\(title)</title></head>
        <body>\(body)</body>
        </html>
        """
    }

    public func encodeResponse(for request: Request) async throws -> Response {
        var headers = HTTPHeaders()
        headers.contentType = .html
        return Response(status: .ok, headers: headers, body: .init(string: render()))
    }
}
