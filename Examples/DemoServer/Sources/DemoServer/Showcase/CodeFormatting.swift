import SwiftVaporUI

/// A small Swift syntax highlighter, enough to make the snippets easy to
/// read. It returns escaped HTML with `<span class="tok-…">` around tokens.
enum SwiftHighlighter {

    // MARK: - Static Properties

    /// The Swift keywords to colour.
    static let keywords: Set<String> = [
        "let", "var", "func", "struct", "enum", "class", "protocol", "extension", "init",
        "if", "else", "for", "in", "while", "switch", "case", "default", "return", "guard",
        "some", "any", "where", "import", "static", "private", "fileprivate", "public",
        "true", "false", "nil", "self", "Self", "try", "await", "async", "throws", "do", "catch",
        "typealias", "associatedtype", "break", "continue", "mutating", "inout", "let",
    ]

    // MARK: - Methods

    /// Colours Swift source with `<span>`s.
    /// - Parameter code: The Swift source.
    /// - Returns: Escaped HTML with token spans.
    static func highlight(_ code: String) -> String {
        let chars = Array(code)
        var html = ""
        var index = 0
        var previousNonSpace: Character?

        /// Writes a token, wrapped in a span when it has a kind.
        /// - Parameters:
        ///   - text: The token's source text.
        ///   - kind: The token kind used as the CSS class suffix, or `nil` for plain text.
        func emit(_ text: String, _ kind: String?) {
            let escaped = HTMLEscaping.escapeText(text)
            if let kind {
                html += "<span class=\"tok-\(kind)\">\(escaped)</span>"
            } else {
                html += escaped
            }
        }

        while index < chars.count {
            let char = chars[index]

            // Line comment.
            if char == "/", index + 1 < chars.count, chars[index + 1] == "/" {
                var end = index
                while end < chars.count, chars[end] != "\n" { end += 1 }
                emit(String(chars[index..<end]), "comment")
                index = end
                continue
            }

            // String literal, including multi-line ones. Interpolations
            // stay inside the string colour, which keeps this simple.
            if char == "\"" {
                let isMultiline = index + 2 < chars.count && chars[index + 1] == "\"" && chars[index + 2] == "\""
                var end = index + (isMultiline ? 3 : 1)
                while end < chars.count {
                    if chars[end] == "\\" { end += 2; continue }
                    if isMultiline {
                        if end + 2 < chars.count, chars[end] == "\"", chars[end + 1] == "\"", chars[end + 2] == "\"" {
                            end += 3
                            break
                        }
                    } else if chars[end] == "\"" || chars[end] == "\n" {
                        end += 1
                        break
                    }
                    end += 1
                }
                end = min(end, chars.count)
                emit(String(chars[index..<end]), "string")
                previousNonSpace = "\""
                index = end
                continue
            }

            // Numbers.
            if char.isNumber {
                var end = index
                while end < chars.count, chars[end].isNumber || chars[end] == "." || chars[end] == "_" { end += 1 }
                emit(String(chars[index..<end]), "number")
                previousNonSpace = chars[end - 1]
                index = end
                continue
            }

            // Identifiers, keywords, types and attributes.
            if char.isLetter || char == "_" || char == "@" || char == "#" {
                var end = index + 1
                while end < chars.count, chars[end].isLetter || chars[end].isNumber || chars[end] == "_" { end += 1 }
                let word = String(chars[index..<end])
                let kind: String?
                if char == "@" || char == "#" {
                    kind = "attribute"
                } else if keywords.contains(word) && previousNonSpace != "." {
                    kind = "keyword"
                } else if previousNonSpace == "." {
                    kind = "member"
                } else if word.first?.isUppercase == true {
                    kind = "type"
                } else if end < chars.count, chars[end] == "(" {
                    kind = "call"
                } else {
                    kind = nil
                }
                emit(word, kind)
                previousNonSpace = chars[end - 1]
                index = end
                continue
            }

            emit(String(char), nil)
            if !char.isWhitespace { previousNonSpace = char }
            index += 1
        }
        return html
    }
}

/// Indents rendered HTML so it is readable on the page: each block-level
/// tag goes on its own line, while inline tags and text stay together.
enum HTMLFormatter {

    // MARK: - Static Properties

    /// Tags that start a new indented line.
    static let blockTags: Set<String> = [
        "html", "head", "body", "title", "meta", "link", "style", "script",
        "div", "section", "header", "footer", "nav", "main", "article", "aside",
        "h1", "h2", "h3", "h4", "h5", "h6", "p", "pre", "blockquote", "hr", "br",
        "ul", "ol", "li", "dl", "dt", "dd", "table", "thead", "tbody", "tfoot", "tr", "th", "td",
        "figure", "figcaption", "details", "summary", "form", "fieldset", "legend",
        "label", "input", "select", "option", "textarea", "button", "template", "img",
    ]

    /// Tags with no closing tag.
    static let voidTags: Set<String> = ["meta", "link", "hr", "br", "input", "img"]

    /// Tags whose content is kept on the same line as the tag.
    static let leafTags: Set<String> = [
        "title", "h1", "h2", "h3", "h4", "h5", "h6", "p", "li", "dt", "dd", "th", "td",
        "figcaption", "summary", "legend", "label", "option", "textarea", "button", "pre",
    ]

    // MARK: - Methods

    /// Indents HTML so it is readable.
    /// - Parameter html: The HTML on one line.
    /// - Returns: The HTML on several indented lines.
    static func format(_ html: String) -> String {
        var lines: [String] = []
        var line = ""
        var depth = 0
        var leafDepth = 0
        var rest = Substring(html)

        /// Writes the text collected so far as one line.
        func flush() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                lines.append(String(repeating: "  ", count: max(depth, 0)) + trimmed)
            }
            line = ""
        }

        while !rest.isEmpty {
            guard rest.first == "<" else {
                let end = rest.firstIndex(of: "<") ?? rest.endIndex
                line += rest[..<end]
                rest = rest[end...]
                continue
            }
            guard let close = rest.firstIndex(of: ">") else {
                line += rest
                break
            }
            let tag = String(rest[...close])
            rest = rest[rest.index(after: close)...]

            let isClosing = tag.hasPrefix("</")
            let name = tag
                .dropFirst(isClosing ? 2 : 1)
                .prefix(while: { $0.isLetter || $0.isNumber || $0 == "-" })
                .lowercased()

            // Keep script and style bodies exactly as they are.
            if !isClosing, name == "script" || name == "style" {
                let closingTag = "</\(name)>"
                let end = rest.range(of: closingTag)?.lowerBound ?? rest.endIndex
                flush()
                line = tag + rest[..<end] + (end < rest.endIndex ? closingTag : "")
                rest = end < rest.endIndex ? rest[rest.index(end, offsetBy: closingTag.count)...] : ""
                flush()
                continue
            }

            // Inside a leaf such as <li>, everything stays on one line.
            if leafDepth > 0 {
                line += tag
                if leafTags.contains(name) {
                    leafDepth += isClosing ? -1 : 1
                    if leafDepth == 0 { flush() }
                }
                continue
            }

            guard blockTags.contains(name) else {
                line += tag
                continue
            }

            if isClosing {
                if leafTags.contains(name) {
                    line += tag
                    flush()
                } else {
                    flush()
                    depth -= 1
                    line = tag
                    flush()
                }
            } else if voidTags.contains(name) {
                flush()
                line = tag
                flush()
            } else if leafTags.contains(name) {
                flush()
                line = tag
                leafDepth += 1
            } else {
                flush()
                line = tag
                flush()
                depth += 1
            }
        }
        flush()
        return lines.joined(separator: "\n")
    }
}
