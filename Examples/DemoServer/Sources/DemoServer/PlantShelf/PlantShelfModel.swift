import SwiftVaporUI

/// How much light a plant needs.
enum Light: String, CaseIterable, Codable, Sendable {

    /// Shade or a north-facing window.
    case low

    /// Bright, indirect light.
    case medium

    /// Direct sun for part of the day.
    case bright

    /// The light level as shown to people.
    var label: String {
        switch self {
        case .low: "Low light"
        case .medium: "Indirect light"
        case .bright: "Bright light"
        }
    }

}

/// A plant on the shelf.
struct Plant: Sendable {

    /// The URL-safe name used in the plant's address.
    let slug: String

    /// The plant's common name.
    let name: String

    /// How much light the plant needs.
    let light: Light

    /// How many days to wait between waterings.
    let waterEveryDays: Int

    /// Care notes.
    let notes: String

}

/// An in-memory store, so the demo has some state to show.
actor PlantShelf {

    // MARK: - Properties

    /// The plants on the shelf, seeded with a few examples.
    private var plants: [Plant] = [
        Plant(slug: "pothos", name: "Golden pothos", light: .low, waterEveryDays: 7,
              notes: "Trails happily off a bookshelf. Let the top inch of soil dry out."),
        Plant(slug: "fiddle-leaf-fig", name: "Fiddle-leaf fig", light: .bright, waterEveryDays: 10,
              notes: "Dislikes being moved. Rotate a quarter turn each month."),
        Plant(slug: "snake-plant", name: "Snake plant", light: .medium, waterEveryDays: 21,
              notes: "Very forgiving. Overwatering is the main risk."),
    ]

    // MARK: - Methods

    /// Every plant, in the order they were added.
    /// - Returns: The plants.
    func all() -> [Plant] { plants }

    /// Finds a plant by its slug.
    /// - Parameter slug: The URL-safe name.
    /// - Returns: The plant, or `nil` if there is none.
    func plant(slug: String) -> Plant? {
        plants.first { $0.slug == slug }
    }

    /// Adds a plant from a valid form.
    /// - Parameter form: The submitted values.
    /// - Returns: The new plant.
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

    // MARK: - Properties

    /// The name the visitor typed.
    var name = ""

    /// The chosen light level's raw value.
    var light = Light.medium.rawValue

    /// The watering interval as typed.
    var waterEveryDays = "7"

    /// The care notes as typed.
    var notes = ""

    // MARK: - Initializers

    /// Creates an empty form with the default choices.
    init() {}

    /// Missing fields decode as empty, so validation can report them
    /// instead of the request failing with a 400.
    /// - Parameter decoder: The decoder holding the submitted fields.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        light = try container.decodeIfPresent(String.self, forKey: .light) ?? ""
        waterEveryDays = try container.decodeIfPresent(String.self, forKey: .waterEveryDays) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }

    // MARK: - Methods

    /// Checks the values.
    /// - Returns: A message for each problem; empty when the form is valid.
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
