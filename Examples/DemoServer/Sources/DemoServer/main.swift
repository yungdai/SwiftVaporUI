import SwiftVaporUI

// The SwiftVaporUI showcase server.
//
// Run it from Xcode (open Examples/DemoServer/Package.swift, pick the
// DemoServer scheme and press ⌘R) or from a terminal with `swift run`,
// then open http://127.0.0.1:8080.

/// The Vapor application that serves the showcase.
let app = try await Application.make(.detect())

// Default address. `swift run DemoServer serve --port 9000` still overrides it.
app.http.server.configuration.hostname = Environment.get("HOST") ?? "127.0.0.1"
app.http.server.configuration.port = Environment.get("PORT").flatMap(Int.init) ?? 8080

// snippet: static-files
// Serve CSS, JavaScript and images from the Public folder, so
// Public/css/site.css is at /css/site.css. Vapor's default is
// app.directory.publicDirectory, which is relative to the working directory;
// this demo falls back to Public next to its Package.swift so it also works
// from Xcode.
app.middleware.use(FileMiddleware(publicDirectory: demoPublicDirectory(for: app)))
// end-snippet

// The showcase: a home page and one page per feature area.
app.get { _ in ShowcaseHomePage() }
for topic in Topics.all {
    app.get(PathComponent(stringLiteral: topic.slug)) { _ in TopicPage(topic: topic) }
}

// The capstone page, the page it explains, and the playground.
app.get("capstone") { _ in CapstonePage() }
registerMarketRoutes(app)
app.get("playground") { _ in PlaygroundPage() }

// Routes that the examples link to or submit to.
registerFormRoutes(app)
registerNavigationRoutes(app)
registerComponentRoutes(app)
registerHTMXRoutes(app)
registerDocumentRoutes(app)
registerMediaRoutes(app)
app.get("images", "leaf.svg") { _ in
    Response(status: .ok, headers: ["Content-Type": "image/svg+xml"], body: .init(string: leafSVG))
}

// The Plant Shelf sample app.
registerPlantShelfRoutes(app)

/// The URL the server is listening on, for the startup log.
let address = "http://\(app.http.server.configuration.hostname):\(app.http.server.configuration.port)"
app.logger.notice("SwiftVaporUI showcase: open \(address) in your browser.")

try await app.execute()
try await app.asyncShutdown()
