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
    /// The plants on the shelf, seeded with a few examples.
    private var plants: [Plant] = [
        Plant(slug: "pothos", name: "Golden pothos", light: .low, waterEveryDays: 7,
              notes: "Trails happily off a bookshelf. Let the top inch of soil dry out."),
        Plant(slug: "fiddle-leaf-fig", name: "Fiddle-leaf fig", light: .bright, waterEveryDays: 10,
              notes: "Dislikes being moved. Rotate a quarter turn each month."),
        Plant(slug: "snake-plant", name: "Snake plant", light: .medium, waterEveryDays: 21,
              notes: "Very forgiving. Overwatering is the main risk."),
    ]

    /// Returns every plant on the shelf.
    func all() -> [Plant] { plants }

    /// Returns the plant with the given URL slug, if there is one.
    func plant(slug: String) -> Plant? {
        plants.first { $0.slug == slug }
    }

    /// Adds a plant from the submitted form, giving it a unique slug, and returns it.
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

    init() {}

    /// Missing fields decode as empty, so validation can report them
    /// instead of the request failing with a 400.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        light = try container.decodeIfPresent(String.self, forKey: .light) ?? ""
        waterEveryDays = try container.decodeIfPresent(String.self, forKey: .waterEveryDays) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }

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
