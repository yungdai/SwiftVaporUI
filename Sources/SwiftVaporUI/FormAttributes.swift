// Modifiers for the form attributes that have no parameter of their own:
// text constraints and keyboard hints for fields, and per-button overrides
// of where and how a form submits.

/// The on-screen keyboard a field asks for, written as `inputmode`.
public enum InputMode: String, Sendable, Hashable {

    /// No on-screen keyboard, for fields with their own input UI.
    case none

    /// The standard keyboard for the visitor's language.
    case text

    /// Digits and a decimal separator.
    case decimal

    /// Digits only, for PINs, codes and card numbers.
    case numeric

    /// A telephone keypad.
    case tel

    /// A keyboard tuned for search, often with a Search key.
    case search

    /// A keyboard with `@` and `.` easy to reach.
    case email

    /// A keyboard with `/` and `.` easy to reach.
    case url

}

/// The label of the Enter key on an on-screen keyboard, written as `enterkeyhint`.
public enum EnterKeyHint: String, Sendable, Hashable {

    /// Inserts a new line.
    case enter

    /// Closes the keyboard: the input is finished.
    case done

    /// Takes the visitor where the text points, such as a URL.
    case go

    /// Moves to the next field.
    case next

    /// Moves to the previous field.
    case previous

    /// Runs a search.
    case search

    /// Sends the text, as in a chat.
    case send

}

/// Field constraints and keyboard hints.
extension View {

    /// Requires the value to match a regular expression before the form
    /// submits. The whole value must match, so `^` and `$` are implied.
    /// Pair it with `.tooltip(_:)` to tell the visitor what is expected.
    /// - Parameter regex: A JavaScript regular expression, without slashes, such as `"[A-Z]{2}[0-9]{4}"`.
    /// - Returns: A view with `pattern` set.
    public func pattern(_ regex: String) -> ModifiedView<Self> {
        changing(.set("pattern", regex))
    }

    /// Requires at least `length` characters before the form submits. Keep it
    /// no larger than any `maxLength(_:)`, or no value can pass.
    /// - Parameter length: The shortest allowed value, in characters.
    /// - Returns: A view with `minlength` set.
    public func minLength(_ length: Int) -> ModifiedView<Self> {
        changing(.set("minlength", String(max(0, length))))
    }

    /// Stops the visitor typing more than `length` characters.
    /// - Parameter length: The longest allowed value, in characters.
    /// - Returns: A view with `maxlength` set.
    public func maxLength(_ length: Int) -> ModifiedView<Self> {
        changing(.set("maxlength", String(max(0, length))))
    }

    /// Chooses the on-screen keyboard, without changing how the value is
    /// checked. Use it with a text field for numbers that are not quantities,
    /// such as PINs.
    /// - Parameter mode: The keyboard to show.
    /// - Returns: A view with `inputmode` set.
    public func inputMode(_ mode: InputMode) -> ModifiedView<Self> {
        changing(.set("inputmode", mode.rawValue))
    }

    /// Chooses the label of the Enter key on an on-screen keyboard.
    /// - Parameter hint: What pressing Enter will do.
    /// - Returns: A view with `enterkeyhint` set.
    public func enterKeyHint(_ hint: EnterKeyHint) -> ModifiedView<Self> {
        changing(.set("enterkeyhint", hint.rawValue))
    }

}

/// Per-button overrides of the form's submission, so one form can have, say,
/// a Save and a Delete button that post to different routes. They only work
/// on submit buttons: a `Button` with the default `.submit` action. Browsers
/// ignore them on other buttons, and on the link `.navigate(to:)` renders.
extension View {

    /// Submits the form to `url` instead of the form's `action`, when this button is pressed.
    /// - Parameter url: The URL to submit to.
    /// - Returns: A view with `formaction` set.
    public func formAction(_ url: String) -> ModifiedView<Self> {
        changing(.set("formaction", url))
    }

    /// Submits the form with `method` instead of the form's method, when this button is pressed.
    /// - Parameter method: The HTTP method, or `.dialog` to close the enclosing dialog.
    /// - Returns: A view with `formmethod` set.
    public func formMethod(_ method: FormMethod) -> ModifiedView<Self> {
        changing(.set("formmethod", method.rawValue))
    }

    /// Encodes the form with `encoding` instead of the form's encoding, when this button is pressed.
    /// - Parameter encoding: How to encode the fields.
    /// - Returns: A view with `formenctype` set.
    public func formEncoding(_ encoding: FormEncoding) -> ModifiedView<Self> {
        changing(.set("formenctype", encoding.rawValue))
    }

    /// Skips the browser's validation when this button submits the form,
    /// for buttons such as Save draft.
    /// - Parameter isOn: Whether to skip validation.
    /// - Returns: A view with `formnovalidate` added or removed.
    public func formNoValidate(_ isOn: Bool = true) -> ModifiedView<Self> {
        flag("formnovalidate", if: isOn)
    }

}
