// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AbyssRankKit",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AbyssRankKit",
            targets: ["AbyssRankKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(path: "../EnkaKit"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "5.3.0")),
        .package(url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "8.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AbyssRankKit",
            dependencies: [
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "EnkaKit", package: "EnkaKit"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Defaults", package: "Defaults"),
            ]
        ),
        .testTarget(
            name: "AbyssRankKitTests",
            dependencies: ["AbyssRankKit"]
        ),
    ]
)