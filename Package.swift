// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "slox",
    platforms: [
        .macOS(.v10_15)  // or .v10_15_4 if needed
    ],
    products: [
        .executable(name: "slox", targets: ["slox"]),
        .executable(name: "GenerateAST", targets: ["GenerateAST"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "slox",
            path: "Sources/slox"
        ),
        .executableTarget(
            name: "GenerateAST",
            path: "Sources/tools/GenerateAST"
        ),
    ]
)
