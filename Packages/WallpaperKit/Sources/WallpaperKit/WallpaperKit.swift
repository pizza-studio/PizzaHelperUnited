// The Swift Programming Language
// https://docs.swift.org/swift-book

import Defaults
import Foundation
import PZBaseKit

// MARK: - Wallpaper

public enum Wallpaper {
    public struct WallpaperAsset: Identifiable, Codable {
        public let game: Pizza.SupportedGame
        public let id: String
        public let localizedName: String
        public let assetName: String
        public let assetName4LiveActivity: String
        public let bindedCharID: String? // 原神专用
    }
}

// MARK: - Wallpaper.WallpaperAsset + _DefaultsSerializable

extension Wallpaper.WallpaperAsset: _DefaultsSerializable {}

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
extension Wallpaper.WallpaperAsset {
    fileprivate static func getBundledDB4HSR() -> [String: String] {
        let url = Bundle.module.url(forResource: "HSRWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }
}

extension Wallpaper {
    public static let allCases4HSR: [WallpaperAsset] = {
        var results = [WallpaperAsset]()
        let db = WallpaperAsset.getBundledDB4HSR()
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
