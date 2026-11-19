/// A view with attribute changes applied by modifiers.
///
/// The changes go to the first HTML element the content renders. When a
/// modifier wraps several sibling elements (for example a `Group`), only the
/// first one receives the attributes. When several modifiers set the same
/// attribute, the last one in the chain wins; `class` and `style` accumulate.
public struct ModifiedView<Content: View>: View {
    public typealias Body = Never
    /// The view the modifier's attribute changes apply to.
    public let content: Content
    let changes: [AttributeChange]

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

extension View {
    func modifier(_ changes: AttributeChange...) -> ModifiedView<Self> {
        ModifiedView(content: self, changes: changes)
    }

    /// Adds one or more space-separated CSS class names.
    public func `class`(_ names: String...) -> ModifiedView<Self> {
        ModifiedView(content: self, changes: names.map { .addClass($0) })
    }

    /// Adds CSS class names only when `condition` is true.
    public func `class`(_ names: String, when condition: Bool) -> ModifiedView<Self> {
        ModifiedView(content: self, changes: condition ? [.addClass(names)] : [])
    }

    /// Sets the element's `id`.
    public func id(_ id: String) -> ModifiedView<Self> {
        modifier(.set("id", id))
    }

    /// Sets the ARIA `role`.
    public func role(_ role: String) -> ModifiedView<Self> {
        modifier(.set("role", role))
    }

    /// Sets the `title` attribute (the browser tooltip).
    public func tooltip(_ title: String) -> ModifiedView<Self> {
        modifier(.set("title", title))
    }

    /// Sets an attribute. Passing `nil` removes it.
    public func attribute(_ name: String, _ value: String?) -> ModifiedView<Self> {
        modifier(value.map { .set(name, $0) } ?? .remove(name))
    }

    /// Adds a boolean attribute with no value, such as `novalidate`, when
    /// `condition` is true, and removes it otherwise.
    public func flag(_ name: String, if condition: Bool = true) -> ModifiedView<Self> {
        modifier(condition ? .set(name, nil) : .remove(name))
    }

    /// Sets a `data-*` attribute.
    public func data(_ key: String, _ value: String) -> ModifiedView<Self> {
        modifier(.set("data-\(key)", value))
    }

    /// Sets an `aria-*` attribute.
    public func aria(_ key: String, _ value: String) -> ModifiedView<Self> {
        modifier(.set("aria-\(key)", value))
    }

    /// Appends inline CSS declarations, for example `"color: red; margin: 0"`.
    public func style(_ declarations: String) -> ModifiedView<Self> {
        modifier(.addStyle(declarations))
    }

    /// Appends a single inline CSS declaration.
    public func style(_ property: String, _ value: String) -> ModifiedView<Self> {
        modifier(.addStyle("\(property): \(value)"))
    }

    /// Adds the `hidden` attribute when `isHidden` is true.
    public func hidden(_ isHidden: Bool = true) -> ModifiedView<Self> {
        flag("hidden", if: isHidden)
    }

    /// Adds the `disabled` attribute when `isDisabled` is true.
    public func disabled(_ isDisabled: Bool = true) -> ModifiedView<Self> {
        flag("disabled", if: isDisabled)
    }

    /// Adds the `required` attribute when `isRequired` is true.
    public func required(_ isRequired: Bool = true) -> ModifiedView<Self> {
        flag("required", if: isRequired)
    }

    /// Sets `autofocus`.
    public func autofocus(_ isOn: Bool = true) -> ModifiedView<Self> {
        flag("autofocus", if: isOn)
    }
}
