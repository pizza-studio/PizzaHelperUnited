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
    name: "PZHelper-WatchPKG",
    defaultLocalization: "en",
    platforms: [.watchOS(.v10)],
    products: [
        .library(
            name: "PZHelper-Watch",
            targets: ["PZHelper-Watch"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(
            url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")
        ),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "5.3.0")),
    ],
    targets: [
        .target(
            name: "PZHelper-Watch",
            dependencies: [
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "PZHelper-WatchTests",
            dependencies: ["PZHelper-Watch"]
        ),
    ]
)
