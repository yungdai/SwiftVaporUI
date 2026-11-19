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

/// The `type` of a `Button`.
public enum ButtonType: String, Sendable {
    case submit, button, reset
}

/// A button (`<button>`).
public struct Button<Content: View>: View {
    public let type: ButtonType
    public let content: Content

    public init(type: ButtonType = .button, @ViewBuilder content: () -> Content) {
        self.type = type
        self.content = content()
    }

    public var body: Element<Content> {
        Element("button", attributes: ["type": type.rawValue], wrapping: content)
    }
}

extension Button where Content == Text {
    public init(_ title: String, type: ButtonType = .button) {
        self.init(type: type) { Text(title) }
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
/// TextField("Your name", name: "name", text: form.name)
/// ```
public struct TextField: View {
    public let placeholder: String
    public let name: String
    public let text: String?
    public let type: InputType

    public init(_ placeholder: String, name: String, text: String? = nil, type: InputType = .text) {
        self.placeholder = placeholder
        self.name = name
        self.text = text
        self.type = type
    }

    public var body: Input {
        Input(type: type, name: name, value: text, placeholder: placeholder)
    }
}

/// A password field, in the style of SwiftUI's `SecureField`. It never
/// renders a value back into the page.
public struct SecureField: View {
    public let placeholder: String
    public let name: String

    public init(_ placeholder: String, name: String) {
        self.placeholder = placeholder
        self.name = name
    }

    public var body: Input {
        Input(type: .password, name: name, placeholder: placeholder)
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
