// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftProtocolsExample",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftProtocolsExample",
            targets: ["SwiftProtocolsExample"]),
        .library(
            name: "OpenAPIClientGenerator",
            targets: ["OpenAPIClientGenerator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SwiftProtocolsExample",
            dependencies: []),
        .target(
            name: "OpenAPIClientGenerator",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]),
        .testTarget(
            name: "SwiftProtocolsExampleTests",
            dependencies: ["SwiftProtocolsExample"]),
        .testTarget(
            name: "OpenAPIClientGeneratorTests",
            dependencies: ["OpenAPIClientGenerator"]),
    ]
) 