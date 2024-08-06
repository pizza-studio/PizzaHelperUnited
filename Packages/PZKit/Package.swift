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
        "-warn-long-function-bodies=200",
        "-Xfrontend",
        "-warn-long-expression-type-checking=200",
    ]),
    .enableExperimentalFeature("AccessLevelOnImport"),
]

let package = Package(
    name: "PizzaKit",
    platforms: [.iOS(.v17), .macOS(.v14), .watchOS(.v10)],
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
    },
    dependencies: buildPackageDependencies {
        Package.Dependency.package(
            url: "https://github.com/sindresorhus/Defaults",
            from: "8.2.0"
        )
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        Package.Dependency.package(
            url: "https://github.com/pizza-studio/GachaMetaGenerator",
            from: "2.1.2"
        )
        Package.Dependency.package(
            url: "https://github.com/pizza-studio/EnkaDBGenerator",
            from: "1.2.2"
        )
        #endif
    },
    targets: buildTargets {
        // MARK: - Common Targets

        Target.target(
            name: "PZBaseKit",
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "PZAccountKit",
            dependencies: ["PZBaseKit"],
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "OSImpl",
            dependencies: ["PZBaseKit"],
            sources: makeSourceList("OSImpl", .separatedOSesAndShared),
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "PZKitBackend",
            dependencies: buildTargetDependencies {
                "PZBaseKit"
                "PZAccountKit"
                "OSImpl"
                #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
                "EnkaKit"
                "GachaKit"
                #endif
            },
            sources: makeSourceList("PZKitBackend", .separatedOSesAndShared),
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "PZKitFrontend",
            dependencies: ["PZBaseKit", "PZAccountKit", "OSImpl", "PZKitBackend"],
            sources: makeSourceList("PZKitFrontend", .separatedOSesAndShared),
            swiftSettings: sharedSwiftSettings
        )

        // MARK: - Non-Watch Targets

        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
        Target.target(
            name: "EnkaKit",
            dependencies: buildTargetDependencies {
                Target.Dependency.product(name: "EnkaDBFiles", package: "EnkaDBGenerator")
                Target.Dependency.product(name: "EnkaDBModels", package: "EnkaDBGenerator")
            },
            swiftSettings: sharedSwiftSettings
        )
        Target.target(
            name: "GachaKit",
            dependencies: buildTargetDependencies {
                Target.Dependency.product(name: "GachaMetaDB", package: "GachaMetaGenerator")
            },
            swiftSettings: sharedSwiftSettings
        )
        #endif

        // MARK: - Test Targets

        Target.testTarget(
            name: "PizzaKitFrontendTests",
            dependencies: ["PZKitFrontend", "OSImpl"]
        )
    }
)

// MARK: - Utils

func makeSourceList(_ target: String, _ folderSetting: SourceFolderSetting = .singleOne) -> [String] {
    switch folderSetting {
    case .singleOne: return [target]
    case .separateOSes:
        var result = [String]()
        #if os(iOS) || targetEnvironment(macCatalyst)
        result.append("\(target)-NonWatch")
        #elseif os(watchOS)
        result.append("\(target)-Watch")
        #elseif os(macOS)
        result.append("\(target)-macOS")
        #endif
        return result
    case .separatedOSesAndShared:
        var result = ["\(target)-Shared"]
        #if os(iOS) || targetEnvironment(macCatalyst)
        result.append("\(target)-NonWatch")
        #elseif os(watchOS)
        result.append("\(target)-Watch")
        #elseif os(macOS)
        result.append("\(target)-macOS")
        #endif
        return result
    }
}

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

func buildPackageDependencies(
    @ArrayBuilder<Package.Dependency?> dependencies: () -> [Package.Dependency?]
)
    -> [Package.Dependency] {
    dependencies().compactMap { $0 }
}
