// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZWidgetsKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZWidgetsKit",
            targets: ["PZWidgetsKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(path: "../WallpaperKit"),
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
            name: "PZWidgetsKit",
            dependencies: [
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "WallpaperKit", package: "WallpaperKit"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Defaults", package: "Defaults"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .testTarget(
            name: "PZWidgetsKitTests",
            dependencies: ["PZWidgetsKit"]
        ),
    ]
)
