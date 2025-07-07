// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZAboutKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v14), .macCatalyst(.v14), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZAboutKit",
            targets: ["PZAboutKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(
            url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")
        ),
        .package(
            url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "6.2.0")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PZAboutKit",
            dependencies: [
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Defaults", package: "Defaults"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .testTarget(
            name: "PZAboutKitTests",
            dependencies: ["PZAboutKit"]
        ),
    ]
)
