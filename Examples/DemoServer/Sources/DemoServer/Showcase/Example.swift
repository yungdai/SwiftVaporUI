import Foundation
import SwiftVaporUI

/// One live example on a showcase page: a view, plus the Swift source that
/// produced it.
///
/// The source is not a copy. It is read from this package's own Swift files
/// at runtime, between a pair of marker comments:
///
///     // snippet: headings
///     Heading("Hello")
///     // end-snippet
///
/// So the code you see on the page is always the code that rendered the
/// result next to it. Edit the file, run again, and both change together.
/// A snippet id may appear more than once in a file (for example a helper
/// view defined at the top of the file and its use further down); the
/// regions are shown one after another.
struct Example: Sendable {
    let id: String
    let title: String
    let summary: String
    let preview: AnyView
    let snippetID: String
    let file: String
    /// Show the result in an `<iframe>` instead of inline. Used for full
    /// HTML documents, which cannot be nested inside another page.
    let isolated: Bool

    init<Preview: View>(
        _ id: String,
        title: String,
        summary: String = "",
        snippet: String? = nil,
        isolated: Bool = false,
        file: String = #filePath,
        @ViewBuilder preview: () -> Preview
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.preview = AnyView(preview())
        self.snippetID = snippet ?? id
        self.file = file
        self.isolated = isolated
    }

    /// The Swift source between this example's markers.
    var source: SourceSnippet {
        SourceLibrary.shared.snippet(snippetID, in: file)
    }

    /// The HTML the example renders.
    var html: String {
        preview.render()
    }
}

/// Swift source extracted from a file, with where it came from.
struct SourceSnippet: Sendable {
    let code: String
    /// The file path relative to the demo package, such as
    /// `Sources/DemoServer/Showcase/Topics/TextTopic.swift`.
    let displayPath: String
    /// The first line of the snippet in that file, counting from 1.
    let line: Int?
}

/// Reads and caches the demo's own source files.
final class SourceLibrary: @unchecked Sendable {
    static let shared = SourceLibrary()

    private let lock = NSLock()
    private var files: [String: [String]] = [:]

    func snippet(_ id: String, in path: String) -> SourceSnippet {
        let displayPath = Self.displayPath(for: path)
        guard let lines = lines(of: path) else {
            return SourceSnippet(
                code: "// The source file could not be read at \(path).\n// Run the server from a checkout of the repository to see the code.",
                displayPath: displayPath,
                line: nil
            )
        }

        var regions: [[String]] = []
        var current: [String]?
        var firstLine: Int?
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed == "// snippet: \(id)" {
                current = []
                if firstLine == nil { firstLine = index + 2 }
            } else if trimmed == "// end-snippet", let region = current {
                regions.append(region)
                current = nil
            } else if trimmed.hasPrefix("// snippet:") || trimmed == "// end-snippet" {
                continue
            } else if current != nil {
                current?.append(line)
            }
        }

        guard !regions.isEmpty else {
            return SourceSnippet(code: "// No snippet named \"\(id)\" in this file.", displayPath: displayPath, line: nil)
        }
        let code = regions.map { Self.dedent($0).joined(separator: "\n") }.joined(separator: "\n\n")
        return SourceSnippet(code: code, displayPath: displayPath, line: firstLine)
    }

    private func lines(of path: String) -> [String]? {
        lock.lock()
        defer { lock.unlock() }
        if let cached = files[path] { return cached }
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        let lines = contents.components(separatedBy: "\n")
        files[path] = lines
        return lines
    }

    /// Removes the indentation common to every non-blank line, and blank
    /// lines at the start and end.
    static func dedent(_ lines: [String]) -> [String] {
        var lines = lines
        while let first = lines.first, first.trimmingCharacters(in: .whitespaces).isEmpty { lines.removeFirst() }
        while let last = lines.last, last.trimmingCharacters(in: .whitespaces).isEmpty { lines.removeLast() }
        let indent = lines
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .map { $0.prefix(while: { $0 == " " }).count }
            .min() ?? 0
        return lines.map { $0.count >= indent ? String($0.dropFirst(indent)) : $0.trimmingCharacters(in: .whitespaces) }
    }

    static func displayPath(for path: String) -> String {
        if let range = path.range(of: "/Sources/DemoServer/") {
            return "Sources/DemoServer/" + path[range.upperBound...]
        }
        return (path as NSString).lastPathComponent
    }
}
