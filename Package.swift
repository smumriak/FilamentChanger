// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FilamentChanger",
    products: [
        .library(
            name: "FilamentChanger",
            type: .dynamic,
            targets: ["FilamentChanger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/smumriak/PythonKit.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FilamentChanger",
            dependencies: [
                .product(name: "PythonKit", package: "PythonKit"),
            ]
        ),
        .testTarget(
            name: "FilamentChangerTests",
            dependencies: ["FilamentChanger"]),
    ]
)
