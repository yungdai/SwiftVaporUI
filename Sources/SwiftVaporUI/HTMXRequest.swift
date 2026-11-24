import Vapor

/// What htmx said about a request, read from the `HX-*` request headers.
///
/// Get one from ``Vapor/Request/htmx``. Most routes only need
/// ``wantsFragment``, or ``Vapor/Request/fragmentOrPage(_:page:)``, which
/// uses it.
public struct HTMXRequestDetails: Sendable, Equatable {

    // MARK: - Properties

    /// Whether htmx sent the request (`HX-Request: true`).
    public let isHTMX: Bool

    /// Whether the request came from a boosted link or form (`HX-Boosted`).
    /// htmx swaps the response's `<body>` into the page, so send a full page.
    public let isBoosted: Bool

    /// Whether htmx is restoring a page it could not find in its history
    /// cache (`HX-History-Restore-Request`). Send a full page.
    public let isHistoryRestore: Bool

    /// The `id` of the element the response will be swapped into, if it has one (`HX-Target`).
    public let target: String?

    /// The `id` of the element that triggered the request, if it has one (`HX-Trigger`).
    public let trigger: String?

    /// The `name` of the element that triggered the request, if it has one (`HX-Trigger-Name`).
    public let triggerName: String?

    /// The browser's current URL (`HX-Current-URL`).
    public let currentURL: String?

    /// The visitor's answer to an `hx-prompt` question (`HX-Prompt`).
    public let prompt: String?

    // MARK: - Computed Properties

    /// Whether to answer with just a fragment: the request came from htmx,
    /// and is not a boosted navigation or a history restore, which need the
    /// whole page.
    public var wantsFragment: Bool {
        isHTMX && !isBoosted && !isHistoryRestore
    }

    // MARK: - Initializer

    /// Reads the htmx headers of a request.
    /// - Parameter headers: The request headers.
    public init(headers: HTTPHeaders) {
        /// Whether a header is set to `true`.
        /// - Parameter name: The header name.
        /// - Returns: Whether the header's value is `true`, in any case.
        func isTrue(_ name: HTTPHeaders.Name) -> Bool {
            headers.first(name: name)?.lowercased() == "true"
        }
        isHTMX = isTrue(.hxRequest)
        isBoosted = isTrue(.hxBoosted)
        isHistoryRestore = isTrue(.hxHistoryRestoreRequest)
        target = headers.first(name: .hxTarget)
        trigger = headers.first(name: .hxTrigger)
        triggerName = headers.first(name: .hxTriggerName)
        currentURL = headers.first(name: .hxCurrentURL)
        prompt = headers.first(name: .hxPrompt)
    }

}

/// htmx support for Vapor requests.
extension Request {

    /// Whether htmx sent this request (`HX-Request: true`).
    public var isHTMX: Bool {
        htmx.isHTMX
    }

    /// The htmx details of this request, read from its `HX-*` headers.
    public var htmx: HTMXRequestDetails {
        HTMXRequestDetails(headers: headers)
    }

    /// Answers with a fragment for htmx, or with the full page for everyone else.
    ///
    /// ```swift
    /// app.get("plants") { req in
    ///     let list = PlantList(plants: await shelf.all())
    ///     return req.fragmentOrPage(list) { list in
    ///         SiteLayout(title: "Plants") { list }
    ///     }
    /// }
    /// ```
    ///
    /// The same URL then works when it is opened directly, bookmarked or
    /// reloaded, and when htmx requests it to update part of a page. The
    /// response has `Vary: HX-Request`, so caches keep the two answers apart.
    /// - Parameters:
    ///   - fragment: The view htmx swaps into the page.
    ///   - page: Builds the full page around the fragment.
    /// - Returns: The fragment when ``HTMXRequestDetails/wantsFragment`` is true, otherwise the page.
    public func fragmentOrPage<Fragment: View, FullPage: View>(
        _ fragment: Fragment,
        @ViewBuilder page: (Fragment) -> FullPage
    ) -> HTMLResponse<AnyView> {
        let view = htmx.wantsFragment ? AnyView(fragment) : AnyView(page(fragment))
        return HTMLResponse(headers: ["Vary": "HX-Request"], view)
    }

}

/// The headers htmx sends with its requests and reads from responses.
///
/// ```swift
/// var headers = HTTPHeaders()
/// headers.replaceOrAdd(name: .hxTrigger, value: "plant-added")
/// return HTMLResponse(headers: headers) { PlantRow(plant: plant) }
/// ```
extension HTTPHeaders.Name {

    /// Request: `true` on every request htmx sends.
    public static let hxRequest = HTTPHeaders.Name("HX-Request")

    /// Request: `true` when a boosted link or form sent the request.
    public static let hxBoosted = HTTPHeaders.Name("HX-Boosted")

    /// Request: `true` when htmx is restoring a page missing from its history cache.
    public static let hxHistoryRestoreRequest = HTTPHeaders.Name("HX-History-Restore-Request")

    /// Request: the `id` of the target element.
    public static let hxTarget = HTTPHeaders.Name("HX-Target")

    /// Request: the `id` of the element that triggered the request. Response:
    /// client-side events to fire as soon as the response arrives.
    public static let hxTrigger = HTTPHeaders.Name("HX-Trigger")

    /// Request: the `name` of the element that triggered the request.
    public static let hxTriggerName = HTTPHeaders.Name("HX-Trigger-Name")

    /// Request: the browser's current URL.
    public static let hxCurrentURL = HTTPHeaders.Name("HX-Current-URL")

    /// Request: the visitor's answer to an `hx-prompt` question.
    public static let hxPrompt = HTTPHeaders.Name("HX-Prompt")

    /// Response: client-side events to fire after the swap.
    public static let hxTriggerAfterSwap = HTTPHeaders.Name("HX-Trigger-After-Swap")

    /// Response: client-side events to fire after the new content settles.
    public static let hxTriggerAfterSettle = HTTPHeaders.Name("HX-Trigger-After-Settle")

    /// Response: sends the browser to another URL with a full page load.
    public static let hxRedirect = HTTPHeaders.Name("HX-Redirect")

    /// Response: navigates to another URL with an htmx request, without a full page load.
    public static let hxLocation = HTTPHeaders.Name("HX-Location")

    /// Response: `true` makes the browser reload the whole page.
    public static let hxRefresh = HTTPHeaders.Name("HX-Refresh")

    /// Response: pushes a URL onto the browser history.
    public static let hxPushURL = HTTPHeaders.Name("HX-Push-Url")

    /// Response: replaces the current URL in the address bar.
    public static let hxReplaceURL = HTTPHeaders.Name("HX-Replace-Url")

    /// Response: a CSS selector that overrides the element's `hx-target`.
    public static let hxRetarget = HTTPHeaders.Name("HX-Retarget")

    /// Response: an `hx-swap` value that overrides the element's `hx-swap`.
    public static let hxReswap = HTTPHeaders.Name("HX-Reswap")

    /// Response: a CSS selector that overrides the element's `hx-select`.
    public static let hxReselect = HTTPHeaders.Name("HX-Reselect")

}
