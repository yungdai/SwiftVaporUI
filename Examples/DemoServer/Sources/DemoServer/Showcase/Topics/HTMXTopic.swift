import SwiftVaporUI

/// The "Live updates with htmx" showcase page.
enum HTMXTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "htmx",
        title: "Live updates with htmx",
        tagline: "Partial page updates from server-rendered fragments.",
        intro: [
            "htmx lets any element send a request and swap the HTML that comes back into the page. SwiftVaporUI has typed modifiers for its hx-* attributes, an HTMXScript view that loads it, and req.fragmentOrPage, so one route can answer htmx with a fragment and a browser with the full page.",
            "Every page of this showcase loads htmx with HTMXScript() in its head, so the examples below are live. Without JavaScript, the links and forms still work as plain HTML.",
        ],
        examples: [
            Example(
                "click-to-load",
                title: "Click to load a fragment",
                summary: "The button asks /fragments/stat for a new StatTile and swaps it in place of the old one. Open that URL directly and the same route sends a full page instead."
            ) {
                // snippet: click-to-load
                HStack(spacing: 12) {
                    StatTile(label: "Fragments rendered", value: "0")
                        .id("stat-tile")
                    Button("Render another", action: .plain)
                        .hxGet("/fragments/stat")
                        .hxTarget("#stat-tile")
                        .hxSwap(.outerHTML.transition())
                    Link("Open /fragments/stat", destination: "/fragments/stat")
                }
                // end-snippet
            },

            Example(
                "polling",
                title: "Polling",
                summary: "PlantCount polls /fragments/plant-count every five seconds and replaces itself. Add a plant in the sample app in another tab and watch the number change here.",
                file: demoSourcesDirectory.appendingPathComponent("PlantShelf/PlantShelfComponents.swift").path
            ) {
                PlantCount(count: 3)
            },

            Example(
                "active-search",
                title: "Search as you type",
                summary: "The field sends its value to /htmx/search after you stop typing for 300 ms, and the results replace the list below it. Pressing Enter does the same, and without JavaScript the form still submits. The spinner shows while the request is in flight."
            ) {
                // snippet: active-search
                // Without JavaScript the form submits normally. With htmx,
                // pressing Enter and typing both update the results in place.
                // The input inherits hx-target, hx-swap and hx-indicator.
                Form(action: "/htmx/search", method: .get) {
                    Input(type: .search, name: "q", placeholder: "Search plants")
                        .aria("label", "Search plants")
                        .hxGet("/htmx/search")
                        .hxTrigger(.input.changed().delay(.milliseconds(300)), .search)
                    Small("Searching…").id("search-spinner").class("htmx-indicator muted")
                }
                .hxGet("/htmx/search")
                .hxTarget("#search-results")
                .hxSwap(.outerHTML)
                .hxIndicator("#search-spinner")
                PlantSearchResults(query: "")
                // end-snippet
            },

            Example(
                "fragment-or-page",
                title: "One route, fragment or page",
                summary: "req.fragmentOrPage sends the fragment when htmx asks for it and wraps it in a page otherwise, with Vary: HX-Request so caches keep the two apart. These are the routes the examples above use."
            ) {
                // snippet: fragment-or-page
                Paragraph {
                    "Try "
                    Link("/fragments/stat", destination: "/fragments/stat")
                    " and "
                    Link("/htmx/search?q=fern", destination: "/htmx/search?q=fern")
                    " in the address bar: each is a whole page there."
                }
                // end-snippet
            },
        ]
    )

}

// snippet: active-search
/// The plant names the search example looks through.
let searchablePlants = [
    "Boston fern", "Calathea", "Golden pothos", "Jade plant", "Monstera",
    "Peace lily", "Rubber plant", "Snake plant", "Spider plant", "ZZ plant",
]

/// The plants whose names contain the search text, as a list.
struct PlantSearchResults: View {

    // MARK: - Properties

    /// The search text.
    let query: String

    // MARK: - Computed Properties

    /// The matching plant names, or every name when the search is empty.
    var matches: [String] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return searchablePlants }
        return searchablePlants.filter { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Div {
            if matches.isEmpty {
                Paragraph("No plants match “\(query)”.").class("muted")
            } else {
                UnorderedList {
                    ForEach(matches) { name in
                        ListItem(name)
                    }
                }
            }
        }
        .id("search-results")
        .aria("live", "polite")
    }

}
// end-snippet

// snippet: fragment-or-page
// In main.swift:
/// Registers the routes the htmx examples request.
/// - Parameter app: The application to add the routes to.
func registerHTMXRoutes(_ app: Application) {
    app.get("htmx", "search") { req in
        let query = req.query[String.self, at: "q"] ?? ""
        return req.fragmentOrPage(PlantSearchResults(query: query)) { results in
            ShowcaseLayout(title: "Search", currentPath: "/htmx") {
                Heading("Plants matching “\(query)”")
                results
                Link("← Back to htmx", destination: "/htmx#active-search")
            }
        }
    }
}
// end-snippet
