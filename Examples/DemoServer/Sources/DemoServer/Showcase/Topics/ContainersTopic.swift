import SwiftVaporUI

/// The "SwiftUI containers" showcase page: ZStack, grids, scrolling, tabs,
/// disclosure groups and menus.
enum ContainersTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "containers",
        title: "SwiftUI containers",
        tagline: "ZStack, Grid, LazyVGrid, ScrollView, TabView, DisclosureGroup and Menu.",
        intro: [
            "These containers follow their SwiftUI namesakes and turn into plain HTML and CSS. None of them needs JavaScript: tabs are radio buttons, disclosure groups and menus are <details> elements.",
            "ZStack, Grid, TabView and Menu need a few CSS rules. Inside an HTMLDocument they are written in the <head> for you. In a fragment, like the results on this page, each writes a small <style> element the first time it appears.",
        ],
        examples: [
            Example(
                "zstack",
                title: "ZStack",
                summary: "Children are layered in one grid cell, later ones on top. The alignment places them, like SwiftUI's ZStack(alignment:)."
            ) {
                // snippet: zstack
                ZStack(alignment: .bottomLeading) {
                    Div {}
                        .frame(height: 140)
                        .background(.hex("1d2340"))
                        .cornerRadius(12)
                    Span("Open until 11pm")
                        .class("badge", "badge-orange")
                        .padding(12)
                }
                .frame(maxWidth: 360)
                // end-snippet
            },

            Example(
                "grid",
                title: "Grid and GridRow",
                summary: "Each GridRow is a row and each child a cell. Columns line up and size to their widest cell, so you never count columns."
            ) {
                // snippet: grid
                Grid(alignment: .top, horizontalSpacing: 24, verticalSpacing: 6) {
                    GridRow {
                        Strong("Stall")
                        Strong("Opens")
                        Strong("Pitch")
                    }
                    GridRow {
                        "Dumpling House"
                        Time("18:00", dateTime: "18:00")
                        "A4"
                    }
                    GridRow {
                        "Lantern Tea"
                        Time("18:30", dateTime: "18:30")
                        "B1"
                    }
                }
                // end-snippet
            },

            Example(
                "lazy-v-grid",
                title: "LazyVGrid",
                summary: "Columns are GridItems: .fixed, .flexible or .adaptive. An adaptive column fits as many cards as the width allows, so the grid reflows on phones."
            ) {
                // snippet: lazy-v-grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 10) {
                    ForEach(["Basil", "Thyme", "Mint", "Sage", "Dill", "Chives"]) { herb in
                        Div { herb }.class("box")
                    }
                }

                LazyVGrid(columns: [GridItem(.fixed(80)), GridItem()], spacing: 6) {
                    Strong("Fixed")
                    Span("80 pixels wide; this column takes the rest.")
                }
                .padding(.top, 12)
                // end-snippet
            },

            Example(
                "scroll-view",
                title: "ScrollView",
                summary: "A region that scrolls on one or both axes. It is focusable, so keyboard users can scroll it with the arrow keys."
            ) {
                // snippet: scroll-view
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(1...12) { number in
                            Div { "Stall \(number)" }
                                .class("box")
                                .frame(width: 110)
                        }
                    }
                }
                .padding(.bottom, 8)

                ScrollView {
                    OrderedList {
                        ForEach(1...20) { number in
                            ListItem("Lantern number \(number)")
                        }
                    }
                }
                .frame(maxHeight: 120)
                .border(.hex("e2e5eb"))
                .cornerRadius(8)
                // end-snippet
            },

            Example(
                "tab-view",
                title: "TabView",
                summary: "Tabs switch panels with CSS alone: each Tab is a hidden radio button, a label and a panel. Try the arrow keys once a tab has focus."
            ) {
                // snippet: tab-view
                TabView(id: "stall-info") {
                    Tab("Menu") {
                        UnorderedList {
                            ListItem("Pork and chive dumplings")
                            ListItem("Chilli oil wontons")
                        }
                    }
                    Tab("Hours") {
                        Paragraph("Fridays, 6pm to 11pm.")
                    }
                    Tab("Find us") {
                        Paragraph("Pitch A4, next to the river stage.")
                    }
                }
                // end-snippet
            },

            Example(
                "disclosure-group",
                title: "DisclosureGroup",
                summary: "A label that shows and hides content, rendered as <details> and <summary>. isExpanded starts it open."
            ) {
                // snippet: disclosure-group
                DisclosureGroup("Allergens") {
                    Paragraph("Contains wheat, soy and sesame.")
                }
                DisclosureGroup("Opening hours", isExpanded: true) {
                    Paragraph("Every Friday, 6pm to 11pm.")
                }
                // end-snippet
            },

            Example(
                "menu",
                title: "Menu",
                summary: "A button that drops down a list of actions. It is a <details> too, so it opens and closes without a script."
            ) {
                // snippet: menu
                Menu("Share ▾") {
                    Link("Copy link", destination: "#menu")
                    Link("Email a friend", destination: "mailto:?subject=Night%20market")
                    Link("Open the map", destination: "https://www.openstreetmap.org", target: .blank)
                }
                .class("button-secondary")
                // end-snippet
            },

            Example(
                "popover-menu",
                title: "Menu on the Popover API",
                summary: "Give a Menu a popoverID and it is built on the Popover API: the items open on top of the page and close when you click elsewhere or press Escape. Still no script."
            ) {
                // snippet: popover-menu
                Menu("Directions ▾", popoverID: "directions-menu") {
                    Link("Walking", destination: "#popover-menu")
                    Link("By bike", destination: "#popover-menu")
                    Link("By bus", destination: "#popover-menu")
                }
                // end-snippet
            },

            Example(
                "divider",
                title: "Divider",
                summary: "A thematic break between content, rendered as <hr>."
            ) {
                // snippet: divider
                Paragraph("Food stalls")
                Divider()
                Paragraph("Craft stalls")
                // end-snippet
            },
        ]
    )

}
