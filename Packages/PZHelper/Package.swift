// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sharedSwiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-Xfrontend",
        "-warn-long-function-bodies=250",
        "-Xfrontend",
        "-warn-long-expression-type-checking=250",
    ]),
    .enableExperimentalFeature("AccessLevelOnImport"),
]

let package = Package(
    name: "PZHelper",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        .library(
            name: "PZHelper",
            targets: ["PZHelper"]
        ),
    ],
    dependencies: [
        .package(path: "../PZDictionaryKit"),
        .package(path: "../WallpaperKit"),
        .package(path: "../EnkaKit"),
        .package(path: "../GachaKit"),
        .package(path: "../PZKit"),
        .package(path: "../PZHoYoLabKit"),
        .package(url: "https://github.com/elai950/AlertToast", .upToNextMajor(from: "1.3.9")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "5.3.0")),
    ],
    targets: [
        .target(
            name: "PZHelper",
            dependencies: [
                .product(name: "AlertToast", package: "AlertToast"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "PizzaKit", package: "PZKit"),
                .product(name: "EnkaKit", package: "EnkaKit"),
                .product(name: "GachaKit", package: "GachaKit"),
                .product(name: "PZDictionaryKit", package: "PZDictionaryKit"),
                .product(name: "PZHoYoLabKit", package: "PZHoYoLabKit"),
                .product(name: "WallpaperKit", package: "WallpaperKit"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "PZHelperTests",
            dependencies: ["PZHelper"]
        ),
    ]
)
