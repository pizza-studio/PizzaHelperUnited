// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WallpaperKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v14), .macCatalyst(.v14), .watchOS(.v9), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WallpaperKit",
            targets: ["WallpaperKit"]
        ),
        .library(
            name: "WallpaperConfigKit",
            targets: ["WallpaperConfigKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/elai950/AlertToast", .upToNextMajor(from: "1.3.9")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WallpaperKit",
            dependencies: [
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "PZBaseKit", package: "PZKit"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .target(
            name: "WallpaperConfigKit",
            dependencies: [
                "WallpaperKit",
                .product(name: "AlertToast", package: "AlertToast"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "PZBaseKit", package: "PZKit"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .testTarget(
            name: "WallpaperKitTests",
            dependencies: ["WallpaperKit"]
        ),
    ]
)
