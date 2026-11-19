import SwiftVaporUI

/// Where this file lives, so the capstone page can show its source.
let marketPageSourceFile = #filePath

// snippet: market-page
/// What happened with the "I'm coming" form, if anything.
enum VisitState: Sendable {

    /// The form has not been sent.
    case notSent

    /// The visit is booked.
    case confirmed(name: String, guests: Int)

    /// The form had a problem; show it again with the message.
    case failed(message: String, form: VisitForm)
}

/// The colours of the market, passed to every view through the environment.
struct MarketTheme: Sendable {

    /// The warm accent used for highlights.
    var lantern: Color

    /// The dark background of the header and footer.
    var night: Color
}

/// The environment key for `MarketTheme`.
private struct MarketThemeKey: EnvironmentKey {

    /// The market's usual colours.
    static let defaultValue = MarketTheme(lantern: .hex("ffb347"), night: .hex("14182b"))
}

/// The `marketTheme` environment value.
extension EnvironmentValues {

    /// The colours of the market for this part of the page.
    var marketTheme: MarketTheme {
        get { self[MarketThemeKey.self] }
        set { self[MarketThemeKey.self] = newValue }
    }
}

/// The night market page: the whole document.
struct MarketPage: View {

    // MARK: - Properties

    /// The market to show.
    let market: NightMarket

    /// The stall category to filter by, if any.
    let category: StallCategory?

    /// What happened with the visit form.
    var visit: VisitState = .notSent

    // MARK: - View

    /// The document: head, header, sections and footer.
    var body: some View {
        HTMLDocument(title: market.name) {
            Meta(name: "description", content: "Street food, makers and music by the river.")
            ResourceLink(relationship: "icon", destination: "/images/leaf.svg")
            SupportStyles()
            Style(marketCSS)
        } body: {
            MarketHeader(name: market.name)
            Main {
                MarketHero(market: market)
                StallSection(stalls: market.stalls(in: category), selected: category)
                ScheduleSection(schedule: market.schedule)
                HStack(alignment: .top, spacing: 32) {
                    VisitSection(visit: visit)
                    FAQSection(faqs: market.faqs)
                }
                .class("two-up")
            }
            Footer {
                Small("Built with SwiftVaporUI. No templates, no JavaScript framework.")
                Link("How this page is made", destination: "/capstone", target: .top)
            }
            .class("market-footer")
        }
        .environment(\.marketTheme, MarketTheme(lantern: .hex("ffb347"), night: .hex("14182b")))
    }
}
// end-snippet

// snippet: market-header
/// A paper lantern, drawn inline so it needs no image file.
struct LanternIcon: View {

    // MARK: - Properties

    /// The lantern colour from the market theme.
    @ViewEnvironment(\.marketTheme) var theme

    // MARK: - View

    /// The lantern drawing.
    var body: some View {
        SVG(viewBox: "0 0 64 96", width: 18, height: 26) {
            Element("ellipse", attributes: ["cx": "32", "cy": "50", "rx": "28", "ry": "38", "fill": "#ff6b4a"])
            Element("ellipse", attributes: ["cx": "32", "cy": "50", "rx": "14", "ry": "38", "fill": theme.lantern.css])
        }
    }
}

/// The sticky top bar: the market's name, its sections and a share menu.
struct MarketHeader: View {

    // MARK: - Properties

    /// The market's name.
    let name: String

    // MARK: - View

    /// A row with the brand, the section links and the share menu.
    var body: some View {
        Header {
            HStack(spacing: 24) {
                Link(destination: "/market") {
                    LanternIcon()
                    Strong(name)
                }
                .class("market-brand")
                Spacer()
                NavigationBar(spacing: 20) {
                    NavigationLink("Stalls", destination: "#stalls")
                    NavigationLink("Tonight", destination: "#schedule")
                    NavigationLink("Visit", destination: "#visit")
                }
                .aria("label", "Market")
                Menu("Share") {
                    Link("Email a friend", destination: "mailto:?subject=Riverside%20Night%20Market")
                    Link("Open the map", destination: "https://www.openstreetmap.org", target: .blank)
                }
                .class("share")
            }
        }
        .class("market-header")
    }
}

/// The big opening banner with the date, a call to action and three numbers.
struct MarketHero: View {

    // MARK: - Properties

    /// The market to describe.
    let market: NightMarket

    // MARK: - View

    /// The banner.
    var body: some View {
        Section {
            Paragraph(market.date).class("hero-date")
            Heading("Street food, makers and music by the river")
            Paragraph {
                "Eight stalls, a riverside stage and a lantern walk every Friday night. "
                Mark("Come hungry.")
            }
            .class("hero-lead")
            HStack(spacing: 12) {
                Button("I'm coming", action: .navigate(to: "#visit")).class("market-button")
                Button("See the stalls", action: .navigate(to: "#stalls")).class("market-button", "ghost")
            }
            HStack(spacing: 40) {
                HeroStat(value: "\(market.stalls.count)", label: "stalls")
                HeroStat(value: "\(market.schedule.count)", label: "events tonight")
                HeroStat(value: "Free", label: "entry")
            }
            .class("hero-stats")
        }
        .class("hero")
    }
}

/// One big number in the hero, in the theme's lantern colour.
struct HeroStat: View {

    // MARK: - Properties

    /// The colours from the environment.
    @ViewEnvironment(\.marketTheme) var theme

    /// The number, or a word such as "Free".
    let value: String

    /// What the number counts.
    let label: String

    // MARK: - View

    /// The number above its label.
    var body: some View {
        VStack(spacing: 0) {
            Strong(value).class("hero-stat-value").foregroundColor(theme.lantern)
            Small(label)
        }
    }
}
// end-snippet

// snippet: market-stalls
/// The white, rounded, softly shadowed card the page uses for stalls and questions.
struct MarketCard: ViewModifier {

    // MARK: - Properties

    /// Whether the item is unavailable, which fades the card.
    var isDimmed = false

    // MARK: - ViewModifier

    /// Draws `content` as a card.
    /// - Parameter content: The view the modifier is applied to.
    /// - Returns: The content as a card.
    func body(content: Self.Content) -> some View {
        content
            .class("market-card")
            .shadow(color: .rgb(20, 24, 43, opacity: 0.06), radius: 24, y: 8)
            .opacity(isDimmed ? 0.55 : 1)
    }
}

/// The stalls, with links to filter them by category.
struct StallSection: View {

    // MARK: - Properties

    /// The stalls to show.
    let stalls: [Stall]

    /// The category being shown, or `nil` for all of them.
    let selected: StallCategory?

    // MARK: - View

    /// A heading with filter links, then a grid of stall cards.
    var body: some View {
        Section {
            HStack(spacing: 16) {
                Heading("The stalls", level: .h2)
                Spacer()
                NavigationBar(spacing: 6) {
                    NavigationLink("All", destination: "/market#stalls", isActive: selected == nil)
                    ForEach(StallCategory.allCases) { category in
                        NavigationLink(
                            category.title,
                            destination: "/market?category=\(category.rawValue)#stalls",
                            isActive: category == selected
                        )
                    }
                }
                .class("filters")
                .aria("label", "Filter stalls")
            }
            .class("section-head")

            if stalls.isEmpty {
                Paragraph("No stalls in this category tonight.")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 230))], spacing: 16) {
                    ForEach(stalls) { stall in
                        StallCard(stall: stall)
                    }
                }
            }
        }
        .id("stalls")
    }
}

/// One stall: its category, a badge, its name, a blurb and tags.
struct StallCard: View {

    // MARK: - Properties

    /// The stall to show.
    let stall: Stall

    // MARK: - View

    /// The card.
    var body: some View {
        Article {
            HStack(spacing: 8) {
                Span(stall.category.title).class("chip", "chip-\(stall.category.rawValue)")
                Spacer()
                if stall.isSoldOut {
                    Span("Sold out").class("flag", "flag-out")
                } else if stall.isNew {
                    Span("New").class("flag", "flag-new")
                }
            }
            Heading(stall.name, level: .h3)
            Paragraph(stall.blurb)
            Paragraph {
                for tag in stall.tags {
                    Small("#\(tag)").class("tag")
                }
            }
        }
        .class("stall")
        .modifier(MarketCard(isDimmed: stall.isSoldOut))
    }
}
// end-snippet

// snippet: market-schedule
/// Tonight's programme and how to get there, as tabs.
struct ScheduleSection: View {

    // MARK: - Properties

    /// Tonight's programme.
    let schedule: [ScheduleSlot]

    // MARK: - View

    /// A heading and a tab view.
    var body: some View {
        Section {
            Heading("Tonight", level: .h2)
            TabView(id: "tonight") {
                Tab("Programme") {
                    Table {
                        TableCaption("Every Friday from 6pm")
                        TableHead {
                            TableRow {
                                TableHeaderCell("Time")
                                TableHeaderCell("What")
                                TableHeaderCell("Where")
                            }
                        }
                        TableBody {
                            ForEach(schedule) { slot in
                                TableRow {
                                    TableCell { Time(slot.time, dateTime: slot.dateTime) }.class("time")
                                    TableCell { Strong(slot.title) }
                                    TableCell(slot.place)
                                }
                            }
                        }
                    }
                    .class("schedule")
                }
                Tab("Getting there") {
                    Grid(alignment: .top, horizontalSpacing: 20, verticalSpacing: 10) {
                        GridRow { Strong("On foot"); "Ten minutes from the station along the river path." }
                        GridRow { Strong("By bike"); "Racks by the bridge, free all night." }
                        GridRow { Strong("By bus"); "Routes 4 and 11 stop at Riverside." }
                    }
                }
            }
            .class("tonight")
        }
        .id("schedule")
    }
}

/// Common questions, each one opening to show its answer.
struct FAQSection: View {

    // MARK: - Properties

    /// The questions and answers.
    let faqs: [(question: String, answer: String)]

    // MARK: - View

    /// A heading and a disclosure group per question.
    var body: some View {
        Section {
            Heading("Good to know", level: .h2)
            ForEach(faqs) { faq in
                DisclosureGroup(faq.question) {
                    Paragraph(faq.answer)
                }
                .class("faq")
                .modifier(MarketCard())
            }
        }
    }
}
// end-snippet

// snippet: market-visit
/// The "I'm coming" section: the form, the form with an error, or a confirmation.
struct VisitSection: View {

    // MARK: - Properties

    /// What happened with the form.
    let visit: VisitState

    // MARK: - View

    /// The section for the current state.
    var body: some View {
        Section {
            Heading("Let us know you're coming", level: .h2)
            switch visit {
            case let .confirmed(name, guests):
                Paragraph {
                    Strong("See you Friday, \(name)! ")
                    "We've saved space for \(guests) by the river."
                }
                .class("confirmation")
                .role("status")
            case let .failed(message, form):
                Paragraph(message).class("form-error").role("alert")
                VisitFormView(form: form)
            case .notSent:
                VisitFormView(form: VisitForm())
            }
        }
        .id("visit")
        .class("visit")
    }
}

/// The form, filled in with the visitor's earlier values when shown again.
struct VisitFormView: View {

    // MARK: - Properties

    /// The values to fill in.
    let form: VisitForm

    // MARK: - View

    /// The form.
    var body: some View {
        Form(action: "/market/visit#visit", method: .post) {
            Label("Your name", for: "visit-name")
            TextField("Sam", name: "name", id: "visit-name", text: form.name, autocomplete: "given-name")
            Stepper("How many of you?", name: "guests", value: Int(form.guests ?? "") ?? 2, in: 1...8)
            Toggle("Email me if it's cancelled", name: "updates", isOn: form.updates == "yes", value: "yes")
            ProgressView("Riverside tables booked", value: 31, total: 40)
            Button("I'm coming").class("market-button")
        }
    }
}
// end-snippet

// snippet: market-routes
/// Registers the market page and its form route.
/// - Parameter app: The application to add the routes to.
func registerMarketRoutes(_ app: Application) {
    let market = NightMarket()

    // The page, optionally filtered: /market?category=food
    app.get("market") { req in
        let category = req.query[String.self, at: "category"].flatMap(StallCategory.init(rawValue:))
        return MarketPage(market: market, category: category)
    }

    // The form posts here. Invalid input re-renders the page with the
    // message and the values kept, using a 422 status.
    app.post("market", "visit") { req in
        let form = try req.content.decode(VisitForm.self)
        if let message = form.validate() {
            return HTMLResponse(status: .unprocessableEntity) {
                MarketPage(market: market, category: nil, visit: .failed(message: message, form: form))
            }
        }
        let guests = Int(form.guests ?? "") ?? 1
        let name = form.name?.trimmingCharacters(in: .whitespaces) ?? "friend"
        return HTMLResponse {
            MarketPage(market: market, category: nil, visit: .confirmed(name: name, guests: guests))
        }
    }
}
// end-snippet

let marketCSS = """
:root { --night: #14182b; --night-2: #1d2340; --lantern: #ffb347; --ember: #ff6b4a; --paper: #fdf8ef; --ink: #23263a; --soft: #6b6f85; }
* { box-sizing: border-box; }
body { margin: 0; font: 16px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif; color: var(--ink); background: var(--paper); }
main { max-width: 1080px; margin: 0 auto; padding: 0 24px 48px; }
a { color: #c2410c; }
.market-header { background: var(--night); padding: 14px 24px; position: sticky; top: 0; z-index: 5; }
.market-header a { color: #f4f1ff; text-decoration: none; }
.market-header nav a { opacity: .8; } .market-header nav a:hover { opacity: 1; }
.market-brand { display: inline-flex; gap: 8px; font-size: 1.05rem; }
.hero { margin: 0 -24px; padding: 64px 48px 56px; color: #fff; background:
  radial-gradient(circle at 85% 20%, rgba(255,179,71,.45), transparent 32%),
  radial-gradient(circle at 70% 75%, rgba(255,107,74,.35), transparent 30%),
  linear-gradient(160deg, var(--night) 0%, var(--night-2) 100%); }
.hero h1 { font-size: clamp(2rem, 5vw, 3.2rem); line-height: 1.1; margin: 0 0 14px; max-width: 16ch; }
.hero-date { color: var(--lantern); font-weight: 700; letter-spacing: .08em; text-transform: uppercase; font-size: .85rem; margin: 0 0 8px; }
.hero-lead { font-size: 1.15rem; max-width: 46ch; color: #d9dbea; margin: 0 0 24px; }
.hero-stats { margin-top: 36px; }
.hero-stat-value { font-size: 1.8rem; color: var(--lantern); display: block; line-height: 1.1; }
.hero-stats small { color: #b8bbd3; }
.market-button { display: inline-block; background: var(--lantern); color: var(--night); border: 0; border-radius: 999px; padding: 10px 22px; font: inherit; font-weight: 700; text-decoration: none; cursor: pointer; }
.market-button.ghost { background: transparent; color: #fff; box-shadow: inset 0 0 0 2px rgba(255,255,255,.4); }
section { margin-top: 48px; }
h2 { font-size: 1.6rem; margin: 0 0 16px; }
.section-head { flex-wrap: wrap; margin-bottom: 16px; } .section-head h2 { margin: 0; }
.filters a { text-decoration: none; color: var(--soft); padding: 4px 12px; border-radius: 999px; font-size: .9rem; }
.filters a[aria-current=page] { background: var(--night); color: #fff; }
.stall-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 16px; }
.market-card { background: #fff; border-radius: 16px; }
.stall { padding: 16px 18px; }
.stall h3 { margin: 10px 0 4px; font-size: 1.1rem; }
.stall p { margin: 0 0 8px; color: var(--soft); font-size: .93rem; }
.chip { font-size: .72rem; font-weight: 700; text-transform: uppercase; letter-spacing: .06em; padding: 2px 10px; border-radius: 999px; }
.chip-food { background: #ffe8dc; color: #b93c10; } .chip-drink { background: #dff1ff; color: #1b5f93; }
.chip-crafts { background: #efe6ff; color: #5b34a8; } .chip-music { background: #e2f6e9; color: #1f7a45; }
.flag { font-size: .72rem; font-weight: 700; padding: 2px 8px; border-radius: 6px; }
.flag-new { background: var(--lantern); color: var(--night); } .flag-out { background: #e8e8ee; color: #555a70; }
.tag { margin-right: 8px; color: #8a8ea3; }
.schedule { width: 100%; border-collapse: collapse; background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 8px 24px rgba(20,24,43,.06); }
.schedule th, .schedule td { text-align: left; padding: 12px 16px; border-bottom: 1px solid #f0ece3; }
.schedule th { background: var(--night); color: #f4f1ff; font-size: .78rem; text-transform: uppercase; letter-spacing: .06em; }
.schedule .time { color: #c2410c; font-weight: 700; white-space: nowrap; font-variant-numeric: tabular-nums; }
.two-up { flex-wrap: wrap; } .two-up > section { flex: 1 1 320px; }
.visit form { display: grid; gap: 8px; background: #fff; padding: 20px; border-radius: 16px; box-shadow: 0 8px 24px rgba(20,24,43,.06); }
.visit label { font-weight: 600; font-size: .9rem; }
.visit input[type=text], .visit select { padding: 10px 12px; border: 1px solid #ddd8cc; border-radius: 10px; font: inherit; }
.visit .svui-control { display: flex; align-items: center; gap: 10px; }
.visit .svui-control input[type=number] { width: 80px; padding: 8px 10px; border: 1px solid #ddd8cc; border-radius: 10px; font: inherit; }
.visit .svui-control input[type=checkbox] + .svui-control-title { font-weight: 400; }
.visit progress { flex: 1; accent-color: #c2410c; }
.visit form .market-button { justify-self: start; }
.confirmation { background: #e2f6e9; border-radius: 12px; padding: 16px; }
.form-error { background: #ffe8dc; color: #9a3412; border-radius: 10px; padding: 10px 14px; }
.faq { border-radius: 12px; padding: 12px 16px; margin-bottom: 10px; }
.faq summary { cursor: pointer; font-weight: 600; }
.faq p { margin: 8px 0 0; color: var(--soft); }
.market-footer { background: var(--night); color: #b8bbd3; text-align: center; padding: 28px 24px; display: flex; flex-direction: column; gap: 4px; align-items: center; }
.market-footer a { color: var(--lantern); }
.market-brand { align-items: center; }
.share > summary { color: #f4f1ff; opacity: .8; }
.share .svui-menu-items { left: auto; right: 0; background: #fff; color: var(--ink); border: 0; box-shadow: 0 8px 24px rgba(20,24,43,.2); }
.market-header .share .svui-menu-items a { color: var(--ink); padding: 6px 10px; white-space: nowrap; }
mark { background: var(--lantern); color: var(--night); padding: 0 4px; border-radius: 4px; }
.tonight { background: #fff; border-radius: 16px; box-shadow: 0 8px 24px rgba(20,24,43,.06); }
.tonight .svui-tab { color: var(--soft); font-weight: 600; }
.tonight .svui-tab-input:checked + .svui-tab { color: #c2410c; }
.tonight .svui-tab-panel { border-top: 1px solid #f0ece3; }
.tonight .svui-tab-panel > .svui-grid { margin: 12px 8px; }
.tonight .schedule { box-shadow: none; border-radius: 0 0 16px 16px; }
.schedule caption { text-align: left; padding: 12px 16px 4px; color: var(--soft); font-size: .9rem; }
@media (max-width: 640px) { .hero { padding: 40px 24px; } .market-header nav { display: none; } }
"""
