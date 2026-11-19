import SwiftVaporUI

/// Where this file lives, so the capstone page can show its source.
let marketPageSourceFile = #filePath

// snippet: market-page
/// What happened with the "I'm coming" form, if anything.
enum VisitState: Sendable {
    case notSent
    case confirmed(name: String, guests: Int)
    case failed(message: String, form: VisitForm)
}

struct MarketPage: View {
    let market: NightMarket
    let category: StallCategory?
    var visit: VisitState = .notSent

    var body: some View {
        HTMLDocument(title: market.name) {
            Meta(name: "description", content: "Street food, makers and music by the river.")
            ResourceLink(relationship: "icon", destination: "/images/leaf.svg")
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
                Link("How this page is made", destination: "/capstone").attribute("target", "_top")
            }
            .class("market-footer")
        }
    }
}
// end-snippet

// snippet: market-header
struct MarketHeader: View {
    let name: String

    var body: some View {
        Header {
            HStack(spacing: 24) {
                Link(destination: "/market") {
                    Span("🏮")
                    Strong(name)
                }
                .class("market-brand")
                Spacer()
                NavigationBar(spacing: 20) {
                    Link("Stalls", destination: "#stalls")
                    Link("Tonight", destination: "#schedule")
                    Link("Visit", destination: "#visit")
                }
                .aria("label", "Market")
            }
        }
        .class("market-header")
    }
}

struct MarketHero: View {
    let market: NightMarket

    var body: some View {
        Section {
            Paragraph(market.date).class("hero-date")
            Heading("Street food, makers and music by the river")
            Paragraph("Eight stalls, a riverside stage and a lantern walk every Friday night. Come hungry.")
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

struct HeroStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 0) {
            Strong(value).class("hero-stat-value")
            Small(label)
        }
    }
}
// end-snippet

// snippet: market-stalls
struct StallSection: View {
    let stalls: [Stall]
    let selected: StallCategory?

    var body: some View {
        Section {
            HStack(spacing: 16) {
                Heading("The stalls", level: .h2)
                Spacer()
                NavigationBar(spacing: 6) {
                    Link("All", destination: "/market#stalls")
                        .class("active", when: selected == nil)
                    ForEach(StallCategory.allCases) { category in
                        Link(category.title, destination: "/market?category=\(category.rawValue)#stalls")
                            .class("active", when: category == selected)
                    }
                }
                .class("filters")
                .aria("label", "Filter stalls")
            }
            .class("section-head")

            if stalls.isEmpty {
                Paragraph("No stalls in this category tonight.")
            } else {
                Div {
                    ForEach(stalls) { stall in
                        StallCard(stall: stall)
                    }
                }
                .class("stall-grid")
            }
        }
        .id("stalls")
    }
}

struct StallCard: View {
    let stall: Stall

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
        .class("is-sold-out", when: stall.isSoldOut)
    }
}
// end-snippet

// snippet: market-schedule
struct ScheduleSection: View {
    let schedule: [ScheduleSlot]

    var body: some View {
        Section {
            Heading("Tonight", level: .h2)
            Table {
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
                            TableCell(slot.time).class("time")
                            TableCell { Strong(slot.title) }
                            TableCell(slot.place)
                        }
                    }
                }
            }
            .class("schedule")
        }
        .id("schedule")
    }
}

struct FAQSection: View {
    let faqs: [(question: String, answer: String)]

    var body: some View {
        Section {
            Heading("Good to know", level: .h2)
            ForEach(faqs) { faq in
                Details {
                    Summary(faq.question)
                    Paragraph(faq.answer)
                }
                .class("faq")
            }
        }
    }
}
// end-snippet

// snippet: market-visit
struct VisitSection: View {
    let visit: VisitState

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

struct VisitFormView: View {
    let form: VisitForm

    var body: some View {
        Form(action: "/market/visit#visit", method: .post) {
            Label("Your name", for: "visit-name")
            TextField("Sam", name: "name", id: "visit-name", text: form.name, autocomplete: "given-name")
            Label("How many of you?", for: "visit-guests")
            Select(name: "guests") {
                for count in 1...8 {
                    Option("\(count)", selected: "\(count)" == (form.guests ?? "2"))
                }
            }
            .id("visit-guests")
            Label {
                Input(type: .checkbox, name: "updates", value: "yes")
                    .flag("checked", if: form.updates == "yes")
                " Email me if it's cancelled"
            }
            .class("check")
            Button("I'm coming").class("market-button")
        }
    }
}
// end-snippet

// snippet: market-routes
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
.filters a.active { background: var(--night); color: #fff; }
.stall-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(230px, 1fr)); gap: 16px; }
.stall { background: #fff; border-radius: 16px; padding: 16px 18px; box-shadow: 0 1px 2px rgba(20,24,43,.06), 0 8px 24px rgba(20,24,43,.06); }
.stall h3 { margin: 10px 0 4px; font-size: 1.1rem; }
.stall p { margin: 0 0 8px; color: var(--soft); font-size: .93rem; }
.stall.is-sold-out { opacity: .55; }
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
.visit .check { font-weight: 400; display: flex; align-items: center; gap: 6px; margin: 4px 0 8px; }
.visit form .market-button { justify-self: start; }
.confirmation { background: #e2f6e9; border-radius: 12px; padding: 16px; }
.form-error { background: #ffe8dc; color: #9a3412; border-radius: 10px; padding: 10px 14px; }
.faq { background: #fff; border-radius: 12px; padding: 12px 16px; margin-bottom: 10px; box-shadow: 0 1px 2px rgba(20,24,43,.06); }
.faq summary { cursor: pointer; font-weight: 600; }
.faq p { margin: 8px 0 0; color: var(--soft); }
.market-footer { background: var(--night); color: #b8bbd3; text-align: center; padding: 28px 24px; display: flex; flex-direction: column; gap: 4px; align-items: center; }
.market-footer a { color: var(--lantern); }
@media (max-width: 640px) { .hero { padding: 40px 24px; } .market-header nav { display: none; } }
"""
