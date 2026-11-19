import SwiftVaporUI

let app = try await Application.make(.detect())
let shelf = PlantShelf()

// Full pages.
app.get { _ in
    HomePage(plants: await shelf.all())
}

app.get("plants", ":slug") { req in
    guard let slug = req.parameters.get("slug"), let plant = await shelf.plant(slug: slug) else {
        return HTMLResponse(status: .notFound) { AnyView(NotFoundPage()) }
    }
    return HTMLResponse { AnyView(PlantPage(plant: plant)) }
}

app.get("plants", "new") { _ in
    NewPlantPage(form: PlantForm(), errors: [])
}

app.post("plants") { req in
    let form = try req.content.decode(PlantForm.self)
    let errors = form.validate()
    guard errors.isEmpty else {
        return HTMLResponse(status: .unprocessableEntity) {
            AnyView(NewPlantPage(form: form, errors: errors))
        }
    }
    let plant = await shelf.add(form)
    return HTMLResponse(status: .created) { AnyView(PlantPage(plant: plant, justAdded: true)) }
}

// A fragment: any view can be returned on its own, which suits htmx-style
// partial updates.
app.get("fragments", "plant-count") { _ in
    PlantCount(count: await shelf.all().count)
}

try await app.execute()
try await app.asyncShutdown()
