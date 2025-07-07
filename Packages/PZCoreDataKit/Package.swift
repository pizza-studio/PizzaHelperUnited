// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PZCoreDataKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v14), .macOS(.v14), .macCatalyst(.v14), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PZCoreDataKit4LocalAccounts",
            targets: ["PZCoreDataKit4LocalAccounts"]
        ),
        .library(
            name: "PZCoreDataKit4GachaEntries",
            targets: ["PZCoreDataKit4GachaEntries"]
        ),
        .library(
            name: "PZCoreDataKitShared",
            targets: ["PZCoreDataKitShared"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/prisma-ai/Sworm.git", .upToNextMajor(from: "1.3.0")
        ),
        .package(
            url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "PZCoreDataKit4LocalAccounts",
            dependencies: [
                "PZCoreDataKitShared",
                .product(name: "Sworm", package: "Sworm"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .target(
            name: "PZCoreDataKit4GachaEntries",
            dependencies: [
                "PZCoreDataKitShared",
                .product(name: "Sworm", package: "Sworm"),
            ],
            resources: [
                .process("Resources/"),
            ]
        ),
        .target(name: "PZCoreDataKitShared"),
    ]
)
