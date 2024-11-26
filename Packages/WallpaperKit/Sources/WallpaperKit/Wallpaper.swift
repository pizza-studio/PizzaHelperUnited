// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZBaseKit

extension Defaults.Keys {
    // Background wallpapers for live activity view.
    public static let backgrounds4LiveActivity = Key<Set<Wallpaper>>(
        "backgrounds4LiveActivity",
        default: [Wallpaper.defaultValue(for: appGame)],
        suite: .baseSuite
    )
    // Background wallpaper for app view.
    public static let background4App = Key<Wallpaper>(
        "background4App",
        default: Wallpaper.defaultValue(for: appGame),
        suite: .baseSuite
    )
}

// MARK: - Wallpaper

public struct Wallpaper: Identifiable, AbleToCodeSendHash {
    public let game: Pizza.SupportedGame?
    public let id: String
    public let bindedCharID: String? // 原神专用

    public var assetName: String {
        switch game {
        case .genshinImpact: "NC\(id)"
        case .starRail: "WP\(id)"
        case .zenlessZone: "ZZ\(id)"
        case .none: "PZWP\(id)"
        }
    }

    public var assetName4LiveActivity: String {
        switch game {
        case .genshinImpact: "NC\(id)"
        case .starRail: "LA_WP\(id)"
        case .zenlessZone: "ZZ\(id)"
        case .none: "PZA\(id)"
        }
    }

    public var localizedName: String {
        switch game {
        case .genshinImpact: Self.bundledLangDB4GI[id] ?? "NC(\(id))"
        case .starRail: Self.bundledLangDB4HSR[id] ?? "WP(\(id))"
        case .zenlessZone: Self.bundledLangDB4ZZZ[id] ?? "ZZ\(id)"
        case .none: Self.bundledLangDB4PZ[id] ?? "PZA\(id)"
        }
    }

    public var localizedRealName: String {
        switch game {
        case .genshinImpact: Self.bundledLangDB4GIRealName[id] ?? localizedName
        case .starRail: Self.bundledLangDB4HSR[id] ?? localizedName
        case .zenlessZone: Self.bundledLangDB4ZZZ[id] ?? localizedName
        case .none: Self.bundledLangDB4PZ[id] ?? localizedName
        }
    }
}

// MARK: _DefaultsSerializable

extension Wallpaper: _DefaultsSerializable {}

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
extension Wallpaper {
    private static let bundledLangDB4PZ: [String: String] = {
        let url = Bundle.module.url(forResource: "PizzaWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4ZZZ: [String: String] = {
        let url = Bundle.module.url(forResource: "ZZZWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4HSR: [String: String] = {
        let url = Bundle.module.url(forResource: "HSRWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4GI: [String: String] = {
        let assetNameTag = "GIWallpapers_Lang"
        let url = Bundle.module.url(forResource: assetNameTag, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4GIRealName: [String: String] = {
        let assetNameTag = "GIWallpapers_Lang_RealName"
        let url = Bundle.module.url(forResource: assetNameTag, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()
}

extension Wallpaper {
    public static func defaultValue(for game: Pizza.SupportedGame? = nil) -> Self {
        switch game ?? appGame {
        case .genshinImpact: .init(game: .genshinImpact, id: "210042", bindedCharID: nil)
        case .starRail: .init(game: .genshinImpact, id: "221000", bindedCharID: nil)
        case .zenlessZone: .init(game: .genshinImpact, id: "990001", bindedCharID: nil)
        case .none: .init(game: .genshinImpact, id: "210042", bindedCharID: nil)
        }
    }

    public static func randomValue(for game: Pizza.SupportedGame?) -> Self {
        allCases(for: game).randomElement()!
    }

    public static func allCases(for game: Pizza.SupportedGame?) -> [Self] {
        switch game {
        case .genshinImpact: allCases4GI
        case .starRail: allCases4HSR
        case .zenlessZone: allCases4ZZZ
        case .none: allCases4PZ
        }
    }

    /// This will return fallbacked normal value instead if nothing is matched.
    public static func findNameCardForGenshinCharacter(charID: String) -> Self {
        assetCharMap4GI[charID]
            ?? assetCharMap4GI[charID.prefix(8).description]
            ?? Wallpaper.defaultValue(for: .genshinImpact)
    }

    public static var allCases: [Self] {
        switch appGame {
        case .genshinImpact: allCases4PZ + allCases4GI
        case .starRail: allCases4PZ + allCases4HSR
        case .zenlessZone: allCases4PZ + allCases4ZZZ
        case .none: allCases4PZ + allCases4HSR + allCases4ZZZ + allCases4GI
        }
    }

    public static let allCases4PZ: [Self] = {
        var results = [Self]()
        bundledLangDB4PZ.forEach { key, _ in
            results.append(
                Self(
                    game: .none,
                    id: key,
                    bindedCharID: nil
                )
            )
        }
        return results.sorted {
            $0.id < $1.id
        }
    }()

    public static let allCases4HSR: [Self] = {
        var results = [Self]()
        bundledLangDB4HSR.forEach { key, _ in
            results.append(
                Self(
                    game: .starRail,
                    id: key,
                    bindedCharID: nil
                )
            )
        }
        return results.sorted {
            $0.id < $1.id
        }
    }()

    public static let allCases4ZZZ: [Self] = {
        var results = [Self]()
        bundledLangDB4ZZZ.forEach { key, _ in
            results.append(
                Self(
                    game: .zenlessZone,
                    id: key,
                    bindedCharID: nil
                )
            )
        }
        return results.sorted {
            $0.id < $1.id
        }
    }()

    public static let allCases4GI: [Self] = {
        var results = [Self]()
        let url = Bundle.module.url(forResource: "GIWallpapers_Meta", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode([Self].self, from: data)
    }()

    private static let assetCharMap4GI: [String: Self] = {
        var result = [String: Self]()
        allCases4GI.forEach {
            guard let charID = $0.bindedCharID else { return }
            result[charID] = $0
        }
        return result
    }()
}

// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

extension Locale {
    /// 以下内容从 EnkaKit 继承而来。
    fileprivate static var langCodeForEnkaAPI: String {
        let languageCode = Locale.preferredLanguages.first
            ?? Bundle.module.preferredLocalizations.first
            ?? Bundle.main.preferredLocalizations.first
            ?? "en"
        switch languageCode.prefix(7).lowercased() {
        case "zh-hans": return "zh-cn"
        case "zh-hant": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(5).lowercased() {
        case "zh-cn": return "zh-cn"
        case "zh-tw": return "zh-tw"
        default: break
        }
        switch languageCode.prefix(2).lowercased() {
        case "ja", "jp": return "ja"
        case "ko", "kr": return "ko"
        default: break
        }
        let valid = allowedLangTags.contains(languageCode)
        return valid ? languageCode.prefix(2).description : "en"
    }

    /// 星穹铁道所支持的语言数量比原神略少，所以取两者之交集。
    /// 以下内容从 EnkaKit 继承而来。
    fileprivate static let allowedLangTags: [String] = [
        "en", "ru", "vi", "th", "pt", "ko",
        "ja", "id", "fr", "es", "de", "zh-tw", "zh-cn",
    ]
}
