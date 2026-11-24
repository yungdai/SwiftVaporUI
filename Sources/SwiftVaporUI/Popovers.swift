// Native HTML interactivity with no script: the Popover API and invoker
// commands. Buttons open, close and toggle popovers and dialogs through
// attributes, and the browser does the rest.

/// How a popover behaves, written as the `popover` attribute.
public enum PopoverMode: String, Sendable, Hashable {

    /// Closes when the visitor clicks outside it or presses Escape, and
    /// closes other `auto` popovers when it opens. Right for menus and pickers.
    case auto

    /// Stays open until a button or script closes it, and leaves other
    /// popovers alone. Right for toasts and persistent panels.
    case manual

    /// A tooltip-like popover: it closes other hints but not `auto`
    /// popovers. Browsers without `hint` treat it as `manual`.
    case hint

}

/// What a popover button does to its popover, written as `popovertargetaction`.
public enum PopoverAction: String, Sendable, Hashable {

    /// Opens the popover when it is closed and closes it when it is open.
    case toggle

    /// Opens the popover.
    case show

    /// Closes the popover.
    case hide

}

/// A command a button sends to another element, written as the `command`
/// attribute of an invoker button.
///
/// ```swift
/// Button("Show today's special", action: .command(.showModal, target: "special"))
/// Dialog { ... }.id("special")
/// ```
public struct InvokerCommand: Sendable, Hashable {

    // MARK: - Static Properties

    /// Opens a `Dialog` as a modal.
    public static let showModal = InvokerCommand(rawValue: "show-modal")

    /// Closes a `Dialog`.
    public static let close = InvokerCommand(rawValue: "close")

    /// Asks a `Dialog` to close, firing its `cancel` event first so a script can stop it.
    public static let requestClose = InvokerCommand(rawValue: "request-close")

    /// Opens a closed popover and closes an open one.
    public static let togglePopover = InvokerCommand(rawValue: "toggle-popover")

    /// Opens a popover.
    public static let showPopover = InvokerCommand(rawValue: "show-popover")

    /// Closes a popover.
    public static let hidePopover = InvokerCommand(rawValue: "hide-popover")

    // MARK: - Properties

    /// The `command` value, such as `"show-modal"`.
    public let rawValue: String

    // MARK: - Static Methods

    /// A custom command, which the target receives as a `command` event for
    /// your own script to handle. Custom commands start with two dashes, which
    /// are added when `name` does not have them.
    /// - Parameter name: The command name, such as `"rotate"` or `"--rotate"`.
    /// - Returns: The command, starting with `--`.
    public static func custom(_ name: String) -> InvokerCommand {
        InvokerCommand(rawValue: name.hasPrefix("--") ? name : "--" + name)
    }

}

/// Making any element a popover.
extension View {

    /// Makes the element a popover: hidden until a button with
    /// `ButtonAction.popover(_:target:)` or an invoker command opens it, then
    /// shown on top of the page. Give it an `id` for the button to target.
    ///
    /// ```swift
    /// Button("What's a bao?", action: .popover(target: "bao"))
    /// Paragraph("A soft steamed bun with a filling.")
    ///     .id("bao")
    ///     .popover()
    /// ```
    /// - Parameter mode: How the popover closes and interacts with other popovers.
    /// - Returns: A view with the `popover` attribute set.
    public func popover(_ mode: PopoverMode = .auto) -> ModifiedView<Self> {
        changing(.set("popover", mode.rawValue))
    }

}
