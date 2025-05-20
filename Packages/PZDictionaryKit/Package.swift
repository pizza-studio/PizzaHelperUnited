// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZDictionaryKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZDictionaryKit",
            targets: ["PZDictionaryKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "6.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PZDictionaryKit",
            dependencies: [
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
            ]
        ),
        .testTarget(
            name: "PZDictionaryKitTests",
            dependencies: ["PZDictionaryKit"]
        ),
    ]
)
