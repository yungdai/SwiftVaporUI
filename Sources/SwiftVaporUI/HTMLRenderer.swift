/// Accumulates the HTML output of a view tree.
///
/// Modifiers such as `.class(_:)` do not write anything themselves. They
/// queue attribute changes, and the next HTML element rendered inside them
/// picks those changes up.
public struct HTMLRenderer: Sendable {

    // MARK: - Properties

    /// Attribute changes waiting for the next element, innermost modifier first.
    var pending: [AttributeChange] = []

    /// Keys of the support style sheets already written, so each is written once.
    var writtenSupportStyles: Set<String> = []

    /// The `TabView` currently being rendered, if any.
    var tabGroup: TabGroupState?

    /// Support styles that views asked for while rendering a document's body.
    /// When this is set, `writeSupportStyle(_:)` collects styles here for
    /// `HTMLDocument` to write in the head, instead of writing them inline.
    var collectedSupportStyles: [SupportStyle]?

    /// The CSP nonce in the environment where a collected support style was
    /// first asked for, so the head's `<style>` carries it even though the
    /// head is written outside the body's environment.
    var collectedSupportStyleNonce: String?

    /// The HTML written so far.
    public internal(set) var output = ""

    // MARK: - Initializer

    /// Creates an empty renderer.
    public init() {}

    // MARK: - Methods

    /// Makes sure the CSS a built-in view needs is on the page, once.
    ///
    /// Inside an `HTMLDocument`, the style is collected and written in the
    /// document's `<head>`. In a fragment, it is written inline as a small
    /// `<style>` element the first time it is needed.
    /// - Parameter style: The style sheet the view needs.
    mutating func writeSupportStyle(_ style: SupportStyle) {
        guard writtenSupportStyles.insert(style.key).inserted else { return }
        if collectedSupportStyles != nil {
            collectedSupportStyles?.append(style)
            if collectedSupportStyleNonce == nil {
                collectedSupportStyleNonce = EnvironmentValues.current.cspNonce
            }
        } else {
            output += SupportStyle.styleElement(for: [style])
        }
    }

    /// Writes markup exactly as given.
    /// - Parameter string: The markup to write.
    mutating func write(_ string: String) {
        output += string
    }

    /// Writes text, escaping it.
    /// - Parameter string: The unescaped text.
    mutating func writeEscapedText(_ string: String) {
        output += HTMLEscaping.escapeText(string)
    }

    /// Applies and clears queued modifier changes on top of `attributes`.
    /// - Parameter attributes: The attributes to write, already including any modifier changes.
    mutating func takePending(applyingTo attributes: inout HTMLAttributes) {
        for change in pending {
            attributes.apply(change)
        }
        pending.removeAll()
    }

    /// Writes an opening tag with its attributes.
    /// - Parameters:
    ///   - tag: The tag name, already checked to be valid.
    ///   - attributes: The attributes to write, already including any modifier changes.
    mutating func writeOpeningTag(_ tag: String, attributes: HTMLAttributes) {
        output += "<"
        output += tag
        for attribute in attributes.storage {
            output += " "
            output += attribute.name
            if let value = attribute.value {
                output += "=\""
                let safe = HTMLEscaping.isURLAttribute(attribute.name) ? HTMLEscaping.safeURL(value) : value
                output += HTMLEscaping.escapeAttribute(safe)
                output += "\""
            }
        }
        output += ">"
        // The parser drops one newline right after these opening tags, so
        // write one ourselves and content that starts with a newline keeps it.
        if tag == "pre" || tag == "textarea" || tag == "listing" {
            output += "\n"
        }
    }

}

/// Escaping helpers used by the renderer. Exposed for use in custom views.
public enum HTMLEscaping {

    /// Escapes text placed between tags.
    /// - Parameter string: The unescaped string.
    /// - Returns: The escaped text.
    public static func escapeText(_ string: String) -> String {
        escape(string, quotes: false)
    }

    /// Escapes a value placed inside a double-quoted attribute.
    /// - Parameter string: The unescaped string.
    /// - Returns: The escaped value.
    public static func escapeAttribute(_ string: String) -> String {
        escape(string, quotes: true)
    }

    /// Escapes `&`, `<` and `>`, and quotes too when asked.
    /// - Parameters:
    ///   - string: The unescaped string.
    ///   - quotes: Whether to escape double and single quotes.
    /// - Returns: The escaped string.
    private static func escape(_ string: String, quotes: Bool) -> String {
        guard string.utf8.contains(where: { $0 == 0x26 || $0 == 0x3C || $0 == 0x3E || (quotes && ($0 == 0x22 || $0 == 0x27)) }) else {
            return string
        }
        var result = ""
        result.reserveCapacity(string.utf8.count + 16)
        for scalar in string.unicodeScalars {
            switch scalar {
            case "&": result += "&amp;"
            case "<": result += "&lt;"
            case ">": result += "&gt;"
            case "\"" where quotes: result += "&quot;"
            case "'" where quotes: result += "&#39;"
            default: result.unicodeScalars.append(scalar)
            }
        }
        return result
    }

    /// Whether an attribute holds a URL that a browser may navigate to or load.
    /// - Parameter name: The attribute name.
    /// - Returns: Whether the attribute's value is checked by `safeURL(_:)`.
    public static func isURLAttribute(_ name: String) -> Bool {
        switch name.lowercased() {
        case "href", "src", "action", "formaction", "poster", "cite", "data", "xlink:href":
            return true
        default:
            return false
        }
    }

    /// Replaces a URL that would run script with `#`.
    ///
    /// `javascript:` and `vbscript:` URLs run code when followed, so a link
    /// built from user input could otherwise be used for cross-site
    /// scripting. Browsers ignore spaces, control characters and case in the
    /// scheme, so this does too. Every other URL, including relative ones, is
    /// returned unchanged. To run script from a button, use
    /// `ButtonAction.script(_:)` instead.
    /// - Parameter url: The URL as given.
    /// - Returns: The URL, or `#` when it uses a scripting scheme.
    public static func safeURL(_ url: String) -> String {
        var scheme = ""
        for scalar in url.unicodeScalars {
            if scalar == ":" { break }
            if scalar.value <= 0x20 || scalar.value == 0x7F { continue }
            scheme.unicodeScalars.append(scalar)
            if scheme.count > 10 { return url }
        }
        switch scheme.lowercased() {
        case "javascript", "vbscript":
            return "#"
        default:
            return url
        }
    }

    /// Whether `name` is safe to emit as an attribute name.
    ///
    /// Allows ASCII letters, digits and `- _ : . @`, which covers standard,
    /// `data-*`, `aria-*` and common framework attributes (for example
    /// `hx-get` or `@click`). Anything else is dropped rather than risk
    /// breaking out of the tag.
    /// - Parameter name: The name to check.
    /// - Returns: Whether the name can be written as an attribute.
    public static func isValidAttributeName(_ name: String) -> Bool {
        !name.isEmpty && name.utf8.allSatisfy { byte in
            switch byte {
            case UInt8(ascii: "a")...UInt8(ascii: "z"),
                 UInt8(ascii: "A")...UInt8(ascii: "Z"),
                 UInt8(ascii: "0")...UInt8(ascii: "9"),
                 UInt8(ascii: "-"), UInt8(ascii: "_"), UInt8(ascii: ":"),
                 UInt8(ascii: "."), UInt8(ascii: "@"):
                return true
            default:
                return false
            }
        }
    }

    /// Whether `name` is safe to emit as a tag name: an ASCII letter
    /// followed by letters, digits or hyphens.
    /// - Parameter name: The name to check.
    /// - Returns: Whether the name can be written as a tag.
    public static func isValidTagName(_ name: String) -> Bool {
        guard let first = name.utf8.first,
              (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(first | 0x20) else {
            return false
        }
        return name.utf8.allSatisfy { byte in
            switch byte {
            case UInt8(ascii: "a")...UInt8(ascii: "z"),
                 UInt8(ascii: "A")...UInt8(ascii: "Z"),
                 UInt8(ascii: "0")...UInt8(ascii: "9"),
                 UInt8(ascii: "-"):
                return true
            default:
                return false
            }
        }
    }

}
