/// An ordered set of HTML attributes.
///
/// A `nil` value renders a boolean attribute with no value, such as
/// `disabled`. Attribute names that are not safe to emit are ignored.
public struct HTMLAttributes: Sendable, Equatable, ExpressibleByDictionaryLiteral {
    /// One attribute: a name and an optional value.
    public struct Attribute: Sendable, Equatable {
        /// The attribute name.
        public var name: String
        /// The value, or `nil` for a boolean attribute.
        public var value: String?
    }

    /// The attributes, in the order they were first set.
    public private(set) var storage: [Attribute] = []

    /// Creates an empty set of attributes.
    public init() {}

    /// Creates attributes from a dictionary literal, keeping the literal's order.
    public init(dictionaryLiteral elements: (String, String)...) {
        for (name, value) in elements {
            self[name] = value
        }
    }

    /// Whether there are no attributes.
    public var isEmpty: Bool { storage.isEmpty }

    /// Gets or sets an attribute's value. Setting `nil` removes it.
    public subscript(name: String) -> String? {
        get { storage.first(where: { $0.name == name })?.value ?? nil }
        set {
            if let newValue {
                set(name, newValue)
            } else {
                remove(name)
            }
        }
    }

    /// Whether an attribute called `name` is set.
    public func contains(_ name: String) -> Bool {
        storage.contains(where: { $0.name == name })
    }

    /// Sets `name` to `value`, or to a bare boolean attribute when `value` is `nil`.
    public mutating func set(_ name: String, _ value: String?) {
        guard HTMLEscaping.isValidAttributeName(name) else { return }
        if let index = storage.firstIndex(where: { $0.name == name }) {
            storage[index].value = value
        } else {
            storage.append(Attribute(name: name, value: value))
        }
    }

    /// Adds a bare boolean attribute such as `required`.
    public mutating func setFlag(_ name: String) {
        set(name, nil)
    }

    /// Removes the attribute called `name`, if it is set.
    public mutating func remove(_ name: String) {
        storage.removeAll(where: { $0.name == name })
    }

    /// Adds whitespace-separated class names, skipping ones already present.
    public mutating func addClass(_ names: String) {
        var classes = (self["class"] ?? "").split(separator: " ").map(String.init)
        for name in names.split(whereSeparator: \.isWhitespace).map(String.init) where !classes.contains(name) {
            classes.append(name)
        }
        if !classes.isEmpty {
            set("class", classes.joined(separator: " "))
        }
    }

    /// Appends CSS declarations to the `style` attribute.
    public mutating func addStyle(_ declarations: String) {
        let trimmed = declarations.trimmingSeparators()
        guard !trimmed.isEmpty else { return }
        if let existing = self["style"]?.trimmingSeparators(), !existing.isEmpty {
            set("style", existing + "; " + trimmed)
        } else {
            set("style", trimmed)
        }
    }

    mutating func apply(_ change: AttributeChange) {
        switch change {
        case let .set(name, value): set(name, value)
        case let .remove(name): remove(name)
        case let .addClass(names): addClass(names)
        case let .addStyle(css): addStyle(css)
        }
    }
}

/// A change a modifier makes to the attributes of the element it wraps.
enum AttributeChange: Sendable, Equatable {
    case set(String, String?)
    case remove(String)
    case addClass(String)
    case addStyle(String)
}

private extension String {
    func trimmingSeparators() -> String {
        let set: Set<Character> = [" ", ";"]
        var slice = Substring(self)
        while let first = slice.first, set.contains(first) { slice.removeFirst() }
        while let last = slice.last, set.contains(last) { slice.removeLast() }
        return String(slice)
    }
}
