// swift-tools-version: 6.0
import Foundation
import PackageDescription

// SwiftLint runs as a build tool plugin, but only in a checkout that has
// opted in with an untracked `.enable-swiftlint` file (see the README). The
// file is git-ignored, so it never exists where SwiftPM or Xcode resolve
// SwiftVaporUI as a dependency, and consumers never fetch or run SwiftLint.
let lintEnabled = FileManager.default.fileExists(
    atPath: Context.packageDirectory + "/.enable-swiftlint"
)

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
