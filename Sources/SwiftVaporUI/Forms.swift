/// The HTTP method a `Form` submits with.
public enum FormMethod: String, Sendable {

    /// Sends the fields in the URL query. Use for searches and filters.
    case get

    /// Sends the fields in the request body. Use for changes.
    case post

    /// Closes the enclosing `Dialog` instead of submitting to the server.
    case dialog
}

/// A form (`<form>`).
public struct Form<Content: View>: View {

    // MARK: - Properties

    /// The URL the form submits to. `nil` submits to the current URL.
    public let action: String?

    /// The HTTP method the form submits with.
    public let method: FormMethod

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a form that submits to `action` with `method`.
    /// - Parameters:
    ///   - action: The URL the form submits to. `nil` submits to the current URL.
    ///   - method: The HTTP method the form submits with.
    ///   - content: The element's content.
    public init(action: String? = nil, method: FormMethod = .post, @ViewBuilder content: () -> Content) {
        self.action = action
        self.method = method
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes: HTMLAttributes = ["method": method.rawValue]
        attributes["action"] = action
        return Element("form", attributes: attributes, wrapping: content)
    }
}

/// What a `Button` does when it is pressed.
public enum ButtonAction: Sendable, Equatable {

    /// Submits the enclosing form (`<button type="submit">`). This is the
    /// default, as in HTML.
    case submit

    /// Resets the enclosing form (`<button type="reset">`).
    case reset

    /// Does nothing by itself (`<button type="button">`). Attach behaviour
    /// with your own script or attributes.
    case plain

    /// Goes to a URL. Renders an `<a href>` so it works without JavaScript;
    /// style it like a button with a class.
    case navigate(to: String)

    /// Runs inline JavaScript from an `onclick` attribute. The code is
    /// attribute-escaped but otherwise trusted, so never build it from user input.
    case script(String)
}

/// A button, in the style of SwiftUI's `Button`.
///
/// ```swift
/// Button("Save")                                   // submits its form
/// Button("Cancel", action: .navigate(to: "/"))     // a link
/// Button("Close", action: .script("dialog.close()"))
/// ```
public struct Button<Label: View>: View {

    // MARK: - Properties

    /// What the button does when pressed.
    public let action: ButtonAction

    /// The button's visible content.
    public let label: Label

    // MARK: - Initializer

    /// Creates a button whose visible content is built by `label`.
    /// - Parameters:
    ///   - action: What the button does when pressed.
    ///   - label: The button's visible content.
    public init(action: ButtonAction = .submit, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        switch action {
        case .submit:
            Element("button", attributes: ["type": "submit"], wrapping: label)
        case .reset:
            Element("button", attributes: ["type": "reset"], wrapping: label)
        case .plain:
            Element("button", attributes: ["type": "button"], wrapping: label)
        case let .navigate(destination):
            Element("a", attributes: ["href": destination], wrapping: label)
        case let .script(code):
            Element("button", attributes: ["type": "button", "onclick": code], wrapping: label)
        }
    }
}

/// Initializers that take plain text.
extension Button where Label == Text {

    /// Creates a button with escaped `title` as its text.
    /// - Parameters:
    ///   - title: The visible text, which is escaped when rendered.
    ///   - action: What the button does when pressed.
    public init(_ title: String, action: ButtonAction = .submit) {
        self.init(action: action) { Text(title) }
    }
}

/// A caption for a form control (`<label>`).
public struct Label<Content: View>: View {

    // MARK: - Properties

    /// The `id` of the control this label describes, written as `for`.
    public let forID: String?

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a label for the control with the given `id`.
    /// - Parameters:
    ///   - id: The `id` of the control the label describes.
    ///   - content: The element's content.
    public init(for id: String? = nil, @ViewBuilder content: () -> Content) {
        self.forID = id
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["for"] = forID
        return Element("label", attributes: attributes, wrapping: content)
    }
}

/// Initializers that take plain text.
extension Label where Content == Text {

    /// Creates a label with escaped `title` as its text.
    /// - Parameters:
    ///   - title: The label text, which is escaped when rendered.
    ///   - id: The `id` of the control the label describes.
    public init(_ title: String, for id: String? = nil) {
        self.init(for: id) { Text(title) }
    }
}

/// The `type` of an `Input`.
public struct InputType: RawRepresentable, Sendable, Hashable, ExpressibleByStringLiteral {

    // MARK: - Static Properties

    /// A single-line text input.
    public static let text: InputType = "text"

    /// An email address input.
    public static let email: InputType = "email"

    /// A password input.
    public static let password: InputType = "password"

    /// A number input.
    public static let number: InputType = "number"

    /// A search input.
    public static let search: InputType = "search"

    /// A telephone number input.
    public static let tel: InputType = "tel"

    /// A URL input.
    public static let url: InputType = "url"

    /// A date picker.
    public static let date: InputType = "date"

    /// A checkbox.
    public static let checkbox: InputType = "checkbox"

    /// A radio button.
    public static let radio: InputType = "radio"

    /// A hidden value, submitted with the form but not shown.
    public static let hidden: InputType = "hidden"

    /// A file picker.
    public static let file: InputType = "file"

    /// A submit button.
    public static let submit: InputType = "submit"

    /// A slider for a number in a range.
    public static let range: InputType = "range"

    /// A color picker.
    public static let color: InputType = "color"

    /// A time of day.
    public static let time: InputType = "time"

    /// A date and time with no time zone.
    public static let dateTimeLocal: InputType = "datetime-local"

    /// A month and year.
    public static let month: InputType = "month"

    /// A week of a year.
    public static let week: InputType = "week"

    /// A reset button.
    public static let reset: InputType = "reset"

    /// A plain button.
    public static let button: InputType = "button"

    // MARK: - Properties

    /// The value written to the `type` attribute.
    public let rawValue: String

    // MARK: - Initializers

    /// Creates an input type from its HTML name.
    /// - Parameter rawValue: The value written to the `type` attribute.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Creates an input type from a string literal, such as `"color"`.
    /// - Parameter value: The HTML name of the input type.
    public init(stringLiteral value: String) { self.rawValue = value }
}

/// A form input (`<input>`).
public struct Input: View {

    // MARK: - Properties

    /// The input type.
    public var type: InputType

    /// The field name the value is submitted under.
    public var name: String?

    /// The initial value.
    public var value: String?

    /// Hint text shown while the input is empty.
    public var placeholder: String?

    // MARK: - Initializer

    /// Creates an input.
    /// - Parameters:
    ///   - type: The input type.
    ///   - name: The field name the value is submitted under.
    ///   - value: The initial value.
    ///   - placeholder: Hint text shown while the input is empty.
    public init(type: InputType = .text, name: String? = nil, value: String? = nil, placeholder: String? = nil) {
        self.type = type
        self.name = name
        self.value = value
        self.placeholder = placeholder
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes: HTMLAttributes = ["type": type.rawValue]
        attributes["name"] = name
        attributes["value"] = value
        attributes["placeholder"] = placeholder
        return VoidElement("input", attributes: attributes)
    }
}

/// A single-line text field, in the style of SwiftUI's `TextField`.
///
/// ```swift
/// TextField("Your name", name: "name", id: "name", text: form.name, autocomplete: "name")
/// ```
public struct TextField: View {

    // MARK: - Properties

    /// Hint text shown while the field is empty.
    public let placeholder: String?

    /// The field name the value is submitted under.
    public let name: String

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    /// The current value, for example the value the user submitted last time.
    public let text: String?

    /// The input type, such as `.email` or `.search`.
    public let type: InputType

    /// The `autocomplete` hint, such as `"email"` or `"off"`.
    public let autocomplete: String?

    /// The `id` of a `DataList` of suggested values.
    public let list: String?

    // MARK: - Initializer

    /// Creates a text field.
    /// - Parameters:
    ///   - placeholder: Hint text shown while the field is empty.
    ///   - name: The field name the value is submitted under.
    ///   - id: The element `id`, for use with `Label(for:)`.
    ///   - text: The current value.
    ///   - type: The input type. Defaults to `.text`.
    ///   - autocomplete: The `autocomplete` hint.
    ///   - list: The `id` of a `DataList` of suggested values.
    public init(
        _ placeholder: String? = nil,
        name: String,
        id: String? = nil,
        text: String? = nil,
        type: InputType = .text,
        autocomplete: String? = nil,
        list: String? = nil
    ) {
        self.list = list
        self.placeholder = placeholder
        self.name = name
        self.id = id
        self.text = text
        self.type = type
        self.autocomplete = autocomplete
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes: HTMLAttributes = ["type": type.rawValue, "name": name]
        attributes["id"] = id
        attributes["value"] = text
        attributes["placeholder"] = placeholder
        attributes["autocomplete"] = autocomplete
        attributes["list"] = list
        return VoidElement("input", attributes: attributes)
    }
}

/// A password field, in the style of SwiftUI's `SecureField`. It never
/// renders a value back into the page.
public struct SecureField: View {

    // MARK: - Properties

    /// Hint text shown while the field is empty.
    public let placeholder: String?

    /// The field name the value is submitted under.
    public let name: String

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    /// The `autocomplete` hint, such as `"current-password"`.
    public let autocomplete: String?

    // MARK: - Initializer

    /// Creates a password field.
    /// - Parameters:
    ///   - placeholder: Hint text shown while the field is empty.
    ///   - name: The field name the value is submitted under.
    ///   - id: The element `id`, for use with `Label(for:)`.
    ///   - autocomplete: The `autocomplete` hint, such as `"current-password"`.
    public init(_ placeholder: String? = nil, name: String, id: String? = nil, autocomplete: String? = nil) {
        self.placeholder = placeholder
        self.name = name
        self.id = id
        self.autocomplete = autocomplete
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes: HTMLAttributes = ["type": "password", "name": name]
        attributes["id"] = id
        attributes["placeholder"] = placeholder
        attributes["autocomplete"] = autocomplete
        return VoidElement("input", attributes: attributes)
    }
}

/// A multi-line text field (`<textarea>`). The text is escaped.
public struct TextArea: View {

    // MARK: - Properties

    /// The field name the value is submitted under.
    public let name: String

    /// The initial text. It is escaped.
    public let text: String

    /// The number of visible text lines.
    public let rows: Int?

    /// Hint text shown while the field is empty.
    public let placeholder: String?

    // MARK: - Initializer

    /// Creates a multi-line text field.
    /// - Parameters:
    ///   - name: The field name the value is submitted under.
    ///   - text: The initial text. It is escaped.
    ///   - rows: The number of visible text lines.
    ///   - placeholder: Hint text shown while the field is empty.
    public init(name: String, text: String = "", rows: Int? = nil, placeholder: String? = nil) {
        self.name = name
        self.text = text
        self.rows = rows
        self.placeholder = placeholder
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Text> {
        var attributes: HTMLAttributes = ["name": name]
        attributes["rows"] = rows.map(String.init)
        attributes["placeholder"] = placeholder
        return Element("textarea", attributes: attributes, wrapping: Text(text))
    }
}

/// A drop-down list (`<select>`). Fill it with `Option`s.
public struct Select<Content: View>: View {

    // MARK: - Properties

    /// The field name the selection is submitted under.
    public let name: String

    /// The element's content.
    public let content: Content

    // MARK: - Initializer

    /// Creates a drop-down list whose options are built by `content`.
    /// - Parameters:
    ///   - name: The field name the selection is submitted under.
    ///   - content: The element's content.
    public init(name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Content> {
        Element("select", attributes: ["name": name], wrapping: content)
    }
}

/// An entry in a `Select` (`<option>`).
public struct Option: View {

    // MARK: - Properties

    /// The visible text.
    public let title: String

    /// The value submitted when this option is selected.
    public let value: String

    /// Whether the option starts selected.
    public let isSelected: Bool

    // MARK: - Initializer

    /// Creates an option. When `value` is `nil`, the title is submitted.
    /// - Parameters:
    ///   - title: The visible text.
    ///   - value: The value submitted when this option is selected.
    ///   - selected: Whether the option starts selected.
    public init(_ title: String, value: String? = nil, selected: Bool = false) {
        self.title = title
        self.value = value ?? title
        self.isSelected = selected
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: Element<Text> {
        var attributes: HTMLAttributes = ["value": value]
        if isSelected { attributes.setFlag("selected") }
        return Element("option", attributes: attributes, wrapping: Text(title))
    }
}
