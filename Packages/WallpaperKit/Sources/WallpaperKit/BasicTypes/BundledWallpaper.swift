// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Foundation
import PZBaseKit
import SwiftUI

// MARK: - BundledWallpaper

public struct BundledWallpaper: Identifiable, AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(
        game: Pizza.SupportedGame?,
        id: String,
        bindedCharID: String?,
        officialFileNameStem: String? = nil
    ) {
        self.game = game
        self.id = id
        self.bindedCharID = bindedCharID
        self.officialFileNameStem = officialFileNameStem
    }

    // MARK: Public

    public let game: Pizza.SupportedGame?
    public let id: String
    public let bindedCharID: String? // 原神专用
    public let officialFileNameStem: String? // 原神專用

    public var assetName: String {
        switch game {
        case .genshinImpact: "NC\(id)"
        case .starRail: "WP\(id)"
        case .zenlessZone: "ZZ\(id)"
        case .none: "PZWP\(id)"
        }
    }

    public var onlineAssetURL: URL? {
        guard let officialFileNameStem else { return nil }
        return URL(string: "https://enka.network/ui/\(officialFileNameStem).jpg")
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

// MARK: Defaults.Serializable

extension BundledWallpaper: Defaults.Serializable {}

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
extension BundledWallpaper {
    private static let bundledLangDB4PZ: [String: String] = {
        let url = Bundle.currentSPM.url(forResource: "PizzaWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4ZZZ: [String: String] = {
        let url = Bundle.currentSPM.url(forResource: "ZZZWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4HSR: [String: String] = {
        let url = Bundle.currentSPM.url(forResource: "HSRWallpapers", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4GI: [String: String] = {
        let assetNameTag = "GIWallpapers_Lang"
        let url = Bundle.currentSPM.url(forResource: assetNameTag, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()

    private static let bundledLangDB4GIRealName: [String: String] = {
        let assetNameTag = "GIWallpapers_Lang_RealName"
        let url = Bundle.currentSPM.url(forResource: assetNameTag, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dbs = try! JSONDecoder().decode([String: [String: String]].self, from: data)
        return dbs[Locale.langCodeForEnkaAPI] ?? dbs["en"]!
    }()
}

extension BundledWallpaper {
    public static func defaultValue(for game: Pizza.SupportedGame? = nil) -> Self {
        switch game ?? appGame {
        case .genshinImpact: .init(game: .genshinImpact, id: "210042", bindedCharID: "10000031_203101")
        case .starRail: .init(game: .genshinImpact, id: "221000", bindedCharID: nil)
        case .zenlessZone: .init(game: .genshinImpact, id: "990001", bindedCharID: nil)
        case .none: .init(game: .genshinImpact, id: "210042", bindedCharID: "10000031_203101")
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
            ?? BundledWallpaper.defaultValue(for: .genshinImpact)
    }

    /// This will return nullable value.
    public static func findNullableNameCardForGenshinCharacter(charID: String) -> Self? {
        assetCharMap4GI[charID]
            ?? assetCharMap4GI[charID.prefix(8).description]
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
        let url = Bundle.currentSPM.url(forResource: "GIWallpapers_Meta", withExtension: "json")!
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
        let languageCode =
            Locale.preferredLanguages.first
                ?? Bundle.currentSPM.preferredLocalizations.first
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

@available(iOS 16.2, macCatalyst 16.2, *)
extension BundledWallpaper {
    public func saveOnlineBackgroundAsset(skip: Bool = false) async {
        await BackgroundSavingActor.shared.saveOnlineBackgroundAsset(
            for: self, skip: skip
        )
    }
}

// MARK: - BackgroundSavingActor

@available(iOS 16.2, macCatalyst 16.2, *)
private actor BackgroundSavingActor {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let shared = BackgroundSavingActor()

    public func saveOnlineBackgroundAsset(
        for bundledWP: BundledWallpaper, skip: Bool = false
    ) async {
        guard !skip, let url = bundledWP.onlineAssetURL else { return }
        guard await ImageMap.shared.assetMap[url] == nil else { return }
        let data: Data = (try? await AF.request(url).serializingData().value) ?? .init([])
        guard let cgImage = CGImage.instantiate(data: data) else { return }
        let imagePtr = SendableImagePtr(img: Image(decorative: cgImage, scale: 1))
        await ImageMap.shared.insertValue(url: url, image: imagePtr)
    }
}
