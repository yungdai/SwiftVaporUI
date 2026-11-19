import SwiftVaporUI

/// Where this file lives, so the capstone page can show its source.
let marketDataSourceFile = #filePath

// snippet: market-data
/// What a stall sells.
enum StallCategory: String, CaseIterable, Sendable {

    /// Hot food.
    case food

    /// Drinks.
    case drink

    /// Things made by hand.
    case crafts

    /// Live music.
    case music

    /// The category's name as shown to people.
    var title: String { rawValue.capitalized }
}

/// One stall at the market.
struct Stall: Sendable {

    /// The stall's name.
    let name: String

    /// What the stall sells.
    let category: StallCategory

    /// One sentence about the stall.
    let blurb: String

    /// Short tags shown under the blurb.
    let tags: [String]

    /// Whether the stall is new this week.
    var isNew = false

    /// Whether the stall has sold out.
    var isSoldOut = false
}

/// One event in tonight's programme.
struct ScheduleSlot: Sendable {

    // MARK: - Properties

    /// When it starts, such as `6:00 pm`.
    let time: String

    /// What happens.
    let title: String

    /// Where it happens.
    let place: String

    // MARK: - Computed Properties

    /// The time in 24-hour form for `<time datetime>`, such as `18:00`.
    var dateTime: String {
        let parts = time.split(separator: " ")
        let clock = parts.first?.split(separator: ":").compactMap { Int($0) } ?? []
        guard clock.count == 2 else { return time }
        let hour = clock[0] % 12 + (parts.last == "pm" ? 12 : 0)
        return String(format: "%02d:%02d", hour, clock[1])
    }
}

/// Everything the page shows. In a real app this would come from a database.
struct NightMarket: Sendable {

    // MARK: - Properties

    /// The market's name.
    let name = "Riverside Night Market"

    /// When the market runs.
    let date = "Every Friday, 6pm to 11pm"

    /// Tonight's stalls.
    let stalls: [Stall] = [
        Stall(name: "Ember & Salt", category: .food, blurb: "Charcoal-grilled corn with lime butter and smoked chilli.", tags: ["vegetarian"], isNew: true),
        Stall(name: "Dumpling Lantern", category: .food, blurb: "Hand-folded pork and chive dumplings, pan-fried to order.", tags: ["hot", "popular"]),
        Stall(name: "The Cold Brewery", category: .drink, blurb: "Nitro cold brew and sparkling hibiscus tea on tap.", tags: ["non-alcoholic"]),
        Stall(name: "Fig & Fennel", category: .food, blurb: "Wood-fired flatbreads with seasonal toppings.", tags: ["vegan option"], isSoldOut: true),
        Stall(name: "Loom Room", category: .crafts, blurb: "Hand-woven scarves and table runners from local makers.", tags: ["handmade"]),
        Stall(name: "Clay Harbour", category: .crafts, blurb: "Stoneware mugs and bowls, glazed in river blues.", tags: ["handmade"], isNew: true),
        Stall(name: "Lemon Press", category: .drink, blurb: "Fresh lemonade with mint, ginger or lavender.", tags: ["kids' favourite"]),
        Stall(name: "Bridge Sessions", category: .music, blurb: "Acoustic sets on the riverside stage all night.", tags: ["free"]),
    ]

    /// Tonight's programme.
    let schedule: [ScheduleSlot] = [
        ScheduleSlot(time: "6:00 pm", title: "Stalls open", place: "Everywhere"),
        ScheduleSlot(time: "7:00 pm", title: "Dumpling folding demo", place: "Dumpling Lantern"),
        ScheduleSlot(time: "8:00 pm", title: "Bridge Sessions: first set", place: "River stage"),
        ScheduleSlot(time: "9:30 pm", title: "Lantern walk along the river", place: "Meet at the bridge"),
        ScheduleSlot(time: "11:00 pm", title: "Last orders", place: "Everywhere"),
    ]

    /// Common questions and their answers.
    let faqs: [(question: String, answer: String)] = [
        ("Is it free to get in?", "Yes. You only pay the stalls you buy from."),
        ("Can I bring my dog?", "Dogs on leads are welcome. Water bowls are by the bridge."),
        ("What if it rains?", "Most stalls have covers. We only close for storms, and post it here by 3pm."),
    ]

    // MARK: - Methods

    /// Filters the stalls by category.
    /// - Parameter category: The category, or `nil` for every stall.
    /// - Returns: The matching stalls.
    func stalls(in category: StallCategory?) -> [Stall] {
        guard let category else { return stalls }
        return stalls.filter { $0.category == category }
    }
}

/// The values posted by the "I'm coming" form.
struct VisitForm: Content {

    // MARK: - Properties

    /// The visitor's name.
    var name: String?

    /// How many people are coming, as sent.
    var guests: String?

    /// `yes` when the visitor wants cancellation emails.
    var updates: String?

    // MARK: - Methods

    /// Checks the values.
    /// - Returns: A message for the first problem, or `nil` when the form is valid.
    func validate() -> String? {
        let trimmed = name?.trimmingCharacters(in: .whitespaces) ?? ""
        if trimmed.isEmpty { return "Please tell us your name." }
        guard (1...8).contains(Int(guests ?? "") ?? 0) else {
            return "Choose between 1 and 8 guests."
        }
        return nil
    }
}
// end-snippet
