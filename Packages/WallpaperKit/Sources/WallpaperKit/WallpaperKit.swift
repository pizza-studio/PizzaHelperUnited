// The Swift Programming Language
// https://docs.swift.org/swift-book

import Defaults
import Foundation
import PZBaseKit

// MARK: - Wallpaper

public enum Wallpaper {
    public struct WallpaperAsset: Identifiable, Codable {
        // MARK: Lifecycle

        public init(
            game: Pizza.SupportedGame,
            id: String,
            localizedName: String,
            assetName: String,
            assetName4LiveActivity: String,
            bindedCharID: String?
        ) {
            self.game = game
            self.id = id
            self.localizedName = localizedName
            self.assetName = assetName
            self.assetName4LiveActivity = assetName4LiveActivity
            self.bindedCharID = bindedCharID
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: Wallpaper.WallpaperAsset.CodingKeys.self)
            self.game = try container.decode(Pizza.SupportedGame.self, forKey: .game)
            self.id = try container.decode(String.self, forKey: .id)
            self.assetName = try container.decode(String.self, forKey: .assetName)
            self.assetName4LiveActivity = try container.decode(String.self, forKey: .assetName4LiveActivity)
            self.bindedCharID = try container.decodeIfPresent(String.self, forKey: .bindedCharID)
            self.localizedName = try container.decodeIfPresent(String.self, forKey: .localizedName) ?? assetName
        }

        // MARK: Public

        public let game: Pizza.SupportedGame
        public let id: String
        public var localizedName: String
        public fileprivate(set) var assetName: String
        public fileprivate(set) var assetName4LiveActivity: String
        public let bindedCharID: String? // 原神专用

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case game
            case id
            case localizedName
            case assetName
            case assetName4LiveActivity
            case bindedCharID
        }
    }
}

// MARK: - Wallpaper.WallpaperAsset + _DefaultsSerializable

extension Wallpaper.WallpaperAsset: _DefaultsSerializable {}

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
extension Wallpaper.WallpaperAsset {
    fileprivate static func getBundledLangDB4HSR() -> [String: String] {
        let url = Bundle.module.url(forResource: "HSRWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }

    fileprivate static func getBundledLangDB4GI() -> [String: String] {
        let url = Bundle.module.url(forResource: "GIWallpapers_Lang", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }
}

extension Wallpaper {
    public static func defaultValue(for game: Pizza.SupportedGame) -> WallpaperAsset {
        let allCases = allCases(for: game)
        return switch game {
        case .genshinImpact: allCases.first { $0.id == "210042" }!
        case .starRail: allCases.first { $0.id == "221005" }!
        }
    }

    public static func allCases(for game: Pizza.SupportedGame) -> [WallpaperAsset] {
        switch game {
        case .genshinImpact: allCases4GI
        case .starRail: allCases4HSR
        }
    }

    public static let allCases4HSR: [WallpaperAsset] = {
        var results = [WallpaperAsset]()
        let db = WallpaperAsset.getBundledLangDB4HSR()
        db.forEach { key, value in
            results.append(
                WallpaperAsset(
                    game: .starRail,
                    id: key,
                    localizedName: value,
                    assetName: "WP\(key)",
                    assetName4LiveActivity: "LA_WP\(key)",
                    bindedCharID: nil
                )
            )
        }
        return results
    }()

    public static let allCases4GI: [WallpaperAsset] = {
        var results = [WallpaperAsset]()
        let url = Bundle.module.url(forResource: "GIWallpapers_Meta", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        var dbs = try! JSONDecoder().decode([WallpaperAsset].self, from: data)
        let langDB = WallpaperAsset.getBundledLangDB4GI()
        for i in 0 ..< dbs.count {
            let oldObj = dbs[i]
            dbs[i].assetName = "NC\(oldObj.id)"
            dbs[i].assetName4LiveActivity = "NC\(oldObj.id)"
            if let localized = langDB[dbs[i].id] {
                dbs[i].localizedName = localized
            }
        }
        return dbs
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
