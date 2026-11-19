import SwiftVaporUI

// snippet: list
/// A seedling in the list examples.
struct Seedling: Sendable {

    /// The seedling's name.
    let name: String

    /// How many days it takes to sprout.
    let daysToSprout: Int

    /// Whether it has been sown yet.
    let sown: Bool
}

let seedlings = [
    Seedling(name: "Basil", daysToSprout: 7, sown: true),
    Seedling(name: "Chilli", daysToSprout: 14, sown: false),
    Seedling(name: "Lettuce", daysToSprout: 5, sown: true),
]
// end-snippet

/// The "Lists and ForEach" showcase page.
enum ListsTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "lists",
        title: "Lists and ForEach",
        tagline: "List, ForEach, for loops and description lists.",
        intro: [
            "There are three ways to repeat content: List builds a whole <ul> from a collection, ForEach renders a view per element anywhere, and a plain for loop works inside any view builder.",
            "The examples on this page share a small seedlings array, shown in the first example.",
        ],
        examples: [
            Example(
                "list",
                title: "List",
                summary: "List(data) { row } is the quickest route from a collection to a bulleted list. Each row is wrapped in an <li> for you."
            ) {
                // snippet: list
                List(seedlings) { seedling in
                    Strong(seedling.name)
                    " sprouts in about \(seedling.daysToSprout) days"
                }
                // end-snippet
            },

            Example(
                "foreach",
                title: "ForEach",
                summary: "ForEach renders its content once per element, without adding a wrapper element. Use it inside lists, tables, stacks or anywhere else."
            ) {
                // snippet: foreach
                OrderedList {
                    ForEach(seedlings) { seedling in
                        ListItem {
                            seedling.name
                            if seedling.sown {
                                " "
                                Span("sown").class("badge", "badge-green")
                            }
                        }
                    }
                }
                // end-snippet
            },

            Example(
                "for-loop",
                title: "for loops",
                summary: "A for-in loop inside a builder works too, including where clauses, ranges and enumerated()."
            ) {
                // snippet: for-loop
                UnorderedList {
                    for seedling in seedlings where !seedling.sown {
                        ListItem("Still to sow: \(seedling.name)")
                    }
                }
                HStack(spacing: 6) {
                    for week in 1...4 {
                        Span("Week \(week)").class("badge")
                    }
                }
                // end-snippet
            },

            Example(
                "sorted",
                title: "Transforming the data first",
                summary: "Because it is all Swift, sort, filter and map the collection right where you use it."
            ) {
                // snippet: sorted
                let quickest = seedlings.sorted { $0.daysToSprout < $1.daysToSprout }

                OrderedList {
                    for (rank, seedling) in quickest.enumerated() {
                        ListItem {
                            Strong(seedling.name)
                            " (\(seedling.daysToSprout) days)"
                            if rank == 0 {
                                " 🏆"
                            }
                        }
                    }
                }
                // end-snippet
            },

            Example(
                "description-list",
                title: "Description lists",
                summary: "DescriptionList, DescriptionTerm and DescriptionDetail render <dl>, <dt> and <dd> for key-value content."
            ) {
                // snippet: description-list
                DescriptionList {
                    ForEach(seedlings) { seedling in
                        DescriptionTerm(seedling.name)
                        DescriptionDetail(seedling.sown ? "Sown, sprouts in \(seedling.daysToSprout) days" : "Not sown yet")
                    }
                }
                // end-snippet
            },

            Example(
                "nested-lists",
                title: "Nested lists",
                summary: "Lists nest like any other view."
            ) {
                // snippet: nested-lists
                let beds = ["Herbs": ["Basil", "Mint"], "Salad": ["Lettuce", "Rocket", "Radish"]]

                UnorderedList {
                    for bed in beds.keys.sorted() {
                        ListItem {
                            Strong(bed)
                            UnorderedList {
                                ForEach(beds[bed] ?? []) { plant in
                                    ListItem(plant)
                                }
                            }
                        }
                    }
                }
                // end-snippet
            },
        ]
    )
}
