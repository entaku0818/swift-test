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