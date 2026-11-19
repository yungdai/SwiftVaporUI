import SwiftVaporUI

struct HomePage: View {
    let plants: [Plant]

    var body: some View {
        SiteLayout(title: "All plants") {
            Heading("Your plant shelf")
            PlantCount(count: plants.count)

            if plants.isEmpty {
                Paragraph {
                    "Nothing here yet. "
                    Link("Add your first plant", destination: "/plants/new")
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
                Heading(plant.name)
                LightBadge(light: plant.light)
                DescriptionList {
                    DescriptionTerm("Light")
                    DescriptionDetail(plant.light.label)
                    DescriptionTerm("Watering")
                    DescriptionDetail("Every \(plant.waterEveryDays) days")
                }
                .padding(.vertical, 8)
                if !plant.notes.isEmpty {
                    Heading("Care notes", level: .h2)
                    Paragraph(plant.notes)
                }
            }
            Link("← Back to all plants", destination: "/plants")
        }
    }
}

struct NewPlantPage: View {
    let form: PlantForm
    let errors: [String]

    var body: some View {
        SiteLayout(title: "Add a plant") {
            Heading("Add a plant")
            Paragraph("Fields marked as required must be filled in.").font(.footnote).foregroundColor(.gray)
            ErrorSummary(errors: errors)

            Form(action: "/plants", method: .post) {
                VStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Label("Name", for: "name")
                        TextField("e.g. Monstera", name: "name", id: "name", text: form.name, autocomplete: "off")
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
                    HStack(spacing: 12) {
                        Button("Add to shelf")
                        Button("Cancel", action: .navigate(to: "/plants")).class("button-secondary")
                    }
                }
            }
        }
    }
}

struct NotFoundPage: View {
    var body: some View {
        SiteLayout(title: "Not found") {
            Heading("No plant by that name")
            Paragraph {
                "It may have wilted. "
                Link("See all plants", destination: "/plants")
                "."
            }
        }
    }
}
