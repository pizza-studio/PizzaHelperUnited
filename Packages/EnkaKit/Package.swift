// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EnkaKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EnkaKit",
            targets: ["EnkaKit"]
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
        .package(
            url: "https://github.com/pizza-studio/EnkaDBGenerator", .upToNextMajor(from: "1.8.1")
        ),
        .package(
            url: "https://github.com/pizza-studio/ArtifactRatingDB", .upToNextMajor(from: "1.1.4")
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EnkaKit",
            dependencies: [
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "WallpaperKit", package: "WallpaperKit"),
                .product(name: "EnkaDBFiles", package: "EnkaDBGenerator"),
                .product(name: "EnkaDBModels", package: "EnkaDBGenerator"),
                .product(name: "ArtifactRatingDB", package: "ArtifactRatingDB"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "Alamofire", package: "Alamofire"),
            ],
            resources: [
                .process("Assets/"),
                .process("Resources/"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "EnkaKitTests",
            dependencies: [
                "EnkaKit",
            ]
        ),
    ]
)

let sharedSwiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-Xfrontend",
        "-warn-long-function-bodies=250",
        "-Xfrontend",
        "-warn-long-expression-type-checking=250",
    ]),
    .enableExperimentalFeature("AccessLevelOnImport"),
]
