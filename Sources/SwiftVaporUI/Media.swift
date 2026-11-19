// Video, audio, responsive images, embedded pages and inline SVG.

/// How much of a media file the browser should load before playback.
public enum MediaPreload: String, Sendable {

    /// Load nothing until the user presses play.
    case none

    /// Load only the duration and dimensions.
    case metadata

    /// Let the browser load the whole file.
    case auto
}

/// Playback options shared by `Video` and `Audio`.
public struct MediaOptions: OptionSet, Sendable, Hashable {

    // MARK: - Static Properties

    /// Show the browser's playback controls.
    public static let controls = MediaOptions(rawValue: 1)

    /// Start playing as soon as possible. Browsers only allow this for muted media.
    public static let autoplay = MediaOptions(rawValue: 2)

    /// Start again from the beginning when the end is reached.
    public static let loop = MediaOptions(rawValue: 4)

    /// Start with the sound off.
    public static let muted = MediaOptions(rawValue: 8)

    /// Play inline on phones instead of going full screen (video only).
    public static let playsInline = MediaOptions(rawValue: 16)

    // MARK: - Properties

    /// The bit mask of options.
    public let rawValue: Int

    // MARK: - Computed Properties

    /// The boolean attributes these options add.
    var flags: [String] {
        var flags: [String] = []
        if contains(.controls) { flags.append("controls") }
        if contains(.autoplay) { flags.append("autoplay") }
        if contains(.loop) { flags.append("loop") }
        if contains(.muted) { flags.append("muted") }
        if contains(.playsInline) { flags.append("playsinline") }
        return flags
    }

    // MARK: - Initializer

    /// Creates options from a bit mask.
    /// - Parameter rawValue: The bit mask of options.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

/// A video player (`<video>`).
///
/// Pass one `src`, or list several formats as `Source`s in the content. Any
/// other content is the fallback for browsers that cannot play video.
///
/// ```swift
/// Video(poster: "/media/stall.jpg", options: [.controls, .muted]) {
///     Source(src: "/media/stall.webm", type: "video/webm")
///     Source(src: "/media/stall.mp4", type: "video/mp4")
///     Paragraph("Your browser cannot play this video.")
/// }
/// ```
public struct Video<Content: View>: View {

    // MARK: - Properties

    /// The video URL, when there is a single source.
    public let src: String?

    /// An image shown before playback starts.
    public let poster: String?

    /// Playback options. Defaults to showing controls.
    public let options: MediaOptions

    /// How much to load before playback, or `nil` for the browser default.
    public let preload: MediaPreload?

    /// The element's content: `Source`s, `Track`s and fallback content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a video player with sources and fallback built by `content`.
    /// - Parameters:
    ///   - src: The video URL, when there is a single source.
    ///   - poster: An image shown before playback starts.
    ///   - options: Playback options. Defaults to showing controls.
    ///   - preload: How much to load before playback, or `nil` for the browser default.
    ///   - content: The element's content: `Source`s, `Track`s and fallback content.
    public init(
        src: String? = nil,
        poster: String? = nil,
        options: MediaOptions = .controls,
        preload: MediaPreload? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.src = src
        self.poster = poster
        self.options = options
        self.preload = preload
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["src"] = src
        attributes["poster"] = poster
        attributes["preload"] = preload?.rawValue
        for flag in options.flags { attributes.setFlag(flag) }
        return Element("video", attributes: attributes, wrapping: content)
    }
}

/// Initializers for a video with a single file and no fallback content.
extension Video where Content == EmptyView {

    /// Creates a video player for a single file.
    /// - Parameters:
    ///   - src: The video URL, when there is a single source.
    ///   - poster: An image shown before playback starts.
    ///   - options: Playback options. Defaults to showing controls.
    ///   - preload: How much to load before playback, or `nil` for the browser default.
    public init(src: String, poster: String? = nil, options: MediaOptions = .controls, preload: MediaPreload? = nil) {
        self.init(src: src, poster: poster, options: options, preload: preload) { EmptyView() }
    }
}

/// An audio player (`<audio>`).
///
/// Pass one `src`, or list several formats as `Source`s in the content.
public struct Audio<Content: View>: View {

    // MARK: - Properties

    /// The audio URL, when there is a single source.
    public let src: String?

    /// Playback options. Defaults to showing controls.
    public let options: MediaOptions

    /// How much to load before playback, or `nil` for the browser default.
    public let preload: MediaPreload?

    /// The element's content: `Source`s and fallback content.
    public let content: Content

    // MARK: - Initializer

    /// Creates an audio player with sources and fallback built by `content`.
    /// - Parameters:
    ///   - src: The audio URL, when there is a single source.
    ///   - options: Playback options. Defaults to showing controls.
    ///   - preload: How much to load before playback, or `nil` for the browser default.
    ///   - content: The element's content: `Source`s and fallback content.
    public init(
        src: String? = nil,
        options: MediaOptions = .controls,
        preload: MediaPreload? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.src = src
        self.options = options
        self.preload = preload
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["src"] = src
        attributes["preload"] = preload?.rawValue
        for flag in options.flags where flag != "playsinline" { attributes.setFlag(flag) }
        return Element("audio", attributes: attributes, wrapping: content)
    }
}

/// Initializers for audio with a single file and no fallback content.
extension Audio where Content == EmptyView {

    /// Creates an audio player for a single file.
    /// - Parameters:
    ///   - src: The audio URL, when there is a single source.
    ///   - options: Playback options. Defaults to showing controls.
    ///   - preload: How much to load before playback, or `nil` for the browser default.
    public init(src: String, options: MediaOptions = .controls, preload: MediaPreload? = nil) {
        self.init(src: src, options: options, preload: preload) { EmptyView() }
    }
}

/// One media resource for a `Video`, `Audio` or `Picture` (`<source>`).
public struct Source: View {

    // MARK: - Properties

    /// The element's attributes.
    let attributes: HTMLAttributes

    // MARK: - Initializers

    /// A media file for a `Video` or `Audio`, with its MIME type such as
    /// `"video/webm"` so the browser can skip formats it cannot play.
    /// - Parameters:
    ///   - src: The media file URL.
    ///   - type: The MIME type, such as `"video/webm"` or `"image/avif"`.
    public init(src: String, type: String? = nil) {
        var attributes: HTMLAttributes = ["src": src]
        attributes["type"] = type
        self.attributes = attributes
    }

    /// An image candidate for a `Picture`.
    /// - Parameters:
    ///   - srcset: One or more image URLs with width or density descriptors,
    ///     such as `"/img/hero-800.avif 800w, /img/hero-1600.avif 1600w"`.
    ///   - media: A media query that must match, such as `"(min-width: 800px)"`.
    ///   - type: The image MIME type, such as `"image/avif"`.
    ///   - sizes: How wide the image is drawn, for width descriptors.
    public init(srcset: String, media: String? = nil, type: String? = nil, sizes: String? = nil) {
        var attributes: HTMLAttributes = ["srcset": srcset]
        attributes["media"] = media
        attributes["type"] = type
        attributes["sizes"] = sizes
        self.attributes = attributes
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        VoidElement("source", attributes: attributes)
    }
}

/// A timed text track, such as captions, for a `Video` (`<track>`).
public struct Track: View {

    // MARK: - Nested Types

    /// What kind of text the track holds.
    public enum Kind: String, Sendable {
        case subtitles, captions, descriptions, chapters, metadata
    }

    // MARK: - Properties

    /// The WebVTT file URL.
    public let src: String

    /// What kind of text the track holds.
    public let kind: Kind

    /// The track's language, such as `"en"`.
    public let language: String?

    /// The name shown in the browser's track menu.
    public let label: String?

    /// Whether this track is on by default.
    public let isDefault: Bool

    // MARK: - Initializer

    /// Creates a text track.
    /// - Parameters:
    ///   - src: The WebVTT file URL.
    ///   - kind: What kind of text the track holds.
    ///   - language: The track's language, such as `"en"`.
    ///   - label: The name shown in the browser's track menu.
    ///   - isDefault: Whether this track is on by default.
    public init(src: String, kind: Kind = .captions, language: String? = nil, label: String? = nil, isDefault: Bool = false) {
        self.src = src
        self.kind = kind
        self.language = language
        self.label = label
        self.isDefault = isDefault
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes: HTMLAttributes = ["src": src, "kind": kind.rawValue]
        attributes["srclang"] = language
        attributes["label"] = label
        if isDefault { attributes.setFlag("default") }
        return VoidElement("track", attributes: attributes)
    }
}

/// A responsive image: `Source`s the browser chooses from, then an `Image`
/// fallback (`<picture>`).
///
/// ```swift
/// Picture {
///     Source(srcset: "/img/stall.avif", type: "image/avif")
///     Source(srcset: "/img/stall-wide.jpg", media: "(min-width: 800px)")
///     Image(src: "/img/stall.jpg", alt: "The noodle stall at dusk")
/// }
/// ```
///
/// Modifiers apply to the `<picture>`; style the `Image` inside to size the
/// image itself.
public struct Picture<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates the element with the content built by `content`.
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("picture", wrapping: content)
    }
}

/// Another page embedded in this one (`<iframe>`).
///
/// `title` is required, because screen readers announce it. Frames load
/// lazily by default.
public struct IFrame: View {

    // MARK: - Properties

    /// The URL of the embedded page.
    public let src: String

    /// A description of the frame for screen readers.
    public let title: String

    /// The width in pixels, if fixed.
    public let width: Int?

    /// The height in pixels, if fixed.
    public let height: Int?

    /// Whether to wait until the frame is near the viewport before loading it.
    public let isLazy: Bool

    /// Restrictions for untrusted content, such as `"allow-scripts"`. An
    /// empty string applies every restriction; `nil` writes no `sandbox`.
    public let sandbox: String?

    /// The permissions policy, such as `"fullscreen; picture-in-picture"`.
    public let allow: String?

    // MARK: - Initializer

    /// Creates an embedded page.
    /// - Parameters:
    ///   - src: The URL of the embedded page.
    ///   - title: A description of the frame for screen readers.
    ///   - width: The width in pixels, if fixed.
    ///   - height: The height in pixels, if fixed.
    ///   - isLazy: Whether to wait until the frame is near the viewport before loading it.
    ///   - sandbox: Restrictions for untrusted content, such as `"allow-scripts"`. An empty string applies every restriction; `nil` writes no `sandbox`.
    ///   - allow: The permissions policy, such as `"fullscreen; picture-in-picture"`.
    public init(
        src: String,
        title: String,
        width: Int? = nil,
        height: Int? = nil,
        lazy isLazy: Bool = true,
        sandbox: String? = nil,
        allow: String? = nil
    ) {
        self.src = src
        self.title = title
        self.width = width
        self.height = height
        self.isLazy = isLazy
        self.sandbox = sandbox
        self.allow = allow
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<EmptyView> {
        var attributes: HTMLAttributes = ["src": src, "title": title]
        attributes["width"] = width.map(String.init)
        attributes["height"] = height.map(String.init)
        if isLazy { attributes["loading"] = "lazy" }
        attributes["sandbox"] = sandbox
        attributes["allow"] = allow
        return Element("iframe", attributes: attributes)
    }
}

/// An inline SVG drawing (`<svg>`).
///
/// Build the shapes with `Element`, which writes any tag:
///
/// ```swift
/// SVG(viewBox: "0 0 100 100", width: 48, height: 48, label: "A green dot") {
///     Element("circle", attributes: ["cx": "50", "cy": "50", "r": "40", "fill": "seagreen"])
/// }
/// ```
///
/// With a `label`, the drawing is announced as an image with that name.
/// Without one it is marked decorative and hidden from screen readers.
public struct SVG<Content: View>: View {

    // MARK: - Properties

    /// The coordinate system, such as `"0 0 24 24"`.
    public let viewBox: String

    /// The drawn width in pixels, if fixed.
    public let width: Double?

    /// The drawn height in pixels, if fixed.
    public let height: Double?

    /// The accessible name, or `nil` for a decorative drawing.
    public let label: String?

    /// The shapes.
    public let content: Content

    // MARK: - Initializer

    /// Creates an inline drawing whose shapes are built by `content`.
    /// - Parameters:
    ///   - viewBox: The coordinate system, such as `"0 0 24 24"`.
    ///   - width: The drawn width in pixels, if fixed.
    ///   - height: The drawn height in pixels, if fixed.
    ///   - label: The accessible name, or `nil` for a decorative drawing.
    ///   - content: The shapes.
    public init(
        viewBox: String,
        width: Double? = nil,
        height: Double? = nil,
        label: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.viewBox = viewBox
        self.width = width
        self.height = height
        self.label = label
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes: HTMLAttributes = ["xmlns": "http://www.w3.org/2000/svg", "viewBox": viewBox]
        attributes["width"] = width.map(cssNumber)
        attributes["height"] = height.map(cssNumber)
        if let label {
            attributes["role"] = "img"
            attributes["aria-label"] = label
        } else {
            attributes["aria-hidden"] = "true"
        }
        return Element("svg", attributes: attributes, wrapping: content)
    }
}
