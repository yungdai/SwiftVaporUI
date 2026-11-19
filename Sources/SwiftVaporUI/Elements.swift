// Simple container elements. Each renders its content inside one tag.

/// A generic block container (`<div>`).
public struct Div<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("div", wrapping: content)
    }
}

/// A generic inline container (`<span>`).
public struct Span<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("span", wrapping: content)
    }
}

extension Span where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A thematic section of a page (`<section>`).
public struct Section<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("section", wrapping: content)
    }
}

/// Introductory content for a page or section (`<header>`).
public struct Header<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("header", wrapping: content)
    }
}

/// Footer content for a page or section (`<footer>`).
public struct Footer<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("footer", wrapping: content)
    }
}

/// A block of navigation links (`<nav>`).
public struct Nav<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("nav", wrapping: content)
    }
}

/// The main content of the page (`<main>`).
public struct Main<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("main", wrapping: content)
    }
}

/// Self-contained content (`<article>`).
public struct Article<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("article", wrapping: content)
    }
}

/// Content related to the surrounding content (`<aside>`).
public struct Aside<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("aside", wrapping: content)
    }
}

/// A paragraph (`<p>`).
public struct Paragraph<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("p", wrapping: content)
    }
}

extension Paragraph where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Text of strong importance (`<strong>`).
public struct Strong<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("strong", wrapping: content)
    }
}

extension Strong where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Emphasised text (`<em>`).
public struct Emphasis<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("em", wrapping: content)
    }
}

extension Emphasis where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Side comments and fine print (`<small>`).
public struct Small<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("small", wrapping: content)
    }
}

extension Small where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A fragment of code (`<code>`).
public struct Code<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("code", wrapping: content)
    }
}

extension Code where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Preformatted text (`<pre>`).
public struct Preformatted<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("pre", wrapping: content)
    }
}

extension Preformatted where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A quotation (`<blockquote>`).
public struct Blockquote<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("blockquote", wrapping: content)
    }
}

extension Blockquote where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A bulleted list (`<ul>`).
public struct UnorderedList<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("ul", wrapping: content)
    }
}

/// A numbered list (`<ol>`).
public struct OrderedList<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("ol", wrapping: content)
    }
}

/// An item in a list (`<li>`).
public struct ListItem<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("li", wrapping: content)
    }
}

extension ListItem where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A table (`<table>`).
public struct Table<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("table", wrapping: content)
    }
}

/// The header rows of a table (`<thead>`).
public struct TableHead<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("thead", wrapping: content)
    }
}

/// The body rows of a table (`<tbody>`).
public struct TableBody<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("tbody", wrapping: content)
    }
}

/// The footer rows of a table (`<tfoot>`).
public struct TableFooter<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("tfoot", wrapping: content)
    }
}

/// A table row (`<tr>`).
public struct TableRow<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("tr", wrapping: content)
    }
}

/// A header cell (`<th>`).
public struct TableHeaderCell<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("th", wrapping: content)
    }
}

extension TableHeaderCell where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A data cell (`<td>`).
public struct TableCell<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("td", wrapping: content)
    }
}

extension TableCell where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// Self-contained figure content (`<figure>`).
public struct Figure<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("figure", wrapping: content)
    }
}

/// A caption for a `Figure` (`<figcaption>`).
public struct FigureCaption<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("figcaption", wrapping: content)
    }
}

extension FigureCaption where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A disclosure widget (`<details>`).
public struct Details<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("details", wrapping: content)
    }
}

/// The visible label of a `Details` (`<summary>`).
public struct Summary<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("summary", wrapping: content)
    }
}

extension Summary where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

/// A group of form controls (`<fieldset>`).
public struct Fieldset<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("fieldset", wrapping: content)
    }
}

/// The caption of a `Fieldset` (`<legend>`).
public struct Legend<Content: View>: View {
    public let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: Element<Content> {
        Element("legend", wrapping: content)
    }
}

extension Legend where Content == Text {
    /// Creates the element containing escaped `text`.
    public init(_ text: String) {
        self.init { Text(text) }
    }
}
