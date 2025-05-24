// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "SwiftProtocolsExample",
    products: [
        .library(
            name: "SwiftProtocolsExample",
            targets: ["SwiftProtocolsExample"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftProtocolsExample",
            dependencies: []),
        .testTarget(
            name: "SwiftProtocolsExampleTests",
            dependencies: ["SwiftProtocolsExample"]),
    ]
) 