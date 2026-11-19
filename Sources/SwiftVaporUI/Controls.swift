import Foundation

// Typed inputs (one per HTML input type), then SwiftUI-style controls built
// on them. Every control renders a real form field, so it submits with its
// `Form` and works without JavaScript.

/// The attributes every typed input starts with.
/// - Parameters:
///   - type: The input type.
///   - name: The field name.
///   - id: The element `id`.
/// - Returns: The `type`, `name` and `id` attributes.
private func inputAttributes(_ type: InputType, name: String?, id: String?) -> HTMLAttributes {
    var attributes: HTMLAttributes = ["type": type.rawValue]
    attributes["name"] = name
    attributes["id"] = id
    return attributes
}

// MARK: - Typed inputs

/// A checkbox (`<input type="checkbox">`). When checked, the form submits
/// `name=value`; when unchecked, it submits nothing.
public struct Checkbox: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// The value submitted when checked.
    public let value: String

    /// Whether it starts checked.
    public let isChecked: Bool

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates a checkbox.
    /// - Parameters:
    ///   - name: The field name.
    ///   - value: The value submitted when checked.
    ///   - isChecked: Whether it starts checked.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(name: String, value: String = "on", isChecked: Bool = false, id: String? = nil) {
        self.name = name
        self.value = value
        self.isChecked = isChecked
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(.checkbox, name: name, id: id)
        attributes["value"] = value
        if isChecked { attributes.setFlag("checked") }
        return VoidElement("input", attributes: attributes)
    }
}

/// A radio button (`<input type="radio">`). Buttons with the same `name`
/// form a group where only one can be chosen.
public struct RadioButton: View {

    // MARK: - Properties

    /// The group's field name.
    public let name: String

    /// The value submitted when this button is chosen.
    public let value: String

    /// Whether it starts chosen.
    public let isChecked: Bool

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates a radio button.
    /// - Parameters:
    ///   - name: The group's field name.
    ///   - value: The value submitted when this button is chosen.
    ///   - isChecked: Whether it starts chosen.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(name: String, value: String, isChecked: Bool = false, id: String? = nil) {
        self.name = name
        self.value = value
        self.isChecked = isChecked
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(.radio, name: name, id: id)
        attributes["value"] = value
        if isChecked { attributes.setFlag("checked") }
        return VoidElement("input", attributes: attributes)
    }
}

/// A number field (`<input type="number">`).
public struct NumberField: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// The initial value.
    public let value: Double?

    /// The smallest allowed value.
    public let min: Double?

    /// The largest allowed value.
    public let max: Double?

    /// The step between allowed values. `nil` means whole numbers.
    public let step: Double?

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates a number field.
    /// - Parameters:
    ///   - name: The field name.
    ///   - value: The initial value.
    ///   - min: The smallest allowed value.
    ///   - max: The largest allowed value.
    ///   - step: The step between allowed values. `nil` means whole numbers.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(name: String, value: Double? = nil, min: Double? = nil, max: Double? = nil, step: Double? = nil, id: String? = nil) {
        self.name = name
        self.value = value
        self.min = min
        self.max = max
        self.step = step
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(.number, name: name, id: id)
        attributes["value"] = value.map(cssNumber)
        attributes["min"] = min.map(cssNumber)
        attributes["max"] = max.map(cssNumber)
        attributes["step"] = step.map(cssNumber)
        return VoidElement("input", attributes: attributes)
    }
}

/// A slider (`<input type="range">`).
public struct RangeField: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// The initial value.
    public let value: Double

    /// The allowed values.
    public let range: ClosedRange<Double>

    /// The step between allowed values, or `nil` for whole numbers.
    public let step: Double?

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates a slider.
    /// - Parameters:
    ///   - name: The field name.
    ///   - value: The initial value.
    ///   - range: The allowed values.
    ///   - step: The step between allowed values, or `nil` for whole numbers.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(name: String, value: Double, in range: ClosedRange<Double> = 0...100, step: Double? = nil, id: String? = nil) {
        self.name = name
        self.value = value
        self.range = range
        self.step = step
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(.range, name: name, id: id)
        attributes["min"] = cssNumber(range.lowerBound)
        attributes["max"] = cssNumber(range.upperBound)
        attributes["step"] = step.map(cssNumber)
        attributes["value"] = cssNumber(value)
        return VoidElement("input", attributes: attributes)
    }
}

/// A date field (`<input type="date">`). Values are `yyyy-MM-dd` strings.
public struct DateField: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// The initial value, such as `"2026-11-21"`.
    public let value: String?

    /// The earliest allowed date.
    public let min: String?

    /// The latest allowed date.
    public let max: String?

    /// The input type: `.date`, `.time`, `.dateTimeLocal`, `.month` or `.week`.
    public let type: InputType

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates a date field. Pass `type` for a time, month or week instead.
    /// - Parameters:
    ///   - name: The field name.
    ///   - value: The initial value, such as `"2026-11-21"`.
    ///   - min: The earliest allowed date.
    ///   - max: The latest allowed date.
    ///   - type: The input type: `.date`, `.time`, `.dateTimeLocal`, `.month` or `.week`.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(name: String, value: String? = nil, min: String? = nil, max: String? = nil, type: InputType = .date, id: String? = nil) {
        self.name = name
        self.value = value
        self.min = min
        self.max = max
        self.type = type
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(type, name: name, id: id)
        attributes["value"] = value
        attributes["min"] = min
        attributes["max"] = max
        return VoidElement("input", attributes: attributes)
    }
}

/// An email address field (`<input type="email">`). The browser checks the
/// format before submitting.
public struct EmailField: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// The initial value.
    public let value: String?

    /// Hint text shown while the field is empty.
    public let placeholder: String?

    /// Whether several comma-separated addresses are allowed.
    public let allowsMultiple: Bool

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates an email field. Its `autocomplete` hint is `email`.
    /// - Parameters:
    ///   - placeholder: Hint text shown while the field is empty.
    ///   - name: The field name.
    ///   - value: The initial value.
    ///   - allowsMultiple: Whether several comma-separated addresses are allowed.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(_ placeholder: String? = nil, name: String, value: String? = nil, multiple allowsMultiple: Bool = false, id: String? = nil) {
        self.name = name
        self.value = value
        self.placeholder = placeholder
        self.allowsMultiple = allowsMultiple
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(.email, name: name, id: id)
        attributes["value"] = value
        attributes["placeholder"] = placeholder
        attributes["autocomplete"] = "email"
        if allowsMultiple { attributes.setFlag("multiple") }
        return VoidElement("input", attributes: attributes)
    }
}

/// A file picker (`<input type="file">`).
///
/// The enclosing form must post as `multipart/form-data`; add
/// `.attribute("enctype", "multipart/form-data")` to the `Form`.
public struct FileField: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// Allowed file types, such as `["image/*", ".pdf"]`. Empty allows any.
    public let accept: [String]

    /// Whether several files can be chosen.
    public let allowsMultiple: Bool

    /// The element `id`, for use with `Label(for:)`.
    public let id: String?

    // MARK: - Initializer

    /// Creates a file picker.
    /// - Parameters:
    ///   - name: The field name.
    ///   - accept: Allowed file types, such as `["image/*", ".pdf"]`. Empty allows any.
    ///   - allowsMultiple: Whether several files can be chosen.
    ///   - id: The element `id`, for use with `Label(for:)`.
    public init(name: String, accept: [String] = [], multiple allowsMultiple: Bool = false, id: String? = nil) {
        self.name = name
        self.accept = accept
        self.allowsMultiple = allowsMultiple
        self.id = id
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: VoidElement {
        var attributes = inputAttributes(.file, name: name, id: id)
        if !accept.isEmpty { attributes["accept"] = accept.joined(separator: ",") }
        if allowsMultiple { attributes.setFlag("multiple") }
        return VoidElement("input", attributes: attributes)
    }
}

// MARK: - SwiftUI-style controls

/// A `<label>` around a title and a control.
///
/// Modifiers on the control go to the control itself, not to the label, so
/// `.disabled()` and `.class(_:)` act on the field as they would in SwiftUI.
struct LabeledControl<Title: View, Control: View>: View {

    // MARK: - Properties

    /// The visible label.
    let title: Title

    /// The form control, which receives the modifiers.
    let control: Control

    /// Whether the title comes before the control (text fields) or after it (checkboxes).
    let titleFirst: Bool

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    func _render(into renderer: inout HTMLRenderer) {
        let pending = renderer.pending
        renderer.pending = []
        renderer.writeOpeningTag("label", attributes: ["class": "svui-control"])
        let title = Element("span", attributes: ["class": "svui-control-title"], wrapping: title)
        if titleFirst {
            title._render(into: &renderer)
            renderer.pending = pending
            control._render(into: &renderer)
        } else {
            renderer.pending = pending
            control._render(into: &renderer)
            renderer.pending = []
            title._render(into: &renderer)
        }
        renderer.pending = []
        renderer.write("</label>")
    }
}

/// A labelled checkbox, in the style of SwiftUI's `Toggle`.
///
/// ```swift
/// Toggle("Email me when it's ready", name: "notify", isOn: true)
/// ```
///
/// Renders `<label><input type="checkbox"> title</label>`. Modifiers apply
/// to the checkbox.
public struct Toggle<Title: View>: View {

    // MARK: - Properties

    /// The field name.
    public let name: String

    /// Whether it starts on.
    public let isOn: Bool

    /// The value submitted when on.
    public let value: String

    /// The visible label.
    public let title: Title

    // MARK: - Initializer

    /// Creates a toggle whose label is built by `label`.
    /// - Parameters:
    ///   - name: The field name.
    ///   - isOn: Whether it starts on.
    ///   - value: The value submitted when on.
    ///   - label: A view builder that creates the label.
    public init(name: String, isOn: Bool = false, value: String = "on", @ViewBuilder label: () -> Title) {
        self.name = name
        self.isOn = isOn
        self.value = value
        self.title = label()
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        LabeledControl(title: title, control: Checkbox(name: name, value: value, isChecked: isOn), titleFirst: false)
    }
}

/// Initializers that take plain text.
extension Toggle where Title == Text {

    /// Creates a toggle with escaped `title` as its label.
    /// - Parameters:
    ///   - title: The visible label.
    ///   - name: The field name.
    ///   - isOn: Whether it starts on.
    ///   - value: The value submitted when on.
    public init(_ title: String, name: String, isOn: Bool = false, value: String = "on") {
        self.init(name: name, isOn: isOn, value: value) { Text(title) }
    }
}

/// One choice in a `Picker`.
public struct PickerOption: Sendable, Hashable, ExpressibleByStringLiteral {

    // MARK: - Properties

    /// The visible text.
    public let title: String

    /// The submitted value.
    public let value: String

    // MARK: - Initializers

    /// Creates a choice. When `value` is `nil`, the title is submitted.
    /// - Parameters:
    ///   - title: The visible text.
    ///   - value: The submitted value.
    public init(_ title: String, value: String? = nil) {
        self.title = title
        self.value = value ?? title
    }

    /// Creates a choice whose title is also its value.
    /// - Parameter value: The submitted value.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

/// How a `Picker` presents its choices.
public enum PickerStyle: Sendable {

    /// A drop-down list (`<select>`).
    case menu

    /// A `<fieldset>` of radio buttons, all visible at once.
    case radioGroup
}

/// A labelled choice from a list, in the style of SwiftUI's `Picker`.
///
/// ```swift
/// Picker("Spice level", name: "spice", selection: "medium", options: [
///     PickerOption("Mild", value: "mild"),
///     PickerOption("Medium", value: "medium"),
///     PickerOption("Hot", value: "hot"),
/// ])
/// ```
///
/// In the `.menu` style, modifiers apply to the `<select>`; in the
/// `.radioGroup` style, to the `<fieldset>`.
public struct Picker: View {

    // MARK: - Properties

    /// The visible label.
    public let title: String

    /// The field name.
    public let name: String

    /// The value chosen at first, if any.
    public let selection: String?

    /// How the choices are presented.
    public let style: PickerStyle

    /// The choices, in order.
    public let options: [PickerOption]

    // MARK: - Initializer

    /// Creates a picker.
    /// - Parameters:
    ///   - title: The visible label.
    ///   - name: The field name.
    ///   - selection: The value chosen at first, if any.
    ///   - style: How the choices are presented.
    ///   - options: The choices, in order.
    public init(_ title: String, name: String, selection: String? = nil, style: PickerStyle = .menu, options: [PickerOption]) {
        self.title = title
        self.name = name
        self.selection = selection
        self.style = style
        self.options = options
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        switch style {
        case .menu:
            LabeledControl(
                title: Text(title),
                control: Select(name: name) {
                    ForEach(options) { option in
                        Option(option.title, value: option.value, selected: option.value == selection)
                    }
                },
                titleFirst: true
            )
        case .radioGroup:
            Fieldset {
                Legend(title)
                ForEach(options) { option in
                    LabeledControl(
                        title: Text(option.title),
                        control: RadioButton(name: name, value: option.value, isChecked: option.value == selection),
                        titleFirst: false
                    )
                }
            }
            .class("svui-radio-group")
        }
    }
}

/// A labelled slider, in the style of SwiftUI's `Slider`.
///
/// ```swift
/// Slider("Volume", name: "volume", value: 40, in: 0...100, showsValue: true)
/// ```
///
/// With `showsValue`, an `<output>` after the slider shows the current value
/// and a one-line inline script keeps it up to date as the slider moves.
public struct Slider: View {

    // MARK: - Properties

    /// The visible label.
    public let title: String

    /// The field name.
    public let name: String

    /// The initial value.
    public let value: Double

    /// The allowed values.
    public let range: ClosedRange<Double>

    /// The step between values, or `nil` for whole numbers.
    public let step: Double?

    /// Whether to show the current value next to the slider.
    public let showsValue: Bool

    // MARK: - Initializer

    /// Creates a slider.
    /// - Parameters:
    ///   - title: The visible label.
    ///   - name: The field name.
    ///   - value: The initial value.
    ///   - range: The allowed values.
    ///   - step: The step between values, or `nil` for whole numbers.
    ///   - showsValue: Whether to show the current value next to the slider.
    public init(
        _ title: String,
        name: String,
        value: Double,
        in range: ClosedRange<Double> = 0...100,
        step: Double? = nil,
        showsValue: Bool = false
    ) {
        self.title = title
        self.name = name
        self.value = value
        self.range = range
        self.step = step
        self.showsValue = showsValue
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        LabeledControl(
            title: Text(title),
            control: Group {
                if showsValue {
                    RangeField(name: name, value: value, in: range, step: step)
                        .attribute("oninput", "this.nextElementSibling.value=this.value")
                    Output(cssNumber(value))
                } else {
                    RangeField(name: name, value: value, in: range, step: step)
                }
            },
            titleFirst: true
        )
    }
}

/// A labelled whole-number field with up and down buttons, in the style of
/// SwiftUI's `Stepper`. Renders `<input type="number">`.
///
/// ```swift
/// Stepper("Guests", name: "guests", value: 2, in: 1...12)
/// ```
public struct Stepper: View {

    // MARK: - Properties

    /// The visible label.
    public let title: String

    /// The field name.
    public let name: String

    /// The initial value.
    public let value: Int

    /// The allowed values, if limited.
    public let range: ClosedRange<Int>?

    /// The step between values.
    public let step: Int

    // MARK: - Initializer

    /// Creates a stepper.
    /// - Parameters:
    ///   - title: The visible label.
    ///   - name: The field name.
    ///   - value: The initial value.
    ///   - range: The allowed values, if limited.
    ///   - step: The step between values.
    public init(_ title: String, name: String, value: Int, in range: ClosedRange<Int>? = nil, step: Int = 1) {
        self.title = title
        self.name = name
        self.value = value
        self.range = range
        self.step = step
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        LabeledControl(
            title: Text(title),
            control: NumberField(
                name: name,
                value: Double(value),
                min: range.map { Double($0.lowerBound) },
                max: range.map { Double($0.upperBound) },
                step: step == 1 ? nil : Double(step)
            ),
            titleFirst: true
        )
    }
}

/// The parts of a date a `DatePicker` asks for.
public struct DatePickerComponents: OptionSet, Sendable, Hashable {

    // MARK: - Static Properties

    /// The day, month and year.
    public static let date = DatePickerComponents(rawValue: 1)

    /// The hour and minute.
    public static let hourAndMinute = DatePickerComponents(rawValue: 2)

    // MARK: - Properties

    /// The bit mask of components.
    public let rawValue: Int

    // MARK: - Initializer

    /// Creates components from a bit mask.
    /// - Parameter rawValue: The bit mask of components.
    public init(rawValue: Int) { self.rawValue = rawValue }
}

/// A labelled date and/or time field, in the style of SwiftUI's `DatePicker`.
///
/// ```swift
/// DatePicker("Pick-up", name: "pickup", selection: Date(), displayedComponents: [.date, .hourAndMinute])
/// ```
///
/// Renders `<input type="date">`, `"time"` or `"datetime-local"`. Dates are
/// written in `timeZone`, UTC by default; HTML date fields have no time zone,
/// so read the submitted value back in the same zone.
public struct DatePicker: View {

    // MARK: - Properties

    /// The visible label.
    public let title: String

    /// The field name.
    public let name: String

    /// The initial date, if any.
    public let selection: Date?

    /// The earliest and latest allowed dates, if limited.
    public let range: ClosedRange<Date>?

    /// Which parts of the date to ask for.
    public let displayedComponents: DatePickerComponents

    /// The time zone used to write dates.
    public let timeZone: TimeZone

    // MARK: - Computed Properties

    /// The input type for the chosen components.
    var inputType: InputType {
        switch (displayedComponents.contains(.date), displayedComponents.contains(.hourAndMinute)) {
        case (true, true): .dateTimeLocal
        case (false, true): .time
        default: .date
        }
    }

    // MARK: - Initializer

    /// Creates a date picker.
    /// - Parameters:
    ///   - title: The visible label.
    ///   - name: The field name.
    ///   - selection: The initial date, if any.
    ///   - range: The earliest and latest allowed dates, if limited.
    ///   - displayedComponents: Which parts of the date to ask for.
    ///   - timeZone: The time zone used to write dates.
    public init(
        _ title: String,
        name: String,
        selection: Date? = nil,
        in range: ClosedRange<Date>? = nil,
        displayedComponents: DatePickerComponents = .date,
        timeZone: TimeZone = TimeZone(identifier: "UTC") ?? .current
    ) {
        self.title = title
        self.name = name
        self.selection = selection
        self.range = range
        self.displayedComponents = displayedComponents
        self.timeZone = timeZone
    }

    // MARK: - Methods

    /// Formats `date` the way the field's input type expects.
    /// - Parameter date: The date to format.
    /// - Returns: The date as the field expects it, such as `2026-11-21`.
    func format(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        /// Pads a number with leading zeros.
        func pad(_ value: Int?, _ width: Int = 2) -> String {
            let string = String(value ?? 0)
            return String(repeating: "0", count: max(0, width - string.count)) + string
        }
        let day = "\(pad(parts.year, 4))-\(pad(parts.month))-\(pad(parts.day))"
        let time = "\(pad(parts.hour)):\(pad(parts.minute))"
        switch inputType {
        case .dateTimeLocal: return "\(day)T\(time)"
        case .time: return time
        default: return day
        }
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        LabeledControl(
            title: Text(title),
            control: DateField(
                name: name,
                value: selection.map(format),
                min: range.map { format($0.lowerBound) },
                max: range.map { format($0.upperBound) },
                type: inputType
            ),
            titleFirst: true
        )
    }
}

/// Progress through a task, in the style of SwiftUI's `ProgressView`
/// (`<progress>`).
///
/// ```swift
/// ProgressView()                                   // indeterminate
/// ProgressView("Uploading", value: 0.4)            // 40%, labelled
/// ProgressView(value: 3, total: 8)
/// ```
///
/// Use `Meter` for a measurement that is not progress, such as disk usage.
public struct ProgressView: View {

    // MARK: - Properties

    /// The visible label, if any.
    public let title: String?

    /// The amount done, or `nil` when unknown.
    public let value: Double?

    /// The amount when finished.
    public let total: Double

    // MARK: - Computed Properties

    /// The `<progress>` element, with a percentage as fallback text.
    var bar: Element<Text> {
        var attributes = HTMLAttributes()
        if let value {
            attributes["value"] = cssNumber(value)
            attributes["max"] = cssNumber(total)
        }
        let percent = value.flatMap { total > 0 ? "\(Int(($0 / total * 100).rounded()))%" : nil } ?? ""
        return Element("progress", attributes: attributes, wrapping: Text(percent))
    }

    // MARK: - Initializers

    /// Creates an indeterminate progress bar, for work of unknown length.
    /// - Parameter title: The visible label, if any.
    public init(_ title: String? = nil) {
        self.title = title
        self.value = nil
        self.total = 1
    }

    /// Creates a progress bar showing `value` out of `total`.
    /// - Parameters:
    ///   - title: The visible label, if any.
    ///   - value: The amount done, or `nil` when unknown.
    ///   - total: The amount when finished.
    public init(_ title: String? = nil, value: Double?, total: Double = 1) {
        self.title = title
        self.value = value.map { min(max($0, 0), total) }
        self.total = total
    }

    // MARK: - View

    /// The elements this view is made of.
    public var body: some View {
        if let title {
            LabeledControl(title: Text(title), control: bar, titleFirst: true)
        } else {
            bar
        }
    }
}
