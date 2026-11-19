import Vapor

/// A piece of HTML, described declaratively in the style of SwiftUI.
///
/// Conform your own types to `View` and describe their content in `body`:
///
/// ```swift
/// struct Greeting: View {
///     let name: String
///
///     var body: some View {
///         Paragraph {
///             "Hello, "
///             Strong(name)
///         }
///         .class("greeting")
///     }
/// }
/// ```
///
/// Every view is also an `AsyncResponseEncodable`, so it can be returned
/// directly from a Vapor route handler and is sent as `text/html`.
public protocol View: AsyncResponseEncodable, Sendable {
    /// The type of view representing the body of this view.
    associatedtype Body: View

    /// The content of the view.
    @ViewBuilder var body: Body { get }

    /// Writes the HTML for this view into `renderer`.
    ///
    /// You do not normally implement this yourself: composite views render
    /// their `body`. It is public so that the library's primitive views can
    /// override it.
    func _render(into renderer: inout HTMLRenderer)
}

extension View {

    // MARK: - Modifiers

    /// Renders the view to an HTML string.
    ///
    /// - Returns: The HTML, as a string.
    public func render() -> String {
        var renderer = HTMLRenderer()
        _render(into: &renderer)
        return renderer.output
    }

    // MARK: - View

    /// Writes this view's HTML into `renderer`.
    ///
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        body._render(into: &renderer)
    }

}

extension View where Body == Never {

    // MARK: - View

    /// The elements this view is made of.
    public var body: Never {
        fatalError("\(Self.self) is a primitive view and has no body.")
    }

}

extension Never: @retroactive AsyncResponseEncodable {}

extension Never: View {

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    ///
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {}

}

// MARK: - Vapor integration

extension View {

    // MARK: - Modifiers

    /// Encodes the view as an HTML response with status `200 OK`.
    ///
    /// - Parameter request: The request being answered.
    public func encodeResponse(for request: Request) async throws -> Response {
        try await HTMLResponse(self).encodeResponse(for: request)
    }

}

/// Wraps a view so a route can choose the response status and headers.
///
/// ```swift
/// app.get("missing") { _ in
///     HTMLResponse(status: .notFound) { NotFoundPage() }
/// }
/// ```
public struct HTMLResponse<Content: View>: AsyncResponseEncodable {

    // MARK: - Properties

    /// The response status. Defaults to `200 OK`.
    public var status: HTTPResponseStatus

    /// Extra response headers. `Content-Type` defaults to `text/html; charset=utf-8`.
    public var headers: HTTPHeaders

    /// The view rendered as the response body.
    public var content: Content

    // MARK: - Initializers

    /// Creates a response that renders `content`.
    ///
    /// - Parameters:
    ///   - status: The response status. Defaults to `200 OK`.
    ///   - headers: Extra response headers. `Content-Type` defaults to `text/html; charset=utf-8`.
    ///   - content: The view rendered as the response body.
    public init(status: HTTPResponseStatus = .ok, headers: HTTPHeaders = [:], _ content: Content) {
        self.status = status
        self.headers = headers
        self.content = content
    }

    /// Creates a response that renders the view built by `content`.
    ///
    /// - Parameters:
    ///   - status: The response status. Defaults to `200 OK`.
    ///   - headers: Extra response headers. `Content-Type` defaults to `text/html; charset=utf-8`.
    ///   - content: The view rendered as the response body.
    public init(
        status: HTTPResponseStatus = .ok,
        headers: HTTPHeaders = [:],
        @ViewBuilder content: () -> Content
    ) {
        self.init(status: status, headers: headers, content())
    }

    // MARK: - Methods

    /// Renders the view and builds the Vapor response.
    ///
    /// - Parameter request: The request being answered.
    public func encodeResponse(for request: Request) async throws -> Response {
        var headers = headers
        if headers.contentType == nil {
            headers.contentType = .html
        }
        return Response(status: status, headers: headers, body: .init(string: content.render()))
    }

}
