import SwiftVaporUI

/// The shelf: every plant, and a link to add one.
struct HomePage: View {

    // MARK: - Properties

    /// The plants on the shelf.
    let plants: [Plant]

    // MARK: - View

    /// The elements this view is made of.
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

/// One plant's details.
struct PlantPage: View {

    // MARK: - Properties

    /// The plant to show.
    let plant: Plant

    /// Whether the plant was just added, which shows a confirmation.
    var justAdded = false

    // MARK: - View

    /// The elements this view is made of.
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

/// The form for adding a plant, with any errors from the last attempt.
struct NewPlantPage: View {

    // MARK: - Properties

    /// The values to fill the form with.
    let form: PlantForm

    /// Problems with the last submission.
    let errors: [String]

    // MARK: - View

    /// The elements this view is made of.
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

/// Shown, with a 404 status, for a plant that does not exist.
struct NotFoundPage: View {

    /// The elements this view is made of.
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
