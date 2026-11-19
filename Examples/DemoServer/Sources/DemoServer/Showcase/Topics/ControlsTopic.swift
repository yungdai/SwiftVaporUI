import Foundation
import SwiftVaporUI

/// The "SwiftUI controls" showcase page: Toggle, Picker, Slider, Stepper,
/// DatePicker and ProgressView, plus the typed HTML inputs under them.
enum ControlsTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "controls",
        title: "SwiftUI controls",
        tagline: "Toggle, Picker, Slider, Stepper, DatePicker, ProgressView and typed inputs.",
        intro: [
            "The SwiftUI-style controls each render a <label> around a real form field, so they submit with their Form and work without JavaScript. Modifiers such as .disabled() and .class(_:) go to the field itself, as they would in SwiftUI.",
            "Underneath are the typed inputs (Checkbox, RadioButton, NumberField, RangeField, DateField, EmailField and FileField) and the other HTML5 form elements: <optgroup>, <datalist>, <meter> and <output>.",
        ],
        examples: [
            Example(
                "swiftui-controls",
                title: "A form of SwiftUI-style controls",
                summary: "Submit it to see what the browser sends. Each control's name is the field name on the server."
            ) {
                // snippet: swiftui-controls
                Form(action: "/forms/echo", method: .post) {
                    Toggle("Email me when the market opens", name: "notify", isOn: true)
                    Picker("Spice level", name: "spice", selection: "medium", options: [
                        PickerOption("Mild", value: "mild"),
                        PickerOption("Medium", value: "medium"),
                        PickerOption("Hot", value: "hot"),
                    ])
                    Picker("Table", name: "table", selection: "inside", style: .radioGroup, options: [
                        PickerOption("Inside", value: "inside"),
                        PickerOption("By the river", value: "river"),
                    ])
                    Slider("Lantern brightness", name: "brightness", value: 70, in: 0...100, step: 5, showsValue: true)
                    Stepper("Guests", name: "guests", value: 2, in: 1...12)
                    DatePicker("Arriving", name: "arrival", selection: marketOpening, displayedComponents: [.date, .hourAndMinute])
                    Button("Send").class("button")
                }
                .class("stack-form", "controls-form")
                // end-snippet
            },

            Example(
                "disabled-controls",
                title: "Disabled controls",
                summary: ".disabled() on a control disables the field, not the label, just as in SwiftUI."
            ) {
                // snippet: disabled-controls
                VStack(spacing: 8) {
                    Toggle("Reserve a table (fully booked)", name: "reserve").disabled()
                    Stepper("Lanterns", name: "lanterns", value: 1, in: 1...4).disabled()
                }
                .class("controls-form")
                // end-snippet
            },

            Example(
                "progress",
                title: "ProgressView and Meter",
                summary: "ProgressView is a <progress> bar: indeterminate with no value, or value out of total. Meter is for a measurement in a range, and colours itself with low, high and optimum."
            ) {
                // snippet: progress
                VStack(spacing: 10) {
                    ProgressView("Setting up stalls")
                    ProgressView("Lanterns lit", value: 34, total: 50)
                    HStack {
                        Span("Seats taken")
                        Meter(value: 0.9, low: 0.5, high: 0.8, optimum: 0.2, label: "90%")
                    }
                }
                .class("controls-form")
                // end-snippet
            },

            Example(
                "typed-inputs",
                title: "Typed inputs",
                summary: "One view per HTML input type, with the attributes that type takes. Pair them with Label(for:) when you want your own layout."
            ) {
                // snippet: typed-inputs
                Form(action: "/forms/echo", method: .post) {
                    Label("Sign up for the newsletter", for: "news")
                    Checkbox(name: "news", value: "yes", id: "news")

                    Fieldset {
                        Legend("Payment")
                        Label { RadioButton(name: "pay", value: "card", isChecked: true); " Card" }.class("choice")
                        Label { RadioButton(name: "pay", value: "cash"); " Cash" }.class("choice")
                    }

                    Label("Portions", for: "portions")
                    NumberField(name: "portions", value: 1, min: 1, max: 6, id: "portions")

                    Label("Volume", for: "volume")
                    RangeField(name: "volume", value: 30, in: 0...100, id: "volume")

                    Label("Date", for: "date")
                    DateField(name: "date", value: "2026-11-27", min: "2026-11-20", id: "date")

                    Label("Email", for: "email")
                    EmailField("sam@example.com", name: "email", id: "email")

                    Label("Photo of your stall", for: "photo")
                    FileField(name: "photo", accept: ["image/*"], id: "photo")

                    Button("Send").class("button")
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "option-groups",
                title: "Option groups and suggestions",
                summary: "OptionGroup labels a set of options in a Select. A DataList offers suggestions to a TextField(list:), while still allowing any value."
            ) {
                // snippet: option-groups
                VStack(spacing: 10) {
                    Select(name: "drink") {
                        OptionGroup("Hot") {
                            Option("Jasmine tea")
                            Option("Ginger tea")
                        }
                        OptionGroup("Cold") {
                            Option("Bubble tea")
                            Option("Lemonade")
                        }
                    }

                    TextField("Pick or type a herb", name: "herb", list: "herbs")
                    DataList(id: "herbs") {
                        Option("Basil")
                        Option("Coriander")
                        Option("Thai basil")
                    }
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "output",
                title: "Output",
                summary: "<output> shows the result of a calculation. Here a two-line inline script adds two numbers as you type; the server could fill it in just as well."
            ) {
                // snippet: output
                Form {
                    HStack(spacing: 6) {
                        NumberField(name: "a", value: 2, id: "a").frame(width: 70)
                        "+"
                        NumberField(name: "b", value: 3, id: "b").frame(width: 70)
                        "="
                        Output("5", name: "sum", for: ["a", "b"]).bold()
                    }
                }
                .attribute("oninput", "sum.value = a.valueAsNumber + b.valueAsNumber")
                // end-snippet
            },
        ]
    )

}

/// The next market night, used as the date picker's starting value.
let marketOpening = ISO8601DateFormatter().date(from: "2026-11-27T18:00:00Z") ?? Date()
