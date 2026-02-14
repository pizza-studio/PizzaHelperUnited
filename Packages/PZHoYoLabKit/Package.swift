// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZHoYoLabKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v14), .macCatalyst(.v14), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZHoYoLabKit",
            targets: ["PZHoYoLabKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(path: "../EnkaKit"),
        .package(path: "../WallpaperKit"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PZHoYoLabKit",
            dependencies: [
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "EnkaKit", package: "EnkaKit"),
                .product(name: "WallpaperKit", package: "WallpaperKit"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .testTarget(
            name: "PZHoYoLabKitTests",
            dependencies: ["PZHoYoLabKit"]
        ),
    ]
)
