import SwiftVaporUI

/// Where this file lives, so the capstone page can show its source.
let marketDataSourceFile = #filePath

// snippet: market-data
enum StallCategory: String, CaseIterable, Sendable {
    case food, drink, crafts, music

    var title: String { rawValue.capitalized }
}

struct Stall: Sendable {
    let name: String
    let category: StallCategory
    let blurb: String
    let tags: [String]
    var isNew = false
    var isSoldOut = false
}

struct ScheduleSlot: Sendable {
    let time: String
    let title: String
    let place: String

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
    let name = "Riverside Night Market"
    let date = "Every Friday, 6pm to 11pm"
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
    let schedule: [ScheduleSlot] = [
        ScheduleSlot(time: "6:00 pm", title: "Stalls open", place: "Everywhere"),
        ScheduleSlot(time: "7:00 pm", title: "Dumpling folding demo", place: "Dumpling Lantern"),
        ScheduleSlot(time: "8:00 pm", title: "Bridge Sessions: first set", place: "River stage"),
        ScheduleSlot(time: "9:30 pm", title: "Lantern walk along the river", place: "Meet at the bridge"),
        ScheduleSlot(time: "11:00 pm", title: "Last orders", place: "Everywhere"),
    ]
    let faqs: [(question: String, answer: String)] = [
        ("Is it free to get in?", "Yes. You only pay the stalls you buy from."),
        ("Can I bring my dog?", "Dogs on leads are welcome. Water bowls are by the bridge."),
        ("What if it rains?", "Most stalls have covers. We only close for storms, and post it here by 3pm."),
    ]

    func stalls(in category: StallCategory?) -> [Stall] {
        guard let category else { return stalls }
        return stalls.filter { $0.category == category }
    }
}

/// The values posted by the "I'm coming" form.
struct VisitForm: Content {
    var name: String?
    var guests: String?
    var updates: String?

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
