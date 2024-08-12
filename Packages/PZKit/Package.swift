// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - SourceFolderSetting

enum SourceFolderSetting {
    case singleOne
    case separateOSes
    case separatedOSesAndShared
}

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
    name: "PizzaKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .macCatalyst(.v17), .visionOS(.v1)],
    products: buildProducts {
        Product.library(
            name: "PizzaKit",
            targets: buildStrings {
                "PZBaseKit"
                "PZAccountKit"
                "PZKitBackend"
                "PZKitFrontend"
            }
        )
        Product.library(
            name: "PZBaseKit",
            targets: ["PZBaseKit"]
        )
        Product.library(
            name: "PZAccountKit",
            targets: ["PZAccountKit"]
        )
        Product.library(
            name: "PZKitBackend",
            targets: ["PZKitBackend"]
        )
        Product.library(
            name: "PZKitFrontend",
            targets: ["PZKitFrontend"]
        )

        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        Product.library(
            name: "EnkaKit",
            targets: ["EnkaKit"]
        )
        Product.library(
            name: "GachaKit",
            targets: ["GachaKit"]
        )
        #endif
    },
    dependencies: buildPackageDependencies {
        Package.Dependency.package(
            url: "https://github.com/sindresorhus/Defaults",
            .upToNextMajor(from: "8.2.0")
        )
        Package.Dependency.package(
            url: "https://github.com/pizza-studio/GachaMetaGenerator",
            .upToNextMajor(from: "2.1.2")
        )
        Package.Dependency.package(
            url: "https://github.com/pizza-studio/EnkaDBGenerator",
            .upToNextMajor(from: "1.3.1")
        )
        Package.Dependency.package(
            url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git",
            .upToNextMajor(from: "5.3.0")
        )
        Package.Dependency.package(
            url: "https://github.com/pizza-studio/ArtifactRatingDB.git",
            .upToNextMajor(from: "1.0.2")
        )
    },
    targets: buildTargets {
        // MARK: - Common Targets

        Target.target(
            name: "PZBaseKit",
            dependencies: buildTargetDependencies {
                Target.Dependency.product(
                    name: "Defaults",
                    package: "Defaults"
                )
            },
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "PZAccountKit",
            dependencies: ["PZBaseKit"],
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "PZKitBackend",
            dependencies: buildTargetDependencies {
                "PZBaseKit"
                "PZAccountKit"
                #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
                "EnkaKit"
                "GachaKit"
                #endif
            },
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "PZKitFrontend",
            dependencies: ["PZBaseKit", "PZAccountKit", "PZKitBackend"],
            swiftSettings: sharedSwiftSettings
        )

        // MARK: - Non-Watch Targets

        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        Target.target(
            name: "EnkaKit",
            dependencies: buildTargetDependencies {
                "PZBaseKit"
                Target.Dependency.product(
                    name: "EnkaDBFiles",
                    package: "EnkaDBGenerator",
                    condition: .when(platforms: [.iOS, .macOS, .macCatalyst, .visionOS])
                )
                Target.Dependency.product(
                    name: "EnkaDBModels",
                    package: "EnkaDBGenerator",
                    condition: .when(platforms: [.iOS, .macOS, .macCatalyst, .visionOS])
                )
                Target.Dependency.product(
                    name: "ArtifactRatingDB",
                    package: "ArtifactRatingDB",
                    condition: .when(platforms: [.iOS, .macOS, .macCatalyst, .visionOS])
                )
                Target.Dependency.product(
                    name: "SFSafeSymbols",
                    package: "SFSafeSymbols"
                )
            },
            resources: buildResources {
                Resource.process("Assets/")
            },
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "GachaKit",
            dependencies: buildTargetDependencies {
                "PZBaseKit"
                Target.Dependency.product(
                    name: "GachaMetaDB",
                    package: "GachaMetaGenerator",
                    condition: .when(platforms: [.iOS, .macOS, .macCatalyst, .visionOS])
                )
            },
            swiftSettings: sharedSwiftSettings
        )
        #endif

        // MARK: - Test Targets

        Target.testTarget(
            name: "PizzaKitFrontendTests",
            dependencies: ["PZKitFrontend"]
        )

        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        Target.testTarget(
            name: "EnkaKitTests",
            dependencies: ["EnkaKit"],
            resources: buildResources {
                Resource.process("TestAssets/")
            }
        )
        #endif
    }
)

// MARK: - ArrayBuilder

@resultBuilder
enum ArrayBuilder<Element> {
    public static func buildEither(first elements: [Element]) -> [Element] {
        elements
    }

    public static func buildEither(second elements: [Element]) -> [Element] {
        elements
    }

    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        elements ?? []
    }

    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    public static func buildExpression(_: ()) -> [Element] {
        []
    }

    public static func buildBlock(_ elements: [Element]...) -> [Element] {
        elements.flatMap { $0 }
    }

    public static func buildArray(_ elements: [[Element]]) -> [Element] {
        Array(elements.joined())
    }
}

func buildTargets(@ArrayBuilder<Target?> targets: () -> [Target?]) -> [Target] {
    targets().compactMap { $0 }
}

func buildStrings(@ArrayBuilder<String?> strings: () -> [String?]) -> [String] {
    strings().compactMap { $0 }
}

func buildProducts(@ArrayBuilder<Product?> products: () -> [Product?]) -> [Product] {
    products().compactMap { $0 }
}

func buildTargetDependencies(
    @ArrayBuilder<Target.Dependency?> dependencies: () -> [Target.Dependency?]
)
    -> [Target.Dependency] {
    dependencies().compactMap { $0 }
}

func buildResources(
    @ArrayBuilder<Resource?> dependencies: () -> [Resource?]
)
    -> [Resource] {
    dependencies().compactMap { $0 }
}

func buildPackageDependencies(
    @ArrayBuilder<Package.Dependency?> dependencies: () -> [Package.Dependency?]
)
    -> [Package.Dependency] {
    dependencies().compactMap { $0 }
}
