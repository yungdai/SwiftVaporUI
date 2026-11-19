import SwiftVaporUI

struct HomePage: View {
    let plants: [Plant]

    var body: some View {
        SiteLayout(title: "All plants") {
            Heading(.h1, "Your plant shelf")
            PlantCount(count: plants.count)

            if plants.isEmpty {
                Paragraph {
                    "Nothing here yet. "
                    Link("Add your first plant", href: "/plants/new")
                    "."
                }
            } else {
                Section {
                    ForEach(plants) { plant in
                        PlantCard(plant: plant)
                    }
                }
                .class("grid")
                .aria("label", "Plants")
            }
        }
    }
}

struct PlantPage: View {
    let plant: Plant
    var justAdded = false

    var body: some View {
        SiteLayout(title: plant.name) {
            if justAdded {
                Paragraph("Added \(plant.name) to your shelf.").class("notice").role("status")
            }
            Article {
                Heading(.h1, plant.name)
                LightBadge(light: plant.light)
                Element("dl") {
                    Element("dt") { "Light" }
                    Element("dd") { plant.light.label }
                    Element("dt") { "Watering" }
                    Element("dd") { "Every \(plant.waterEveryDays) days" }
                }
                if !plant.notes.isEmpty {
                    Heading(.h2, "Care notes")
                    Paragraph(plant.notes)
                }
            }
            Link("← Back to all plants", href: "/")
        }
    }
}

struct NewPlantPage: View {
    let form: PlantForm
    let errors: [String]

    var body: some View {
        SiteLayout(title: "Add a plant") {
            Heading(.h1, "Add a plant")
            ErrorSummary(errors: errors)

            Form(action: "/plants", method: .post) {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Label("Name", for: "name")
                        TextField("e.g. Monstera", name: "name", text: form.name)
                            .id("name")
                            .required()
                            .autofocus()
                    }
                    VStack(spacing: 4) {
                        Label("Light", for: "light")
                        Select(name: "light") {
                            ForEach(Light.allCases) { light in
                                Option(light.label, value: light.rawValue, selected: light.rawValue == form.light)
                            }
                        }
                        .id("light")
                    }
                    VStack(spacing: 4) {
                        Label("Water every (days)", for: "water")
                        Input(type: .number, name: "waterEveryDays", value: form.waterEveryDays)
                            .id("water")
                            .attribute("min", "1")
                            .attribute("max", "60")
                    }
                    VStack(spacing: 4) {
                        Label("Care notes", for: "notes")
                        TextArea(name: "notes", text: form.notes, rows: 4, placeholder: "Anything worth remembering")
                            .id("notes")
                    }
                    HStack {
                        Button("Add to shelf", type: .submit)
                    }
                }
            }
        }
    }
}

struct NotFoundPage: View {
    var body: some View {
        SiteLayout(title: "Not found") {
            Heading(.h1, "No plant by that name")
            Paragraph {
                "It may have wilted. "
                Link("See all plants", href: "/")
                "."
            }
        }
    }
}
