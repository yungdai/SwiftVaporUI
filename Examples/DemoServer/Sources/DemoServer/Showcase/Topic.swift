import SwiftVaporUI

/// A feature area of SwiftVaporUI, shown as one page of the showcase.
struct Topic: Sendable {
    /// The URL path segment, such as `text` for `/text`.
    let slug: String
    let title: String
    /// One line for the home page card and the sidebar tooltip.
    let tagline: String
    /// Paragraphs introducing the topic.
    let intro: [String]
    let examples: [Example]

    var path: String { "/\(slug)" }
}

/// Every showcase page, in sidebar order.
enum Topics {
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
        ElementsTopic.topic,
        MediaTopic.topic,
        DocumentsTopic.topic,
        PageSetupTopic.topic,
    ]

    static func topic(slug: String) -> Topic? {
        all.first { $0.slug == slug }
    }
}
