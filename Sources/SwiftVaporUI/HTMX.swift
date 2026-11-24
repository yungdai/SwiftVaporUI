import Foundation

// Typed modifiers for htmx (https://htmx.org), the library that lets any
// element make an HTTP request and swap the HTML it gets back into the page.
// Each modifier writes one `hx-*` attribute, so the server-rendered page
// still works as plain HTML, and htmx adds partial updates when it loads.

/// Where htmx puts the HTML a request returns, written as `hx-swap`.
///
/// ```swift
/// Button("Load more")
///     .hxGet("/plants?page=2")
///     .hxSwap(.beforeEnd.settle(.milliseconds(200)))
/// ```
public struct HTMXSwap: Sendable, Hashable, ExpressibleByStringLiteral {

    // MARK: - Nested Types

    /// The edge of the target that htmx scrolls to, or shows, after a swap.
    public enum ScrollEdge: String, Sendable, Hashable {

        /// The top of the target.
        case top

        /// The bottom of the target.
        case bottom

    }

    // MARK: - Static Properties

    /// Replaces the target's content. This is htmx's default.
    public static let innerHTML = HTMXSwap(rawValue: "innerHTML")

    /// Replaces the whole target element.
    public static let outerHTML = HTMXSwap(rawValue: "outerHTML")

    /// Replaces the target's text content, without parsing the response as HTML.
    public static let textContent = HTMXSwap(rawValue: "textContent")

    /// Inserts the response before the target element.
    public static let beforeBegin = HTMXSwap(rawValue: "beforebegin")

    /// Inserts the response before the target's first child.
    public static let afterBegin = HTMXSwap(rawValue: "afterbegin")

    /// Inserts the response after the target's last child.
    public static let beforeEnd = HTMXSwap(rawValue: "beforeend")

    /// Inserts the response after the target element.
    public static let afterEnd = HTMXSwap(rawValue: "afterend")

    /// Deletes the target element, whatever the response.
    public static let delete = HTMXSwap(rawValue: "delete")

    /// Leaves the target alone. Out-of-band swaps in the response still happen.
    public static let none = HTMXSwap(rawValue: "none")

    // MARK: - Properties

    /// The `hx-swap` value, such as `"outerHTML transition:true"`.
    public let rawValue: String

    // MARK: - Initializers

    /// Creates a swap from a raw `hx-swap` value, for options this type does not name.
    /// - Parameter rawValue: The `hx-swap` value, such as `"innerHTML swap:1s"`.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a swap from a string literal holding a raw `hx-swap` value.
    /// - Parameter value: The `hx-swap` value.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    // MARK: - Methods

    /// Uses the browser's View Transitions API for the swap, where it is supported.
    /// - Returns: The swap with `transition:true` added.
    public func transition() -> HTMXSwap {
        adding("transition:true")
    }

    /// Waits before swapping the new content in.
    /// - Parameter delay: How long to wait.
    /// - Returns: The swap with `swap:` added.
    public func swapDelay(_ delay: Duration) -> HTMXSwap {
        adding("swap:\(HTMXTiming.format(delay))")
    }

    /// Waits between swapping the content in and settling its attributes,
    /// which gives CSS transitions time to run.
    /// - Parameter delay: How long to wait.
    /// - Returns: The swap with `settle:` added.
    public func settle(_ delay: Duration) -> HTMXSwap {
        adding("settle:\(HTMXTiming.format(delay))")
    }

    /// Scrolls the target to one edge after the swap.
    /// - Parameter edge: The edge to scroll to.
    /// - Returns: The swap with `scroll:` added.
    public func scroll(_ edge: ScrollEdge) -> HTMXSwap {
        adding("scroll:\(edge.rawValue)")
    }

    /// Scrolls the window so one edge of the target is visible after the swap.
    /// - Parameter edge: The edge to bring into view.
    /// - Returns: The swap with `show:` added.
    public func show(_ edge: ScrollEdge) -> HTMXSwap {
        adding("show:\(edge.rawValue)")
    }

    /// Keeps the page title, even when the response has a `<title>`.
    /// - Returns: The swap with `ignoreTitle:true` added.
    public func ignoringTitle() -> HTMXSwap {
        adding("ignoreTitle:true")
    }

    /// Appends one swap option.
    /// - Parameter option: The option, such as `"settle:20ms"`.
    /// - Returns: The swap with the option added.
    func adding(_ option: String) -> HTMXSwap {
        HTMXSwap(rawValue: rawValue + " " + option)
    }

}

/// The event that makes htmx send a request, written as `hx-trigger`.
///
/// ```swift
/// SearchField(name: "q")
///     .hxGet("/search")
///     .hxTrigger(.input.changed().delay(.milliseconds(300)), .search)
/// ```
public struct HTMXTrigger: Sendable, Hashable, ExpressibleByStringLiteral {

    // MARK: - Static Properties

    /// A click.
    public static let click = HTMXTrigger(rawValue: "click")

    /// A control's value is committed, such as leaving a changed text field.
    public static let change = HTMXTrigger(rawValue: "change")

    /// A control's value changes, on every keystroke.
    public static let input = HTMXTrigger(rawValue: "input")

    /// A key is released.
    public static let keyup = HTMXTrigger(rawValue: "keyup")

    /// A form is submitted.
    public static let submit = HTMXTrigger(rawValue: "submit")

    /// A search field is cleared or submitted with Enter.
    public static let search = HTMXTrigger(rawValue: "search")

    /// The element is loaded into the page. Use it to load content lazily.
    public static let load = HTMXTrigger(rawValue: "load")

    /// The element is scrolled into the viewport for the first time.
    public static let revealed = HTMXTrigger(rawValue: "revealed")

    /// The element starts to intersect the viewport, each time it does.
    public static let intersect = HTMXTrigger(rawValue: "intersect")

    // MARK: - Properties

    /// The `hx-trigger` value, such as `"keyup changed delay:300ms"`.
    public let rawValue: String

    // MARK: - Initializers

    /// Creates a trigger from a raw `hx-trigger` value, for events and options this type does not name.
    /// - Parameter rawValue: The `hx-trigger` value, such as `"mouseenter once"`.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a trigger from a string literal holding a raw `hx-trigger` value.
    /// - Parameter value: The `hx-trigger` value.
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

    // MARK: - Static Methods

    /// Polls: sends the request again and again at a fixed interval.
    /// - Parameter interval: The time between requests.
    /// - Returns: The trigger `every <interval>`.
    public static func every(_ interval: Duration) -> HTMXTrigger {
        HTMXTrigger(rawValue: "every \(HTMXTiming.format(interval))")
    }

    /// A DOM event by name, including custom events sent with `HX-Trigger`.
    /// - Parameter name: The event name, such as `"mouseenter"` or `"plant-added"`.
    /// - Returns: The trigger for that event.
    public static func event(_ name: String) -> HTMXTrigger {
        HTMXTrigger(rawValue: name)
    }

    // MARK: - Methods

    /// Fires only once.
    /// - Returns: The trigger with `once` added.
    public func once() -> HTMXTrigger {
        adding("once")
    }

    /// Fires only when the element's value has changed since the last request.
    /// - Returns: The trigger with `changed` added.
    public func changed() -> HTMXTrigger {
        adding("changed")
    }

    /// Waits until the event has stopped firing for `delay`, then fires once.
    /// Each new event restarts the wait, which suits typing.
    /// - Parameter delay: How long the events must stop for.
    /// - Returns: The trigger with `delay:` added.
    public func delay(_ delay: Duration) -> HTMXTrigger {
        adding("delay:\(HTMXTiming.format(delay))")
    }

    /// Fires at most once per `interval`, dropping the events in between.
    /// - Parameter interval: The shortest time between requests.
    /// - Returns: The trigger with `throttle:` added.
    public func throttle(_ interval: Duration) -> HTMXTrigger {
        adding("throttle:\(HTMXTiming.format(interval))")
    }

    /// Listens for the event on another element instead of this one.
    /// - Parameter selector: A CSS selector, or an htmx extended selector such as `"body"` or `"closest form"`.
    /// - Returns: The trigger with `from:` added.
    public func from(_ selector: String) -> HTMXTrigger {
        adding("from:\(selector)")
    }

    /// Fires only when the event matches a JavaScript condition, such as
    /// `"ctrlKey"`. The filter goes straight after the event name, where htmx
    /// reads it, whatever order the options were added in.
    /// - Parameter condition: A JavaScript expression, evaluated against the event.
    /// - Returns: The trigger with the `[condition]` filter added.
    public func filter(_ condition: String) -> HTMXTrigger {
        let filter = "[\(condition)]"
        guard let space = rawValue.firstIndex(of: " ") else {
            return HTMXTrigger(rawValue: rawValue + filter)
        }
        return HTMXTrigger(rawValue: rawValue[..<space] + filter + rawValue[space...])
    }

    /// Appends one trigger option.
    /// - Parameter option: The option, such as `"once"`.
    /// - Returns: The trigger with the option added.
    func adding(_ option: String) -> HTMXTrigger {
        HTMXTrigger(rawValue: rawValue + " " + option)
    }

}

/// Writes durations the way htmx reads them.
enum HTMXTiming {

    /// The longest duration written, in seconds: about 31 years, far past
    /// any useful delay, and small enough to count in milliseconds safely.
    static let maximumSeconds: Int64 = 1_000_000_000

    /// Formats a duration as htmx's `500ms` or `2s`.
    /// - Parameter duration: The duration to format. Negative durations count
    ///   as zero, a part of a millisecond counts as a whole one, and durations
    ///   longer than ``maximumSeconds`` are shortened to it.
    /// - Returns: Whole seconds as `<n>s`, anything else as whole milliseconds `<n>ms`.
    static func format(_ duration: Duration) -> String {
        let (seconds, attoseconds) = duration.components
        guard seconds >= 0, seconds < maximumSeconds else {
            return seconds < 0 ? "0s" : "\(maximumSeconds)s"
        }
        let attosecondsPerMillisecond: Int64 = 1_000_000_000_000_000
        let (wholeMilliseconds, remainder) = attoseconds.quotientAndRemainder(dividingBy: attosecondsPerMillisecond)
        let milliseconds = seconds * 1000 + wholeMilliseconds + (remainder > 0 ? 1 : 0)
        return milliseconds % 1000 == 0 ? "\(milliseconds / 1000)s" : "\(milliseconds)ms"
    }

}

/// htmx modifiers: each sets one `hx-*` attribute on the element.
extension View {

    /// Sends a GET request to `url` when the element is triggered, and swaps in the HTML it returns.
    /// - Parameter url: The URL to request.
    /// - Returns: A view with `hx-get` set.
    public func hxGet(_ url: String) -> ModifiedView<Self> {
        changing(.set("hx-get", url))
    }

    /// Sends a POST request to `url` when the element is triggered. Inside a
    /// form, the form's fields are sent too.
    /// - Parameter url: The URL to request.
    /// - Returns: A view with `hx-post` set.
    public func hxPost(_ url: String) -> ModifiedView<Self> {
        changing(.set("hx-post", url))
    }

    /// Sends a PUT request to `url` when the element is triggered.
    /// - Parameter url: The URL to request.
    /// - Returns: A view with `hx-put` set.
    public func hxPut(_ url: String) -> ModifiedView<Self> {
        changing(.set("hx-put", url))
    }

    /// Sends a PATCH request to `url` when the element is triggered.
    /// - Parameter url: The URL to request.
    /// - Returns: A view with `hx-patch` set.
    public func hxPatch(_ url: String) -> ModifiedView<Self> {
        changing(.set("hx-patch", url))
    }

    /// Sends a DELETE request to `url` when the element is triggered.
    /// - Parameter url: The URL to request.
    /// - Returns: A view with `hx-delete` set.
    public func hxDelete(_ url: String) -> ModifiedView<Self> {
        changing(.set("hx-delete", url))
    }

    /// Chooses the element the response is swapped into. Without it, htmx
    /// swaps into the element that made the request.
    /// - Parameter selector: A CSS selector such as `"#results"`, or an htmx
    ///   extended selector such as `"this"`, `"closest tr"` or `"next .error"`.
    /// - Returns: A view with `hx-target` set.
    public func hxTarget(_ selector: String) -> ModifiedView<Self> {
        changing(.set("hx-target", selector))
    }

    /// Chooses how the response is swapped into the target.
    /// - Parameter swap: The swap style and options.
    /// - Returns: A view with `hx-swap` set.
    public func hxSwap(_ swap: HTMXSwap) -> ModifiedView<Self> {
        changing(.set("hx-swap", swap.rawValue))
    }

    /// Chooses the events that send the request. Several triggers are joined
    /// with commas, and any of them sends it.
    /// - Parameters:
    ///   - trigger: The first trigger, such as `.click` or `.every(.seconds(5))`.
    ///   - more: Other triggers that also send the request.
    /// - Returns: A view with `hx-trigger` set.
    public func hxTrigger(_ trigger: HTMXTrigger, _ more: HTMXTrigger...) -> ModifiedView<Self> {
        changing(.set("hx-trigger", ([trigger] + more).map(\.rawValue).joined(separator: ", ")))
    }

    /// Swaps in only part of the response.
    /// - Parameter selector: A CSS selector for the part of the response to keep.
    /// - Returns: A view with `hx-select` set.
    public func hxSelect(_ selector: String) -> ModifiedView<Self> {
        changing(.set("hx-select", selector))
    }

    /// Pushes the request URL onto the browser history, so the back button
    /// and reloads work, or stops a boosted link from doing so.
    /// - Parameter isOn: Whether to push the request URL.
    /// - Returns: A view with `hx-push-url` set.
    public func hxPushURL(_ isOn: Bool = true) -> ModifiedView<Self> {
        changing(.set("hx-push-url", isOn ? "true" : "false"))
    }

    /// Pushes `url` onto the browser history instead of the request URL.
    /// - Parameter url: The URL to show in the address bar.
    /// - Returns: A view with `hx-push-url` set.
    public func hxPushURL(_ url: String) -> ModifiedView<Self> {
        changing(.set("hx-push-url", url))
    }

    /// Shows an element while the request is in flight: htmx adds the
    /// `htmx-request` class to it, and its built-in CSS fades in elements
    /// with the `htmx-indicator` class.
    /// - Parameter selector: A CSS selector for the indicator.
    /// - Returns: A view with `hx-indicator` set.
    public func hxIndicator(_ selector: String) -> ModifiedView<Self> {
        changing(.set("hx-indicator", selector))
    }

    /// Asks the visitor to confirm, with the browser's `confirm()` dialog, before sending the request.
    /// - Parameter message: The question to ask.
    /// - Returns: A view with `hx-confirm` set.
    public func hxConfirm(_ message: String) -> ModifiedView<Self> {
        changing(.set("hx-confirm", message))
    }

    /// Sends the values of other elements with the request.
    /// - Parameter selector: A CSS selector for the inputs or form to include.
    /// - Returns: A view with `hx-include` set.
    public func hxInclude(_ selector: String) -> ModifiedView<Self> {
        changing(.set("hx-include", selector))
    }

    /// Sends extra values with the request. They are written as JSON, with
    /// keys in sorted order.
    /// - Parameter values: The parameter names and values to add.
    /// - Returns: A view with `hx-vals` set.
    public func hxVals(_ values: [String: String]) -> ModifiedView<Self> {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let json = (try? encoder.encode(values)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        return changing(.set("hx-vals", json))
    }

    /// Turns the links and forms inside the element into htmx requests that
    /// swap the page body, so navigation does not reload the whole page.
    /// Pass `false` to opt a part of the page back out.
    /// - Parameter isOn: Whether to boost links and forms.
    /// - Returns: A view with `hx-boost` set.
    public func hxBoost(_ isOn: Bool = true) -> ModifiedView<Self> {
        changing(.set("hx-boost", isOn ? "true" : "false"))
    }

    /// Marks an element in a response as an out-of-band swap: htmx swaps it
    /// into the element with the same `id` elsewhere on the page, as well as
    /// swapping the main response into the target.
    /// - Parameter swap: How to swap it in. `nil` writes `hx-swap-oob="true"`, which replaces the element.
    /// - Returns: A view with `hx-swap-oob` set.
    public func hxSwapOOB(_ swap: HTMXSwap? = nil) -> ModifiedView<Self> {
        changing(.set("hx-swap-oob", swap?.rawValue ?? "true"))
    }

    /// Disables elements while the request is in flight, so it cannot be sent twice.
    /// - Parameter selector: A CSS selector, or `"this"` for the element itself.
    /// - Returns: A view with `hx-disabled-elt` set.
    public func hxDisabledElement(_ selector: String = "this") -> ModifiedView<Self> {
        changing(.set("hx-disabled-elt", selector))
    }

    /// Sets any other `hx-*` attribute, for features without a typed modifier.
    /// - Parameters:
    ///   - name: The name after the `hx-` prefix, such as `"sync"`.
    ///   - value: The value to set.
    /// - Returns: A view with the attribute set.
    public func hx(_ name: String, _ value: String) -> ModifiedView<Self> {
        changing(.set("hx-\(name)", value))
    }

}

/// Loads htmx with a `<script>` tag. Put it in the document head.
///
/// ```swift
/// HTMLDocument(title: "Plants") {
///     HTMXScript()
/// } body: {
///     ...
/// }
/// ```
///
/// By default it loads a pinned htmx release from the jsDelivr CDN, with its
/// Subresource Integrity hash, so the browser refuses a file that has been
/// changed. To serve htmx yourself, pass its URL, for example
/// `HTMXScript(src: "/js/htmx.min.js")`.
///
/// Under a Content Security Policy, the script carries the environment's
/// ``EnvironmentValues/cspNonce``. htmx also adds a small `<style>` for its
/// request indicators, which a nonce policy blocks. Turn that off and serve
/// the same rules yourself:
///
/// ```swift
/// Meta(name: "htmx-config", content: #"{"includeIndicatorStyles":false}"#)
/// Style(HTMXScript.indicatorCSS)
/// HTMXScript()
/// ```
public struct HTMXScript: View {

    // MARK: - Static Properties

    /// The htmx release the default URL loads.
    public static let defaultVersion = "2.0.11"

    /// The Subresource Integrity hashes of `htmx.min.js` for the releases
    /// this library knows, by version. Each was checked against the file
    /// that both jsDelivr and unpkg serve.
    public static let knownIntegrity: [String: String] = [
        "2.0.11": "sha384-2OatzQy1H+Zd/IIrjr1TcuDGqLXeHhbooAyJY1KdQMKnr4LZ22k31GBLdYKHmVjg",
    ]

    /// The CSS htmx adds for its request indicators, for pages that turn
    /// `includeIndicatorStyles` off and serve it with a nonce instead.
    public static let indicatorCSS = ".htmx-indicator{opacity:0}"
        + ".htmx-request .htmx-indicator,.htmx-request.htmx-indicator{opacity:1;transition:opacity 200ms ease-in}"

    // MARK: - Properties

    /// The script URL.
    public let src: String

    /// The Subresource Integrity hash, or `nil` for none.
    public let integrity: String?

    // MARK: - Initializers

    /// Loads a specific htmx release from the jsDelivr CDN.
    /// - Parameters:
    ///   - version: The htmx version, such as `"2.0.11"`.
    ///   - integrity: The file's Subresource Integrity hash. `nil` uses the
    ///     hash in ``knownIntegrity`` for that version, if there is one. An
    ///     empty string turns the check off.
    public init(version: String = HTMXScript.defaultVersion, integrity: String? = nil) {
        self.src = "https://cdn.jsdelivr.net/npm/htmx.org@\(version)/dist/htmx.min.js"
        let hash = integrity ?? Self.knownIntegrity[version]
        self.integrity = hash?.isEmpty == false ? hash : nil
    }

    /// Loads htmx from `src`, such as a copy you serve yourself.
    /// - Parameters:
    ///   - src: The script URL.
    ///   - integrity: The file's Subresource Integrity hash, if you want the browser to check it.
    public init(src: String, integrity: String? = nil) {
        self.src = src
        self.integrity = integrity?.isEmpty == false ? integrity : nil
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Script {
        // Deferred, so it does not block parsing; htmx processes the page
        // once it runs, which is still before `DOMContentLoaded`.
        Script(src: src, defer: true, integrity: integrity)
    }

}
