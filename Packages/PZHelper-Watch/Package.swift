// swift-tools-version: 6.2
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
    platforms: [.watchOS(.v9)],
    products: [
        .library(
            name: "PZHelper-Watch",
            targets: ["PZHelper-Watch"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
    ],
    targets: [
        .target(
            name: "PZHelper-Watch",
            dependencies: [
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "PZHelper-WatchTests",
            dependencies: ["PZHelper-Watch"]
        ),
    ]
)
