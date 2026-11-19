// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DemoServer",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins.git", from: "0.65.1"),
    ],
    targets: [
        .executableTarget(
            name: "DemoServer",
            dependencies: [
                .product(name: "SwiftVaporUI", package: "SwiftVaporUI"),
                .product(name: "Vapor", package: "vapor"),
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins"),
            ]
        ),
    ]
)
