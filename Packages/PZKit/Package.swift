// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// MARK: - SourceFolderSetting

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
    name: "PizzaKitPKG",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10), .macCatalyst(.v17), .visionOS(.v1)],
    products: buildProducts {
        Product.library(
            name: "PZBaseKit",
            targets: ["PZBaseKit"]
        )
        Product.library(
            name: "PZAccountKit",
            targets: ["PZAccountKit"]
        )
    },
    dependencies: buildPackageDependencies {
        // 将参数都弄成单行，方便用脚本来更新这些内容的版本号。
        Package.Dependency.package(
            url: "https://github.com/sindresorhus/Defaults", .upToNextMajor(from: "9.0.2")
        )
        Package.Dependency.package(
            url: "https://github.com/prisma-ai/Sworm.git", .upToNextMajor(from: "1.1.0")
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
            dependencies: buildTargetDependencies {
                "PZBaseKit"
                Target.Dependency.product(
                    name: "Sworm",
                    package: "Sworm"
                )
            },
            resources: buildResources {
                Resource.process("Resources/")
            },
            swiftSettings: sharedSwiftSettings
        )

        // MARK: - Test Targets

        Target.testTarget(
            name: "PZAccountKitTests",
            dependencies: ["PZAccountKit"]
        )
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
    @ArrayBuilder<Resource?> resources: () -> [Resource?]
)
    -> [Resource] {
    resources().compactMap { $0 }
}

func buildPackageDependencies(
    @ArrayBuilder<Package.Dependency?> dependencies: () -> [Package.Dependency?]
)
    -> [Package.Dependency] {
    dependencies().compactMap { $0 }
}
