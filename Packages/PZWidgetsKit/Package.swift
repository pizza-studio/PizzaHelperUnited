// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZWidgetsKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v14), .macCatalyst(.v14), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZWidgetsKit",
            targets: ["PZWidgetsKit"]
        ),
    ],
    dependencies: [
        .package(path: "../GITodayMaterialsKit"),
        .package(path: "../PZKit"),
        .package(path: "../WallpaperKit"),
        .package(path: "../PZInGameEventKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PZWidgetsKit",
            dependencies: [
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "PZInGameEventKit", package: "PZInGameEventKit"),
                .product(name: "GITodayMaterialsKit", package: "GITodayMaterialsKit"),
                .product(name: "WallpaperKit", package: "WallpaperKit"),
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
