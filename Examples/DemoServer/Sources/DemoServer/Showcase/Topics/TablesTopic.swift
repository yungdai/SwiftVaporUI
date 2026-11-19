import SwiftVaporUI

// snippet: data-table
struct HarvestRow: Sendable {
    let crop: String
    let bed: String
    let kilograms: Double
}

let harvest = [
    HarvestRow(crop: "Tomatoes", bed: "South", kilograms: 12.5),
    HarvestRow(crop: "Courgettes", bed: "East", kilograms: 8),
    HarvestRow(crop: "Beans", bed: "South", kilograms: 4.25),
    HarvestRow(crop: "Potatoes", bed: "North", kilograms: 21),
]
// end-snippet

enum TablesTopic {
    static let topic = Topic(
        slug: "tables",
        title: "Tables",
        tagline: "Table, rows and cells from your data.",
        intro: [
            "Tables are built from Table, TableHead, TableBody, TableFooter, TableRow, TableHeaderCell and TableCell, which map directly onto the HTML table elements.",
            "Combine them with ForEach to render a row per record, and use ordinary Swift to compute totals and pick classes.",
        ],
        examples: [
            Example(
                "basic-table",
                title: "A simple table",
                summary: "Header cells go in a TableHead, data rows in a TableBody."
            ) {
                // snippet: basic-table
                Table {
                    TableHead {
                        TableRow {
                            TableHeaderCell("Plant")
                            TableHeaderCell("Light")
                            TableHeaderCell("Water")
                        }
                    }
                    TableBody {
                        TableRow {
                            TableCell("Pothos")
                            TableCell("Low")
                            TableCell("Weekly")
                        }
                        TableRow {
                            TableCell("Cactus")
                            TableCell("Bright")
                            TableCell("Monthly")
                        }
                    }
                }
                .class("data-table")
                // end-snippet
            },

            Example(
                "data-table",
                title: "Rows from data, with a total",
                summary: "ForEach builds the body rows, the footer adds them up, and .class(_:when:) highlights the biggest crop."
            ) {
                // snippet: data-table
                let total = harvest.reduce(0) { $0 + $1.kilograms }
                let biggest = harvest.max { $0.kilograms < $1.kilograms }?.crop

                Table {
                    TableHead {
                        TableRow {
                            TableHeaderCell("Crop")
                            TableHeaderCell("Bed")
                            TableHeaderCell("Harvest (kg)").class("number")
                        }
                    }
                    TableBody {
                        ForEach(harvest) { row in
                            TableRow {
                                TableCell(row.crop)
                                TableCell(row.bed)
                                TableCell(row.kilograms.formatted()).class("number")
                            }
                            .class("highlight", when: row.crop == biggest)
                        }
                    }
                    TableFooter {
                        TableRow {
                            TableCell("Total")
                            TableCell("")
                            TableCell(total.formatted()).class("number")
                        }
                    }
                }
                .class("data-table")
                // end-snippet
            },

            Example(
                "rich-cells",
                title: "Cells with any content",
                summary: "The builder forms of TableCell hold links, badges, buttons or whole stacks. Use .attribute for cell attributes such as colspan."
            ) {
                // snippet: rich-cells
                let beds = ["North", "South", "East"]

                Table {
                    TableBody {
                        ForEach(beds) { bed in
                            let crops = harvest.filter { $0.bed == bed }
                            TableRow {
                                TableHeaderCell(bed).attribute("scope", "row")
                                TableCell {
                                    HStack(spacing: 6) {
                                        ForEach(crops) { crop in
                                            Span(crop.crop).class("badge", "badge-green")
                                        }
                                    }
                                }
                                TableCell {
                                    Link("Details", destination: "#rich-cells")
                                }
                            }
                        }
                        TableRow {
                            TableCell {
                                Small("West bed is resting this year.").class("muted")
                            }
                            .attribute("colspan", "3")
                        }
                    }
                }
                .class("data-table")
                // end-snippet
            },
        ]
    )
}
