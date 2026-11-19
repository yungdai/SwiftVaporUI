// swift-tools-version: 6.0
import PackageDescription

// SwiftLint runs as a build tool plugin while developing this package
// (Xcode and `swift build`). It is skipped when SwiftVaporUI is resolved as
// a dependency (checked out under a `checkouts` directory), so consumers
// never download or run it. Set SWIFTVAPORUI_LINT=0 to turn it off locally.
let lintEnabled = !Context.packageDirectory.contains("/checkouts/")
    && Context.environment["SWIFTVAPORUI_LINT"] != "0"

let lintPlugins: [Target.PluginUsage] = lintEnabled
    ? [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
    : []

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
]
if lintEnabled {
    dependencies.append(.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.65.1"))
}

let package = Package(
    name: "SwiftVaporUI",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "SwiftVaporUI", targets: ["SwiftVaporUI"]),
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "SwiftVaporUI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ],
            plugins: lintPlugins
        ),
        .testTarget(
            name: "SwiftVaporUITests",
            dependencies: [
                "SwiftVaporUI",
                .product(name: "XCTVapor", package: "vapor"),
            ],
            plugins: lintPlugins
        ),
    ]
)
