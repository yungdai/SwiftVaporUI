import SwiftVaporUI

/// A feature area of SwiftVaporUI, shown as one page of the showcase.
struct Topic: Sendable {

    // MARK: - Properties

    /// The URL path segment, such as `text` for `/text`.
    let slug: String

    /// The page heading and sidebar label.
    let title: String

    /// One line for the home page card and the sidebar tooltip.
    let tagline: String

    /// Paragraphs introducing the topic.
    let intro: [String]

    /// The examples, in page order.
    let examples: [Example]

    // MARK: - Computed Properties

    /// The page's URL path, such as `/text`.
    var path: String { "/\(slug)" }

}

/// Every showcase page, in sidebar order.
enum Topics {

    // MARK: - Static Properties

    /// Every topic, in sidebar order.
    static let all: [Topic] = [
        TextTopic.topic,
        LayoutTopic.topic,
        ContainersTopic.topic,
        StylingTopic.topic,
        CompositionTopic.topic,
        ListsTopic.topic,
        ConditionalsTopic.topic,
        TablesTopic.topic,
        FormsTopic.topic,
        ControlsTopic.topic,
        NavigationTopic.topic,
        ComponentsTopic.topic,
        HTMXTopic.topic,
        ElementsTopic.topic,
        MediaTopic.topic,
        DocumentsTopic.topic,
        PageSetupTopic.topic,
    ]

    // MARK: - Methods

    /// Finds a topic by its slug.
    /// - Parameter slug: The URL path segment.
    /// - Returns: The topic, or `nil` if there is none.
    static func topic(slug: String) -> Topic? {
        all.first { $0.slug == slug }
    }

}
