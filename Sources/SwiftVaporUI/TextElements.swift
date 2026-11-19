// Inline text-level elements and other small HTML5 elements.

/// Highlighted text, such as a search match (`<mark>`).
public struct Mark<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates the element with the content built by `content`.
    ///
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("mark", wrapping: content)
    }

}

extension Mark where Content == Text {

    // MARK: - Initializers

    /// Creates the element containing escaped `text`.
    ///
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Keyboard input, such as a key or shortcut (`<kbd>`).
public struct Keyboard<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates the element with the content built by `content`.
    ///
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("kbd", wrapping: content)
    }

}

extension Keyboard where Content == Text {

    // MARK: - Initializers

    /// Creates the element containing escaped `text`.
    ///
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Subscript text, such as the 2 in H₂O (`<sub>`).
public struct Subscript<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates the element with the content built by `content`.
    ///
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("sub", wrapping: content)
    }

}

extension Subscript where Content == Text {

    // MARK: - Initializers

    /// Creates the element containing escaped `text`.
    ///
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// Superscript text, such as an exponent (`<sup>`).
public struct Superscript<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates the element with the content built by `content`.
    ///
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("sup", wrapping: content)
    }

}

extension Superscript where Content == Text {

    // MARK: - Initializers

    /// Creates the element containing escaped `text`.
    ///
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// An abbreviation, with its expansion as the `title` (`<abbr>`).
///
/// ```swift
/// Abbreviation("CSS", title: "Cascading Style Sheets")
/// ```
public struct Abbreviation: View {

    // MARK: - Properties

    /// The abbreviation as written.
    public let text: String

    /// The full expansion, shown as a tooltip.
    public let expansion: String?

    // MARK: - Initializers

    /// Creates an abbreviation with an optional expansion.
    ///
    /// - Parameters:
    ///   - text: The abbreviation as written.
    ///   - expansion: The full expansion, shown as a tooltip.
    public init(_ text: String, title expansion: String? = nil) {
        self.text = text
        self.expansion = expansion
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Text> {
        var attributes = HTMLAttributes()
        attributes["title"] = expansion
        return Element("abbr", attributes: attributes, wrapping: Text(text))
    }

}

/// A date or time, readable by people and machines (`<time>`).
///
/// ```swift
/// Time("Saturday evening", dateTime: "2026-11-21T18:00")
/// ```
public struct Time<Content: View>: View {

    // MARK: - Properties

    /// The machine-readable value written to `datetime`, such as
    /// `2026-11-21` or `18:00`.
    public let dateTime: String?

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates the element with the content built by `content`.
    ///
    /// - Parameters:
    ///   - dateTime: The machine-readable value written to `datetime`, such as `2026-11-21` or `18:00`.
    ///   - content: The element's content.
    public init(dateTime: String? = nil, @ViewBuilder content: () -> Content) {
        self.dateTime = dateTime
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["datetime"] = dateTime
        return Element("time", attributes: attributes, wrapping: content)
    }

}

extension Time where Content == Text {

    // MARK: - Initializers

    /// Creates the element containing escaped `text`.
    ///
    /// - Parameters:
    ///   - text: The text, which is escaped when rendered.
    ///   - dateTime: The machine-readable value written to `datetime`, such as `2026-11-21` or `18:00`.
    public init(_ text: String, dateTime: String? = nil) {
        self.init(dateTime: dateTime) { Text(text) }
    }

}

/// A dialog box (`<dialog>`).
///
/// A dialog with `isPresented: true` renders open, inline in the page. To
/// show one as a modal, give it an `id`, open it with
/// `Button(action: .script("document.getElementById('id').showModal()"))`,
/// and close it with a `Form(method: .dialog)` containing a button.
public struct Dialog<Content: View>: View {

    // MARK: - Properties

    /// Whether the dialog renders open (the `open` attribute).
    public let isPresented: Bool

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates a dialog whose content is built by `content`.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the dialog renders open (the `open` attribute).
    ///   - content: The element's content.
    public init(isPresented: Bool = false, @ViewBuilder content: () -> Content) {
        self.isPresented = isPresented
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        if isPresented { attributes.setFlag("open") }
        return Element("dialog", attributes: attributes, wrapping: content)
    }

}

/// The title of a `Table` (`<caption>`). Put it first inside the table.
public struct TableCaption<Content: View>: View {

    // MARK: - Properties

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates the element with the content built by `content`.
    ///
    /// - Parameter content: The element's content.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("caption", wrapping: content)
    }

}

extension TableCaption where Content == Text {

    // MARK: - Initializers

    /// Creates the element containing escaped `text`.
    ///
    /// - Parameter text: The text, which is escaped when rendered.
    public init(_ text: String) {
        self.init { Text(text) }
    }

}

/// A labelled group of options in a `Select` (`<optgroup>`).
public struct OptionGroup<Content: View>: View {

    // MARK: - Properties

    /// The group's visible heading.
    public let label: String

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates a group whose options are built by `content`.
    ///
    /// - Parameters:
    ///   - label: The group's visible heading.
    ///   - content: The element's content.
    public init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("optgroup", attributes: ["label": label], wrapping: content)
    }

}

/// Suggested values for a text field (`<datalist>`).
///
/// Give it an `id` and pass the same id as `TextField(list:)`. Unlike a
/// `Select`, the user can still type any value.
///
/// ```swift
/// TextField("Herb", name: "herb", list: "herbs")
/// DataList(id: "herbs") {
///     Option("Basil")
///     Option("Thyme")
/// }
/// ```
public struct DataList<Content: View>: View {

    // MARK: - Properties

    /// The element `id` that text fields refer to.
    public let id: String

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates a list of suggestions built by `content`.
    ///
    /// - Parameters:
    ///   - id: The element `id` that text fields refer to.
    ///   - content: The element's content.
    public init(id: String, @ViewBuilder content: () -> Content) {
        self.id = id
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("datalist", attributes: ["id": id], wrapping: content)
    }

}

/// A measurement within a known range, such as disk usage (`<meter>`).
///
/// Use `ProgressView` for progress through a task instead.
public struct Meter: View {

    // MARK: - Properties

    /// The measured value.
    public let value: Double

    /// The lowest and highest possible values.
    public let range: ClosedRange<Double>

    /// The upper end of the "low" region, if any.
    public let low: Double?

    /// The lower end of the "high" region, if any.
    public let high: Double?

    /// The best value, which tells the browser which region is good.
    public let optimum: Double?

    /// Text for browsers that cannot draw a meter.
    public let label: String

    // MARK: - Initializers

    /// Creates a meter.
    ///
    /// - Parameters:
    ///   - value: The measured value.
    ///   - range: The lowest and highest possible values.
    ///   - low: The upper end of the "low" region, if any.
    ///   - high: The lower end of the "high" region, if any.
    ///   - optimum: The best value, which tells the browser which region is good.
    ///   - label: Text for browsers that cannot draw a meter.
    public init(
        value: Double,
        in range: ClosedRange<Double> = 0...1,
        low: Double? = nil,
        high: Double? = nil,
        optimum: Double? = nil,
        label: String = ""
    ) {
        self.value = value
        self.range = range
        self.low = low
        self.high = high
        self.optimum = optimum
        self.label = label
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Text> {
        var attributes: HTMLAttributes = [
            "value": cssNumber(value),
            "min": cssNumber(range.lowerBound),
            "max": cssNumber(range.upperBound),
        ]
        attributes["low"] = low.map(cssNumber)
        attributes["high"] = high.map(cssNumber)
        attributes["optimum"] = optimum.map(cssNumber)
        return Element("meter", attributes: attributes, wrapping: Text(label))
    }

}

/// The result of a calculation or user action (`<output>`).
public struct Output<Content: View>: View {

    // MARK: - Properties

    /// The field name, for forms and for scripts.
    public let name: String?

    /// The `id`s of the controls the result comes from, written as `for`.
    public let sources: [String]

    /// The element's content.
    public let content: Content

    // MARK: - Initializers

    /// Creates an output whose initial content is built by `content`.
    ///
    /// - Parameters:
    ///   - name: The field name, for forms and for scripts.
    ///   - sources: The `id`s of the controls the result comes from, written as `for`.
    ///   - content: The element's content.
    public init(name: String? = nil, for sources: [String] = [], @ViewBuilder content: () -> Content) {
        self.name = name
        self.sources = sources
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["name"] = name
        if !sources.isEmpty {
            attributes["for"] = sources.joined(separator: " ")
        }
        return Element("output", attributes: attributes, wrapping: content)
    }

}

extension Output where Content == Text {

    // MARK: - Initializers

    /// Creates an output containing escaped `text`.
    ///
    /// - Parameters:
    ///   - text: The text, which is escaped when rendered.
    ///   - name: The field name, for forms and for scripts.
    ///   - sources: The `id`s of the controls the result comes from, written as `for`.
    public init(_ text: String, name: String? = nil, for sources: [String] = []) {
        self.init(name: name, for: sources) { Text(text) }
    }

}
