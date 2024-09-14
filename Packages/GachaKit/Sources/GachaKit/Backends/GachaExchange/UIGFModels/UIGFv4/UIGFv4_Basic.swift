// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - UIGFv4

// 穹披助手对 UIGF 仅从 v4 开始支援，因为之前版本的 UIGF 仅支援原神。
// Ref: https://uigf.org/zh/standards/uigf.html

public struct UIGFv4: Codable, Hashable, Sendable {
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

extension UIGFv4 {
    static func makeDecodingError(_ key: CodingKey) -> Error {
        let keyName = key.description
        var msg = "\(keyName) value is invalid or empty. "
        msg += "// \(keyName) 不得是空值或不可用值。 "
        msg += "// \(keyName) は必ず有効な値しか処理できません。"
        return DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: msg))
    }
}

extension UIGFv4 {
    public init(info: Info, entries: [PZGachaEntryMO]) throws {
        self.info = info
        self.giProfiles = try entries.extractProfiles(GachaItemGI.self, lang: .current)
        self.hsrProfiles = try entries.extractProfiles(GachaItemHSR.self, lang: .current)
        self.zzzProfiles = try entries.extractProfiles(GachaItemZZZ.self, lang: .current)
    }
}

// MARK: UIGFv4.Info

extension UIGFv4 {
    public struct Info: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(exportApp: String, exportAppVersion: String, exportTimestamp: String, version: String) {
            self.exportApp = exportApp
            self.exportAppVersion = exportAppVersion
            self.exportTimestamp = exportTimestamp
            self.version = version
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
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case exportApp = "export_app"
            case exportAppVersion = "export_app_version"
            case exportTimestamp = "export_timestamp"
            case version
        }

        /// 导出档案的 App 名称
        public let exportApp: String
        /// 导出档案的 App 版本
        public let exportAppVersion: String
        /// 导出档案的时间戳，秒级
        public let exportTimestamp: String
        /// 导出档案的 UIGF 版本号，格式为 'v{major}.{minor}'，如 v4.0
        public let version: String
    }
}

// MARK: - Extensions

extension UIGFv4 {
    public enum SupportedHoYoGames: String {
        case genshinImpact = "GI"
        case starRail = "HSR"
        case zenlessZoneZero = "ZZZ"
    }

    public init() {
        self.info = .init()
        self.giProfiles = []
        self.hsrProfiles = []
        self.zzzProfiles = []
    }

    public var defaultFileNameStem: String {
        let dateFormatter = DateFormatter.forUIGFFileName
        return "\(Self.initials)\(dateFormatter.string(from: info.maybeDateExported ?? Date()))"
    }

    private static let initials = "UIGFv4_"

    public func getFileNameStem(
        uid: String? = nil,
        for game: SupportedHoYoGames? = .starRail
    )
        -> String {
        var stack = Self.initials
        if let game { stack += "\(game.rawValue)_" }
        if let uid { stack += "\(uid)_" }
        return defaultFileNameStem.replacingOccurrences(of: Self.initials, with: stack)
    }
}

extension UIGFv4.Info {
    // MARK: Lifecycle

    public init() {
        self.exportApp = "PizzaHelper4HSR"
        let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.exportAppVersion = shortVer ?? "1.14.514"
        self.exportTimestamp = Int(Date.now.timeIntervalSince1970).description
        self.version = "v4.0"
    }

    public var maybeDateExported: Date? {
        guard let exportTimestamp = Double(exportTimestamp) else { return nil }
        return .init(timeIntervalSince1970: Double(exportTimestamp))
    }
}
