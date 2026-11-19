/// The HTTP method a `Form` submits with.
public enum FormMethod: String, Sendable {
    case get, post
}

/// A form (`<form>`).
public struct Form<Content: View>: View {
    public let action: String?
    public let method: FormMethod
    public let content: Content

    public init(action: String? = nil, method: FormMethod = .post, @ViewBuilder content: () -> Content) {
        self.action = action
        self.method = method
        self.content = content()
    }

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
    public let action: ButtonAction
    public let label: Label

    public init(action: ButtonAction = .submit, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

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

extension Button where Label == Text {
    public init(_ title: String, action: ButtonAction = .submit) {
        self.init(action: action) { Text(title) }
    }
}

/// A caption for a form control (`<label>`).
public struct Label<Content: View>: View {
    public let forID: String?
    public let content: Content

    public init(for id: String? = nil, @ViewBuilder content: () -> Content) {
        self.forID = id
        self.content = content()
    }

    public var body: Element<Content> {
        var attributes = HTMLAttributes()
        attributes["for"] = forID
        return Element("label", attributes: attributes, wrapping: content)
    }
}

extension Label where Content == Text {
    public init(_ title: String, for id: String? = nil) {
        self.init(for: id) { Text(title) }
    }
}

/// The `type` of an `Input`.
public struct InputType: RawRepresentable, Sendable, Hashable, ExpressibleByStringLiteral {
    public let rawValue: String
    public init(rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { self.rawValue = value }

    public static let text: InputType = "text"
    public static let email: InputType = "email"
    public static let password: InputType = "password"
    public static let number: InputType = "number"
    public static let search: InputType = "search"
    public static let tel: InputType = "tel"
    public static let url: InputType = "url"
    public static let date: InputType = "date"
    public static let checkbox: InputType = "checkbox"
    public static let radio: InputType = "radio"
    public static let hidden: InputType = "hidden"
    public static let file: InputType = "file"
    public static let submit: InputType = "submit"
}

/// A form input (`<input>`).
public struct Input: View {
    public var type: InputType
    public var name: String?
    public var value: String?
    public var placeholder: String?

    public init(type: InputType = .text, name: String? = nil, value: String? = nil, placeholder: String? = nil) {
        self.type = type
        self.name = name
        self.value = value
        self.placeholder = placeholder
    }

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
    public let placeholder: String?
    public let name: String
    public let id: String?
    public let text: String?
    public let type: InputType
    public let autocomplete: String?

    public init(
        _ placeholder: String? = nil,
        name: String,
        id: String? = nil,
        text: String? = nil,
        type: InputType = .text,
        autocomplete: String? = nil
    ) {
        self.placeholder = placeholder
        self.name = name
        self.id = id
        self.text = text
        self.type = type
        self.autocomplete = autocomplete
    }

    public var body: VoidElement {
        var attributes: HTMLAttributes = ["type": type.rawValue, "name": name]
        attributes["id"] = id
        attributes["value"] = text
        attributes["placeholder"] = placeholder
        attributes["autocomplete"] = autocomplete
        return VoidElement("input", attributes: attributes)
    }
}

/// A password field, in the style of SwiftUI's `SecureField`. It never
/// renders a value back into the page.
public struct SecureField: View {
    public let placeholder: String?
    public let name: String
    public let id: String?
    public let autocomplete: String?

    public init(_ placeholder: String? = nil, name: String, id: String? = nil, autocomplete: String? = nil) {
        self.placeholder = placeholder
        self.name = name
        self.id = id
        self.autocomplete = autocomplete
    }

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
    public let name: String
    public let text: String
    public let rows: Int?
    public let placeholder: String?

    public init(name: String, text: String = "", rows: Int? = nil, placeholder: String? = nil) {
        self.name = name
        self.text = text
        self.rows = rows
        self.placeholder = placeholder
    }

    public var body: Element<Text> {
        var attributes: HTMLAttributes = ["name": name]
        attributes["rows"] = rows.map(String.init)
        attributes["placeholder"] = placeholder
        return Element("textarea", attributes: attributes, wrapping: Text(text))
    }
}

/// A drop-down list (`<select>`). Fill it with `Option`s.
public struct Select<Content: View>: View {
    public let name: String
    public let content: Content

    public init(name: String, @ViewBuilder content: () -> Content) {
        self.name = name
        self.content = content()
    }

    public var body: Element<Content> {
        Element("select", attributes: ["name": name], wrapping: content)
    }
}

/// An entry in a `Select` (`<option>`).
public struct Option: View {
    public let title: String
    public let value: String
    public let isSelected: Bool

    public init(_ title: String, value: String? = nil, selected: Bool = false) {
        self.title = title
        self.value = value ?? title
        self.isSelected = selected
    }

    public var body: Element<Text> {
        var attributes: HTMLAttributes = ["value": value]
        if isSelected { attributes.setFlag("selected") }
        return Element("option", attributes: attributes, wrapping: Text(title))
    }
}
