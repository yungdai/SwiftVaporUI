import SwiftVaporUI

/// The Plant Shelf sample app, served under /plants.
func registerPlantShelfRoutes(_ app: Application) {
    let shelf = PlantShelf()

    app.get("plants") { _ in
        HomePage(plants: await shelf.all())
    }

    app.get("plants", ":slug") { req in
        guard let slug = req.parameters.get("slug"), let plant = await shelf.plant(slug: slug) else {
            return HTMLResponse(status: .notFound) { AnyView(NotFoundPage()) }
        }
        let justAdded = req.query[String.self, at: "added"] == "1"
        return HTMLResponse { AnyView(PlantPage(plant: plant, justAdded: justAdded)) }
    }

    app.get("plants", "new") { _ in
        NewPlantPage(form: PlantForm(), errors: [])
    }

    app.post("plants") { req async throws -> Response in
        let form = try req.content.decode(PlantForm.self)
        let errors = form.validate()
        guard errors.isEmpty else {
            return try await HTMLResponse(status: .unprocessableEntity) {
                NewPlantPage(form: form, errors: errors)
            }
            .encodeResponse(for: req)
        }
        let plant = await shelf.add(form)
        // Redirect after a successful POST, so reloading the page does not
        // submit the form again.
        return req.redirect(to: "/plants/\(plant.slug)?added=1", redirectType: .normal)
    }

    // A fragment: any view can be returned on its own, which suits htmx-style
    // partial updates.
    app.get("fragments", "plant-count") { _ in
        PlantCount(count: await shelf.all().count)
    }
}
