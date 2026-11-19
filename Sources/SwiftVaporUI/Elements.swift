// Simple container elements. Each renders its content inside one tag.

/// A generic block container (`<div>`).
public struct Div<Content: View>: View {

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
        Element("div", wrapping: content)
    }

}

/// A generic inline container (`<span>`).
public struct Span<Content: View>: View {

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
        Element("span", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Span where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A thematic section of a page (`<section>`).
public struct Section<Content: View>: View {

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
        Element("section", wrapping: content)
    }

}

/// Introductory content for a page or section (`<header>`).
public struct Header<Content: View>: View {

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
        Element("header", wrapping: content)
    }

}

/// Footer content for a page or section (`<footer>`).
public struct Footer<Content: View>: View {

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
        Element("footer", wrapping: content)
    }

}

/// A block of navigation links (`<nav>`).
public struct Nav<Content: View>: View {

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
        Element("nav", wrapping: content)
    }

}

/// The main content of the page (`<main>`).
public struct Main<Content: View>: View {

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
        Element("main", wrapping: content)
    }

}

/// Self-contained content (`<article>`).
public struct Article<Content: View>: View {

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
        Element("article", wrapping: content)
    }

}

/// Content related to the surrounding content (`<aside>`).
public struct Aside<Content: View>: View {

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
        Element("aside", wrapping: content)
    }

}

/// A paragraph (`<p>`).
public struct Paragraph<Content: View>: View {

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
        Element("p", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Paragraph where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Text of strong importance (`<strong>`).
public struct Strong<Content: View>: View {

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
        Element("strong", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Strong where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Emphasised text (`<em>`).
public struct Emphasis<Content: View>: View {

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
        Element("em", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Emphasis where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Side comments and fine print (`<small>`).
public struct Small<Content: View>: View {

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
        Element("small", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Small where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A fragment of code (`<code>`).
public struct Code<Content: View>: View {

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
        Element("code", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Code where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Preformatted text (`<pre>`).
public struct Preformatted<Content: View>: View {

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
        Element("pre", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Preformatted where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A quotation (`<blockquote>`).
public struct Blockquote<Content: View>: View {

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
        Element("blockquote", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Blockquote where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A bulleted list (`<ul>`).
public struct UnorderedList<Content: View>: View {

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
        Element("ul", wrapping: content)
    }

}

/// A numbered list (`<ol>`).
public struct OrderedList<Content: View>: View {

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
        Element("ol", wrapping: content)
    }

}

/// An item in a list (`<li>`).
public struct ListItem<Content: View>: View {

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
        Element("li", wrapping: content)
    }

}

/// Initializers that take plain text.
extension ListItem where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Self-contained figure content (`<figure>`).
public struct Figure<Content: View>: View {

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
        Element("figure", wrapping: content)
    }

}

/// A caption for a `Figure` (`<figcaption>`).
public struct FigureCaption<Content: View>: View {

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
        Element("figcaption", wrapping: content)
    }

}

/// Initializers that take plain text.
extension FigureCaption where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A disclosure widget (`<details>`).
public struct Details<Content: View>: View {

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
        Element("details", wrapping: content)
    }

}

/// The visible label of a `Details` (`<summary>`).
public struct Summary<Content: View>: View {

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
        Element("summary", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Summary where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A group of form controls (`<fieldset>`).
public struct Fieldset<Content: View>: View {

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
        Element("fieldset", wrapping: content)
    }

}

/// The caption of a `Fieldset` (`<legend>`).
public struct Legend<Content: View>: View {

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
        Element("legend", wrapping: content)
    }

}

/// Initializers that take plain text.
extension Legend where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A list of terms and descriptions (`<dl>`).
public struct DescriptionList<Content: View>: View {

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
        Element("dl", wrapping: content)
    }

}

/// A term in a `DescriptionList` (`<dt>`).
public struct DescriptionTerm<Content: View>: View {

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
        Element("dt", wrapping: content)
    }

}

/// Initializers that take plain text.
extension DescriptionTerm where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// The description of a term (`<dd>`).
public struct DescriptionDetail<Content: View>: View {

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
        Element("dd", wrapping: content)
    }

}

/// Initializers that take plain text.
extension DescriptionDetail where Content == Text {

    /// Creates the element containing escaped `text`.
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Markup the browser holds but does not render (`<template>`), for use from scripts.
public struct Template<Content: View>: View {

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
        Element("template", wrapping: content)
    }

    /// Writes the template. Support styles written inline inside it do not
    /// apply to the page, so they are written again where they are next needed.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        let written = renderer.writtenSupportStyles
        body._render(into: &renderer)
        if renderer.collectedSupportStyles == nil {
            renderer.writtenSupportStyles = written
        }
    }

}

/// The document head (`<head>`). `HTMLDocument` writes this for you.
public struct Head<Content: View>: View {

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
        Element("head", wrapping: content)
    }

}

/// The document body (`<body>`). Named so it does not clash with `View.Body`.
public struct DocumentBody<Content: View>: View {

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
        Element("body", wrapping: content)
    }

}
