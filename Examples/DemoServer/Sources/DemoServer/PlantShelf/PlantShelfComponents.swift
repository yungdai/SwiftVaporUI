import SwiftVaporUI

/// The shared page shell: document, header, navigation and footer.
struct SiteLayout<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        HTMLDocument(title: "\(title) · Plant Shelf") {
            Meta(name: "description", content: "A SwiftVaporUI demo")
            Style(siteCSS)
        } body: {
            Header {
                HStack(spacing: 16) {
                    Link("🌿 Plant Shelf", destination: "/plants").class("brand")
                    Spacer()
                    NavigationBar {
                        Link("All plants", destination: "/plants")
                        Link("Add a plant", destination: "/plants/new")
                        Link("Showcase", destination: "/")
                    }
                    .aria("label", "Primary")
                }
            }
            .class("site-header")

            Main { content }.class("container")

            Footer {
                Small("Rendered with SwiftVaporUI, no templates involved.")
                    .foregroundColor(.gray)
            }
            .padding(24)
            .class("site-footer")
        }
    }
}

/// A small pill showing a plant's light needs.
struct LightBadge: View {
    let light: Light

    var body: some View {
        Span(light.label).class("badge", "badge-\(light.rawValue)")
    }
}

/// A summary card for one plant, linking to its page.
struct PlantCard: View {
    let plant: Plant

    var body: some View {
        Article {
            Heading(level: .h3) {
                Link(plant.name, destination: "/plants/\(plant.slug)")
            }
            LightBadge(light: plant.light)
            Paragraph("Water every \(plant.waterEveryDays) days")
        }
        .class("card")
    }
}

/// A fragment that can be returned on its own from a route.
struct PlantCount: View {
    let count: Int

    var body: some View {
        Paragraph {
            Strong("\(count)")
            count == 1 ? " plant on the shelf" : " plants on the shelf"
        }
        .id("plant-count")
    }
}

/// A list of validation messages, or nothing when there are none.
struct ErrorSummary: View {
    let errors: [String]

    var body: some View {
        if !errors.isEmpty {
            Div {
                Strong("Please fix the following:")
                UnorderedList {
                    for error in errors {
                        ListItem(error)
                    }
                }
            }
            .class("errors")
            .role("alert")
        }
    }
}

/// The Plant Shelf app's stylesheet.
let siteCSS = """
:root { --green: #2f6b3a; --ink: #1d2420; --muted: #5d6b62; --line: #dfe6e0; }
* { box-sizing: border-box; }
body { margin: 0; font: 16px/1.5 system-ui, sans-serif; color: var(--ink); background: #f7faf7; }
a { color: var(--green); }
.site-header { background: #fff; border-bottom: 1px solid var(--line); padding: 12px 24px; }
.brand { font-weight: 700; text-decoration: none; font-size: 1.1rem; }
.container { max-width: 880px; margin: 0 auto; padding: 24px; }
.site-footer { text-align: center; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; }
.card { background: #fff; border: 1px solid var(--line); border-radius: 12px; padding: 16px; }
.card h3 { margin: 0 0 8px; }
.badge { display: inline-block; font-size: .8rem; padding: 2px 10px; border-radius: 999px; background: #eef3ee; }
.badge-low { background: #e7ecf7; } .badge-bright { background: #fbf1d8; }
.notice { background: #e8f5ea; border: 1px solid #b8dcbf; padding: 12px; border-radius: 8px; }
.errors { background: #fdecec; border: 1px solid #f2b8b8; padding: 12px; border-radius: 8px; }
form label { font-weight: 600; }
form input, form select, form textarea { width: 100%; padding: 8px; border: 1px solid var(--line); border-radius: 6px; font: inherit; }
button { background: var(--green); color: #fff; border: 0; border-radius: 6px; padding: 10px 18px; font: inherit; cursor: pointer; }
.button-secondary { display: inline-block; padding: 10px 18px; border-radius: 6px; border: 1px solid var(--line); text-decoration: none; }
dl { display: grid; grid-template-columns: max-content 1fr; gap: 4px 16px; }
dt { color: var(--muted); }
dd { margin: 0; }
"""
