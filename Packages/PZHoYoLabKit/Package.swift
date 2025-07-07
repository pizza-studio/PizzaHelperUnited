// swift-tools-version: 6.0
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
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")),
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
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "Alamofire", package: "Alamofire"),
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
