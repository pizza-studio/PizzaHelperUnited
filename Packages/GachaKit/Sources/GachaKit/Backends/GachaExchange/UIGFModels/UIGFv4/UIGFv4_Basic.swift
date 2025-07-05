// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - UIGFv4

// 穹披助手对 UIGF 仅从 v4 开始支援，因为之前版本的 UIGF 仅支援原神。
// Ref: https://uigf.org/zh/standards/uigf.html

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public struct UIGFv4: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(
        info: Info,
        giProfiles: [ProfileGI]? = [],
        hsrProfiles: [ProfileHSR]? = [],
        zzzProfiles: [ProfileZZZ]? = []
    ) {
        self.info = info
        self.giProfiles = giProfiles
        self.hsrProfiles = hsrProfiles
        self.zzzProfiles = zzzProfiles
    }

    // MARK: Public

    public enum CodingKeys: String, CodingKey {
        case giProfiles = "hk4e"
        case hsrProfiles = "hkrpg"
        case zzzProfiles = "nap"
        case info
    }

    public var giProfiles: [ProfileGI]?
    public var hsrProfiles: [ProfileHSR]?
    public var info: Info
    public var zzzProfiles: [ProfileZZZ]?
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4 {
    static func makeDecodingError(_ key: CodingKey) -> Error {
        let keyName = key.description
        var msg = "\(keyName) value is invalid or empty. "
        msg += "// \(keyName) 不得是空值或不可用值。 "
        msg += "// \(keyName) は必ず有効な値しか処理できません。"
        return DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: msg))
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // 此处用 if let 免得生成的 JSON 出现空阵列。
        if let giProfiles { try container.encode(giProfiles, forKey: .giProfiles) }
        if let hsrProfiles { try container.encode(hsrProfiles, forKey: .hsrProfiles) }
        if let zzzProfiles { try container.encode(zzzProfiles, forKey: .zzzProfiles) }
        try container.encode(info, forKey: .info)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4 {
    public init(
        info: Info,
        entries: [any PZGachaEntryProtocol],
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws {
        self.info = info
        self.giProfiles = try entries.extractProfiles(GachaItemGI.self, lang: lang)
        self.hsrProfiles = try entries.extractProfiles(GachaItemHSR.self, lang: lang)
        self.zzzProfiles = try entries.extractProfiles(GachaItemZZZ.self, lang: lang)
    }
}

// MARK: UIGFv4.Info

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4 {
    public struct Info: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            exportApp: String,
            exportAppVersion: String,
            exportTimestamp: String,
            version: String = "v4.0",
            previousFormat: String? = nil
        ) {
            self.exportApp = exportApp
            self.exportAppVersion = exportAppVersion
            self.exportTimestamp = exportTimestamp
            self.version = version
            self.previousFormat = previousFormat ?? "UIGF v4.0"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.exportApp = try container.decode(String.self, forKey: .exportApp)
            self.exportAppVersion = try container.decode(String.self, forKey: .exportAppVersion)
            self.version = try container.decode(String.self, forKey: .version)
            if let x = try? container.decode(String.self, forKey: .exportTimestamp) {
                self.exportTimestamp = x
            } else if let x = try? container.decode(Int.self, forKey: .exportTimestamp) {
                self.exportTimestamp = x.description
            } else if let x = try? container.decode(Double.self, forKey: .exportTimestamp) {
                self.exportTimestamp = x.description
            } else {
                self.exportTimestamp = "YJSNPI" // 摆烂值，反正这里不解析。
            }
            self.previousFormat = try container.decodeIfPresent(
                String.self, forKey: .previousFormat
            ) ?? "UIGF v4.0"
        }

        // MARK: Public

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
        public enum CodingKeys: String, CodingKey {
            case exportApp = "export_app"
            case exportAppVersion = "export_app_version"
            case exportTimestamp = "export_timestamp"
            case version
            case previousFormat = "previous_format"
        }

        /// 导出档案的 App 名称
        public let exportApp: String
        /// 导出档案的 App 版本
        public let exportAppVersion: String
        /// 导出档案的时间戳，秒级
        public let exportTimestamp: String
        /// 导出档案的 UIGF 版本号，格式为 'v{major}.{minor}'，如 v4.0
        public let version: String
        /// 从哪个旧版升级过来的？
        public let previousFormat: String
    }
}

// MARK: - Extensions

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4 {
    public init() {
        self.info = .init()
        self.giProfiles = []
        self.hsrProfiles = []
        self.zzzProfiles = []
    }

    public var defaultFileNameStem: String {
        if let singleGPID = gpidIfContainingOnlyOneSingleProfile {
            return getFileNameStem(uid: singleGPID.uid, for: singleGPID.game)
        }
        return fallbackFileNameStem
    }

    public var fallbackFileNameStem: String {
        let dateFormatter = DateFormatter.forUIGFFileName
        return "\(Self.initials)\(dateFormatter.string(from: info.maybeDateExported ?? Date()))"
    }

    public var gpidIfContainingOnlyOneSingleProfile: GachaProfileID? {
        var ids = Set<GachaProfileID>()
        giProfiles?.forEach { ids.insert($0.gachaProfileID) }
        hsrProfiles?.forEach { ids.insert($0.gachaProfileID) }
        zzzProfiles?.forEach { ids.insert($0.gachaProfileID) }
        guard ids.count == 1, let first = ids.randomElement() else { return nil }
        return first
    }

    private static let initials = "UIGFv4_"

    public func getFileNameStem(
        uid: String? = nil,
        for game: Pizza.SupportedGame? = .starRail
    )
        -> String {
        var stack = Self.initials
        if let game { stack += "\(game.rawValue)_" }
        if let uid { stack += "\(uid)_" }
        return fallbackFileNameStem.replacingOccurrences(of: Self.initials, with: stack)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4.Info {
    // MARK: Lifecycle

    public init() {
        self.exportApp = "UnitedPizzaHelper"
        let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.exportAppVersion = shortVer ?? "1.14.514"
        self.exportTimestamp = Int(Date.now.timeIntervalSince1970).description
        self.version = "v4.0"
        self.previousFormat = "UIGF v4.0"
    }

    public var maybeDateExported: Date? {
        guard let exportTimestamp = Double(exportTimestamp) else { return nil }
        return .init(timeIntervalSince1970: Double(exportTimestamp))
    }
}
