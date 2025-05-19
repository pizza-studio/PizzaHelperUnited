// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GachaKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .macCatalyst(.v17), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GachaKit",
            targets: ["GachaKit"]
        ),
    ],
    dependencies: [
        .package(path: "../PZKit"),
        .package(path: "../EnkaKit"),
        .package(
            url: "https://github.com/pizza-studio/GachaMetaGenerator", .upToNextMajor(from: "2.5.0")
        ),
        .package(
            url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", .upToNextMajor(from: "6.2.0")
        ),
        .package(
            url: "https://github.com/prisma-ai/Sworm.git", .upToNextMajor(from: "1.1.0")
        ),
        .package(
            url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")
        ),
        .package(
            url: "https://github.com/CoreOffice/CoreXLSX", .upToNextMajor(from: "0.14.2")
        ),
        .package(
            url: "https://github.com/elai950/AlertToast", .upToNextMajor(from: "1.3.9")
        ),
        .package(
            url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.2")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GachaKit",
            dependencies: [
                .product(name: "PZAccountKit", package: "PZKit"),
                .product(name: "PZBaseKit", package: "PZKit"),
                .product(name: "EnkaKit", package: "EnkaKit"),
                .product(name: "Sworm", package: "Sworm"),
                .product(name: "GachaMetaDB", package: "GachaMetaGenerator"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "Defaults", package: "Defaults"),
                .product(name: "CoreXLSX", package: "CoreXLSX"),
                .product(name: "AlertToast", package: "AlertToast"),
                .product(name: "Alamofire", package: "Alamofire"),
            ],
            resources: [
                .process("Resources/"),
            ],
            swiftSettings: sharedSwiftSettings
        ),
        .testTarget(
            name: "GachaKitTests",
            dependencies: ["GachaKit"]
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
