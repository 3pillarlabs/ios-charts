// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ios-charts",
    products: [
        .library(
            name: "ios-charts",
            targets: ["ios-charts"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ios-charts",
            dependencies: [],
            path: "Sources")
    ]
)
