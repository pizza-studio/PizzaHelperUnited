// swift-tools-version: 6.0
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
    name: "PZHelperPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        .library(
            name: "PZHelper",
            targets: ["PZHelper"]
        ),
    ],
    dependencies: [
        .package(path: "../GITodayMaterialsKit"),
        .package(path: "../WallpaperKit"),
        .package(path: "../EnkaKit"),
        .package(path: "../GachaKit"),
        .package(path: "../PZWidgetsKit"),
        .package(path: "../PZKit"),
        .package(path: "../PZAboutKit"),
        .package(path: "../PZHoYoLabKit"),
        .package(path: "../PZInGameEventKit"),
        .package(url: "https://github.com/elai950/AlertToast", .upToNextMajor(from: "1.3.9")),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")),
    ],
    targets: [
        .target(
            name: "PZHelper",
            dependencies: [
                .product(name: "AlertToast", package: "AlertToast"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "PZAboutKit", package: "PZAboutKit"),
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "EnkaKit", package: "EnkaKit"),
                .product(name: "GachaKit", package: "GachaKit"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "GITodayMaterialsKit", package: "GITodayMaterialsKit"),
                .product(name: "PZHoYoLabKit", package: "PZHoYoLabKit"),
                .product(name: "PZInGameEventKit", package: "PZInGameEventKit"),
                .product(name: "WallpaperKit", package: "WallpaperKit"),
                .product(name: "WallpaperConfigKit", package: "WallpaperKit"),
                .product(name: "PZWidgetsKit", package: "PZWidgetsKit"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "PZHelperTests",
            dependencies: ["PZHelper"]
        ),
    ]
)
