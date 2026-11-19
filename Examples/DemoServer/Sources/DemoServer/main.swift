import SwiftVaporUI
import Vapor

let app = try await Application.make(.detect())

app.get { _ in
    Page(
        title: "SwiftVaporUI Demo",
        body: "<h1>SwiftVaporUI</h1><p>Examples of the SwiftUI-like DSL will live here.</p>"
    )
}

try await app.execute()
try await app.asyncShutdown()
