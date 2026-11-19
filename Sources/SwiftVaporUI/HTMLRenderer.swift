/// Accumulates the HTML output of a view tree.
///
/// Modifiers such as `.class(_:)` do not write anything themselves. They
/// queue attribute changes, and the next HTML element rendered inside them
/// picks those changes up.
public struct HTMLRenderer: Sendable {
    /// The HTML written so far.
    public internal(set) var output = ""

    /// Attribute changes waiting for the next element, innermost modifier first.
    var pending: [AttributeChange] = []

    /// Creates an empty renderer.
    public init() {}

    mutating func write(_ string: String) {
        output += string
    }

    mutating func writeEscapedText(_ string: String) {
        output += HTMLEscaping.escapeText(string)
    }

    /// Applies and clears queued modifier changes on top of `attributes`.
    mutating func takePending(applyingTo attributes: inout HTMLAttributes) {
        for change in pending {
            attributes.apply(change)
        }
        pending.removeAll()
    }

    mutating func writeOpeningTag(_ tag: String, attributes: HTMLAttributes) {
        output += "<"
        output += tag
        for attribute in attributes.storage {
            output += " "
            output += attribute.name
            if let value = attribute.value {
                output += "=\""
                output += HTMLEscaping.escapeAttribute(value)
                output += "\""
            }
        }
        output += ">"
    }
}

/// Escaping helpers used by the renderer. Exposed for use in custom views.
public enum HTMLEscaping {
    /// Escapes text placed between tags.
    public static func escapeText(_ string: String) -> String {
        escape(string, quotes: false)
    }

    /// Escapes a value placed inside a double-quoted attribute.
    public static func escapeAttribute(_ string: String) -> String {
        escape(string, quotes: true)
    }

    /// Replaces `&`, `<` and `>` (and both quote characters when `quotes` is true) with HTML entities.
    private static func escape(_ string: String, quotes: Bool) -> String {
        guard string.utf8.contains(where: { $0 == 0x26 || $0 == 0x3C || $0 == 0x3E || $0 == 0x22 || $0 == 0x27 }) else {
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

    /// Whether `name` is safe to emit as an attribute name.
    ///
    /// Allows ASCII letters, digits and `- _ : . @`, which covers standard,
    /// `data-*`, `aria-*` and common framework attributes (for example
    /// `hx-get` or `@click`). Anything else is dropped rather than risk
    /// breaking out of the tag.
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
