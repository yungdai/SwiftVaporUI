/// A view with attribute changes applied by modifiers.
///
/// The changes go to the first HTML element the content renders. When a
/// modifier wraps several sibling elements (for example a `Group`), only the
/// first one receives the attributes. When several modifiers set the same
/// attribute, the last one in the chain wins; `class` and `style` accumulate.
public struct ModifiedView<Content: View>: View {

    // MARK: - Properties

    /// The view the modifier's attribute changes apply to.
    public let content: Content

    /// The attribute changes, innermost first.
    let changes: [AttributeChange]

    // MARK: - View

    /// A primitive view writes its own HTML, so it has no `body`.
    public typealias Body = Never

    /// Writes this view's HTML into `renderer`.
    /// - Parameter renderer: The renderer that collects the page's HTML.
    public func _render(into renderer: inout HTMLRenderer) {
        let outer = renderer.pending
        // Inner modifiers apply first, so the outermost (last written) wins.
        renderer.pending = changes + outer
        content._render(into: &renderer)
        if !renderer.pending.isEmpty {
            // Nothing consumed our changes: drop them so they cannot leak to
            // a sibling, but keep any outer changes for the next element.
            renderer.pending = outer
        }
    }

}

/// Modifiers that set the attributes of the element a view renders.
extension View {

    /// Wraps the view with attribute changes.
    /// - Parameter changes: The attribute changes.
    /// - Returns: A view with the change applied.
    func changing(_ changes: AttributeChange...) -> ModifiedView<Self> {
        ModifiedView(content: self, changes: changes)
    }

    /// Adds one or more space-separated CSS class names.
    /// - Parameter names: Space-separated class names.
    /// - Returns: A view with the change applied.
    public func `class`(_ names: String...) -> ModifiedView<Self> {
        ModifiedView(content: self, changes: names.map { .addClass($0) })
    }

    /// Adds CSS class names only when `condition` is true.
    /// - Parameters:
    ///   - names: Space-separated class names.
    ///   - condition: Whether to apply the change.
    /// - Returns: A view with the change applied.
    public func `class`(_ names: String, when condition: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self, changes: condition ? [.addClass(names)] : [])
    }

    /// Sets the element's `id`.
    /// - Parameter id: The element `id`.
    /// - Returns: A view with the change applied.
    public func id(_ id: String) -> ModifiedView<Self> {
        changing(.set("id", id))
    }

    /// Sets the ARIA `role`.
    /// - Parameter role: The ARIA role, such as `"navigation"`.
    /// - Returns: A view with the change applied.
    public func role(_ role: String) -> ModifiedView<Self> {
        changing(.set("role", role))
    }

    /// Sets the `title` attribute (the browser tooltip).
    /// - Parameter title: The tooltip text.
    /// - Returns: A view with the change applied.
    public func tooltip(_ title: String) -> ModifiedView<Self> {
        changing(.set("title", title))
    }

    /// Sets the `title` attribute: advisory text that browsers show as a
    /// tooltip. The same as ``tooltip(_:)``.
    ///
    /// This is not the document title: on an `HTMLDocument` it would set a
    /// tooltip on `<html>`. Set the page title with `HTMLDocument(title:)`.
    /// - Parameter title: The tooltip text.
    /// - Returns: A view with the change applied.
    public func title(_ title: String) -> ModifiedView<Self> {
        tooltip(title)
    }

    /// Sets `tabindex`. Use `0` to make an element focusable in document
    /// order and `-1` to make it focusable only from script.
    /// - Parameter index: The tab index.
    /// - Returns: A view with the change applied.
    public func tabIndex(_ index: Int) -> ModifiedView<Self> {
        changing(.set("tabindex", String(index)))
    }

    /// Sets the language of the element's content, such as `"fr"` or
    /// `"pt-BR"`, so screen readers and spell checkers use the right rules.
    /// - Parameter language: A language tag such as `"fr"` or `"pt-BR"`.
    /// - Returns: A view with the change applied.
    public func lang(_ language: String) -> ModifiedView<Self> {
        changing(.set("lang", language))
    }

    /// Sets an attribute. Passing `nil` removes it.
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - value: The value to set.
    /// - Returns: A view with the change applied.
    public func attribute(_ name: String, _ value: String?) -> ModifiedView<Self> {
        changing(value.map { .set(name, $0) } ?? .remove(name))
    }

    /// Adds a boolean attribute with no value, such as `novalidate`, when
    /// `condition` is true, and removes it otherwise.
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - condition: Whether to apply the change.
    /// - Returns: A view with the change applied.
    public func flag(_ name: String, if condition: Bool = true) -> ModifiedView<Self> {
        changing(condition ? .set(name, nil) : .remove(name))
    }

    /// Sets a `data-*` attribute.
    /// - Parameters:
    ///   - key: The name after the prefix.
    ///   - value: The value to set.
    /// - Returns: A view with the change applied.
    public func data(_ key: String, _ value: String) -> ModifiedView<Self> {
        changing(.set("data-\(key)", value))
    }

    /// Sets an `aria-*` attribute.
    /// - Parameters:
    ///   - key: The name after the prefix.
    ///   - value: The value to set.
    /// - Returns: A view with the change applied.
    public func aria(_ key: String, _ value: String) -> ModifiedView<Self> {
        changing(.set("aria-\(key)", value))
    }

    /// Appends inline CSS declarations, for example `"color: red; margin: 0"`.
    /// - Parameter declarations: CSS declarations, such as `"color: red; margin: 0"`.
    /// - Returns: A view with the change applied.
    public func style(_ declarations: String) -> ModifiedView<Self> {
        changing(.addStyle(declarations))
    }

    /// Appends a single inline CSS declaration.
    /// - Parameters:
    ///   - property: The CSS property name.
    ///   - value: The value to set.
    /// - Returns: A view with the change applied.
    public func style(_ property: String, _ value: String) -> ModifiedView<Self> {
        changing(.addStyle("\(property): \(value)"))
    }

    /// Adds the `hidden` attribute when `isHidden` is true.
    /// - Parameter isHidden: Whether to add the attribute.
    /// - Returns: A view with the change applied.
    public func hidden(_ isHidden: Bool = true) -> ModifiedView<Self> {
        flag("hidden", if: isHidden)
    }

    /// Adds the `disabled` attribute when `isDisabled` is true.
    /// - Parameter isDisabled: Whether to add the attribute.
    /// - Returns: A view with the change applied.
    public func disabled(_ isDisabled: Bool = true) -> ModifiedView<Self> {
        flag("disabled", if: isDisabled)
    }

    /// Adds the `required` attribute when `isRequired` is true.
    /// - Parameter isRequired: Whether to add the attribute.
    /// - Returns: A view with the change applied.
    public func required(_ isRequired: Bool = true) -> ModifiedView<Self> {
        flag("required", if: isRequired)
    }

    /// Sets `autofocus`.
    /// - Parameter isOn: Whether to add the attribute.
    /// - Returns: A view with the change applied.
    public func autofocus(_ isOn: Bool = true) -> ModifiedView<Self> {
        flag("autofocus", if: isOn)
    }

}
