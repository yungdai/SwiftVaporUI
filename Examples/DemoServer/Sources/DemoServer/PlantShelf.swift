import SwiftVaporUI

enum Light: String, CaseIterable, Codable, Sendable {
    case low, medium, bright

    var label: String {
        switch self {
        case .low: "Low light"
        case .medium: "Indirect light"
        case .bright: "Bright light"
        }
    }
}

struct Plant: Sendable {
    let slug: String
    let name: String
    let light: Light
    let waterEveryDays: Int
    let notes: String
}

/// An in-memory store, so the demo has some state to show.
actor PlantShelf {
    private var plants: [Plant] = [
        Plant(slug: "pothos", name: "Golden pothos", light: .low, waterEveryDays: 7,
              notes: "Trails happily off a bookshelf. Let the top inch of soil dry out."),
        Plant(slug: "fiddle-leaf-fig", name: "Fiddle-leaf fig", light: .bright, waterEveryDays: 10,
              notes: "Dislikes being moved. Rotate a quarter turn each month."),
        Plant(slug: "snake-plant", name: "Snake plant", light: .medium, waterEveryDays: 21,
              notes: "Very forgiving. Overwatering is the main risk."),
    ]

    func all() -> [Plant] { plants }

    func plant(slug: String) -> Plant? {
        plants.first { $0.slug == slug }
    }

    func add(_ form: PlantForm) -> Plant {
        let base = form.name.lowercased().split(whereSeparator: { !$0.isLetter && !$0.isNumber }).joined(separator: "-")
        var slug = base.isEmpty ? "plant" : base
        var suffix = 2
        while plants.contains(where: { $0.slug == slug }) {
            slug = "\(base)-\(suffix)"
            suffix += 1
        }
        let plant = Plant(
            slug: slug,
            name: form.name.trimmingCharacters(in: .whitespaces),
            light: Light(rawValue: form.light) ?? .medium,
            waterEveryDays: Int(form.waterEveryDays) ?? 7,
            notes: form.notes
        )
        plants.append(plant)
        return plant
    }
}

/// The values posted by the "add a plant" form.
struct PlantForm: Content {
    var name = ""
    var light = Light.medium.rawValue
    var waterEveryDays = "7"
    var notes = ""

    func validate() -> [String] {
        var errors: [String] = []
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Give the plant a name.")
        }
        if let days = Int(waterEveryDays), (1...60).contains(days) {
            // valid
        } else {
            errors.append("Watering interval must be a whole number of days between 1 and 60.")
        }
        if Light(rawValue: light) == nil {
            errors.append("Pick a light level.")
        }
        return errors
    }
}
