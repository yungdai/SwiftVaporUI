import Foundation
import SwiftVaporUI

/// The "Forms, inputs and buttons" showcase page.
enum FormsTopic {

    /// The page's topic, with every example.
    static let topic = Topic(
        slug: "forms",
        title: "Forms, inputs and buttons",
        tagline: "Text fields, pickers, buttons and actions.",
        intro: [
            "Forms are plain HTML forms, so they work without JavaScript. Form posts to a route, and Vapor decodes the fields with req.content.decode.",
            "Every form on this page really submits. They post to /forms/echo, which renders the values it received with SwiftVaporUI.",
        ],
        examples: [
            Example(
                "text-fields",
                title: "Text fields",
                summary: "TextField, SecureField and TextArea mirror SwiftUI's names. Pair each one with a Label whose for: matches the field's id."
            ) {
                // snippet: text-fields
                Form(action: "/forms/echo", method: .post) {
                    Div {
                        Label("Name", for: "name")
                        TextField("Ada Lovelace", name: "name", id: "name", autocomplete: "name")
                    }
                    Div {
                        Label("Email", for: "email")
                        TextField("ada@example.com", name: "email", id: "email", type: .email)
                    }
                    Div {
                        Label("Password", for: "password")
                        SecureField(name: "password", id: "password", autocomplete: "new-password")
                    }
                    Div {
                        Label("About you", for: "bio")
                        TextArea(name: "bio", rows: 3, placeholder: "A sentence or two").id("bio")
                    }
                    Button("Send").class("button")
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "choices",
                title: "Pickers, radio buttons and checkboxes",
                summary: "Select and Option make a drop-down. Input covers radio buttons and checkboxes; group related ones in a Fieldset with a Legend."
            ) {
                // snippet: choices
                let lightLevels = ["Low", "Medium", "Bright"]

                Form(action: "/forms/echo") {
                    Div {
                        Label("Light", for: "light")
                        Select(name: "light") {
                            ForEach(lightLevels) { level in
                                Option(level, value: level.lowercased(), selected: level == "Medium")
                            }
                        }
                        .id("light")
                    }
                    Fieldset {
                        Legend("Pot size")
                        for size in ["Small", "Large"] {
                            Label {
                                Input(type: .radio, name: "pot", value: size.lowercased())
                                    .flag("checked", if: size == "Small")
                                size
                            }
                            .class("choice")
                        }
                    }
                    Label {
                        Input(type: .checkbox, name: "reminders", value: "yes")
                        "Send me watering reminders"
                    }
                    .class("choice")
                    Button("Save").class("button")
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "button-actions",
                title: "Button actions",
                summary: "A Button's action decides what it renders: submit and reset buttons, a plain button for your own scripts, a link styled as a button, or an inline script."
            ) {
                // snippet: button-actions
                Form(action: "/forms/echo") {
                    TextField("Type something, then try Reset", name: "note")
                        .style("margin-bottom", "10px")
                    HStack(spacing: 8) {
                        Button("Submit").class("button")
                        Button("Reset", action: .reset).class("button-secondary")
                        Button("Go to tables", action: .navigate(to: "/tables")).class("button-secondary")
                        Button("Say hi", action: .script("this.textContent = 'Hi there!'")).class("button-secondary")
                        Button("Disabled", action: .plain).class("button").disabled()
                    }
                }
                .class("stack-form")
                .style("max-width", "none")
                // end-snippet
            },

            Example(
                "validation",
                title: "Built-in validation attributes",
                summary: "The browser checks required fields, lengths, patterns and number ranges before submitting. Use .required(), .minLength(_:), .maxLength(_:), .pattern(_:) and the input type. .inputMode(_:) and .enterKeyHint(_:) pick the on-screen keyboard."
            ) {
                // snippet: validation
                Form(action: "/forms/echo") {
                    Div {
                        Label("Plant name (required)", for: "plant")
                        TextField(name: "plant", id: "plant")
                            .required()
                            .minLength(2)
                            .maxLength(40)
                            .enterKeyHint(.next)
                    }
                    Div {
                        Label("Pot code, such as AB-123", for: "pot")
                        TextField(name: "pot", id: "pot")
                            .pattern("[A-Z]{2}-[0-9]{3}")
                            .tooltip("Two capital letters, a dash and three digits")
                            .enterKeyHint(.next)
                    }
                    Div {
                        Label("Water every (days)", for: "days")
                        Input(type: .number, name: "days", value: "7")
                            .id("days")
                            .attribute("min", "1")
                            .attribute("max", "60")
                            .inputMode(.numeric)
                            .enterKeyHint(.send)
                    }
                    Button("Check and send").class("button")
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "button-overrides",
                title: "Buttons that submit differently",
                summary: "One form, several buttons. .formNoValidate() skips the browser's checks for a draft, and .formAction(_:) with .formMethod(_:) sends the same fields somewhere else."
            ) {
                // snippet: button-overrides
                Form(action: "/forms/echo") {
                    Div {
                        Label("Note (required)", for: "note")
                        TextField(name: "note", id: "note").required()
                    }
                    HStack(spacing: 8) {
                        Button("Publish").class("button")
                        Button("Save draft")
                            .formNoValidate()
                            .class("button-secondary")
                        Button("Preview as GET")
                            .formAction("/forms/echo")
                            .formMethod(.get)
                            .formNoValidate()
                            .class("button-secondary")
                    }
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "file-upload",
                title: "Uploading a file",
                summary: "A form with a FileField needs encoding: .multipart, or the browser sends only the file name. On the server, decode the file as Vapor's File."
            ) {
                // snippet: file-upload
                Form(action: "/forms/upload", encoding: .multipart) {
                    Div {
                        Label("A photo of your plant", for: "photo")
                        FileField(name: "photo", accept: ["image/*"], id: "photo").required()
                    }
                    Div {
                        Label("Caption", for: "caption")
                        TextField(name: "caption", id: "caption").maxLength(80)
                    }
                    Button("Upload").class("button")
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "search",
                title: "A GET form",
                summary: "With method: .get the fields go in the query string, which suits search and filter forms."
            ) {
                // snippet: search
                Form(action: "/forms/echo", method: .get) {
                    HStack(spacing: 8) {
                        TextField("Search plants", name: "q", type: .search)
                            .aria("label", "Search plants")
                        Button("Search").class("button")
                    }
                }
                .class("stack-form")
                // end-snippet
            },

            Example(
                "handling",
                title: "Handling the submission",
                summary: "On the server, decode the fields and return a view. This is the route behind /forms/echo, shown here with sample values."
            ) {
                // snippet: handling
                FormEcho(method: "POST", fields: [("name", "Ada"), ("light", "medium")])
                // end-snippet
            },
        ]
    )

}

// snippet: handling
/// A table of the fields a form sent.
struct FormEcho: View {

    // MARK: - Properties

    /// The HTTP method the form used.
    let method: String

    /// The fields the browser sent, in order.
    let fields: [(name: String, value: String)]

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        Heading("Received a \(method) request", level: .h3)
        if fields.isEmpty {
            Paragraph("No fields were sent.").class("muted")
        } else {
            Table {
                ForEach(fields) { field in
                    TableRow {
                        TableHeaderCell(field.name)
                        TableCell(field.value.isEmpty ? "(empty)" : field.value)
                    }
                }
            }
            .class("data-table")
        }
    }

}

/// Registers the routes the form examples submit to.
/// - Parameter app: The application to add the routes to.
func registerFormRoutes(_ app: Application) {
    app.on(.GET, "forms", "echo") { req in
        let fields = try req.query.decode([String: String].self)
        return FormEchoPage(method: "GET", fields: fields)
    }
    app.on(.POST, "forms", "echo") { req in
        let fields = try req.content.decode([String: String].self)
        return FormEchoPage(method: "POST", fields: fields)
    }
}
// end-snippet

// snippet: file-upload
/// The fields of the upload form.
struct PhotoUpload: Content {

    /// The uploaded file: its name, type and bytes.
    var photo: File

    /// The caption, if one was typed.
    var caption: String?

}

/// Registers the route the upload example submits to. It reports the file
/// it received rather than keeping it.
/// - Parameter app: The application to add the route to.
func registerUploadRoute(_ app: Application) {
    // Vapor collects at most 16 KB of body by default; allow photos.
    app.on(.POST, "forms", "upload", body: .collect(maxSize: "10mb")) { req in
        let upload = try req.content.decode(PhotoUpload.self)
        return FormEchoPage(method: "POST", fields: [
            "photo": upload.photo.filename,
            "size": "\(upload.photo.data.readableBytes) bytes",
            "type": upload.photo.contentType?.description ?? "unknown",
            "caption": upload.caption ?? "",
        ])
    }
}
// end-snippet

/// The full page around `FormEcho`, inside the showcase layout.
struct FormEchoPage: View {

    // MARK: - Properties

    /// The HTTP method the form used.
    let method: String

    /// The fields the browser sent.
    let fields: [String: String]

    // MARK: - View

    /// The elements this view is made of.
    var body: some View {
        ShowcaseLayout(title: "Form received", currentPath: "/forms") {
            Header {
                Paragraph("Forms, inputs and buttons").class("eyebrow")
                Heading("Form received")
                Paragraph("This page was rendered by the /forms/echo route from the values your browser sent.").class("lead")
            }
            .class("page-header")
            FormEcho(method: method, fields: fields.sorted { $0.key < $1.key }.map { (name: $0.key, value: $0.value) })
                .padding(.top, 8)
            Paragraph {
                Link("← Back to forms", destination: "/forms")
            }
            .padding(.top, 16)
        }
    }

}
