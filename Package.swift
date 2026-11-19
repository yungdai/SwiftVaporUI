// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SwiftVaporUI",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "SwiftVaporUI", targets: ["SwiftVaporUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
    ],
    targets: [
        .target(
            name: "SwiftVaporUI",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "SwiftVaporUITests",
            dependencies: [
                "SwiftVaporUI",
                .product(name: "XCTVapor", package: "vapor"),
            ]
        ),
    ]
)
