// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public enum GachaExchange {
    public enum ExportableFormat: String, Sendable, Identifiable, CaseIterable, Hashable {
        case asUIGFv4
        case asSRGFv1

        // MARK: Public

        public var id: String { rawValue }

        public var name: String {
            switch self {
            case .asUIGFv4: "UIGF-v4.0"
            case .asSRGFv1: "SRGF-v1.0"
            }
        }

        public var supportedGames: [Pizza.SupportedGame] {
            switch self {
            case .asUIGFv4: Pizza.SupportedGame.allCases
            case .asSRGFv1: [.starRail]
            }
        }
    }

    public enum ExportPackageMethod: Sendable, Identifiable, Hashable {
        case specifiedOwners([GachaProfileID])
        case singleOwner(GachaProfileID)
        case allOwners

        // MARK: Lifecycle

        public init(owners: [GachaProfileID]?) {
            guard let owners, let firstOwner = owners.first else {
                self = .allOwners
                return
            }
            self = switch owners.count {
            case 1: .singleOwner(firstOwner)
            case ...0: .allOwners
            default: .specifiedOwners(owners)
            }
        }

        // MARK: Public

        public var id: String {
            switch self {
            case .specifiedOwners: "specifiedOwners"
            case .singleOwner: "singleOwner"
            case .allOwners: "allOwners"
            }
        }

        public var localizedName: String {
            "gachaKit.exportPackageMethod.\(id)".i18nGachaKit
        }

        public func supportedExportableFormats(by game: Pizza.SupportedGame) -> [ExportableFormat] {
            switch (self, game) {
            case (.singleOwner, .starRail): ExportableFormat.allCases
            default: [.asUIGFv4]
            }
        }
    }

    public enum ImportableFormat: String, Sendable, Identifiable, CaseIterable, Hashable {
        case asUIGFv4
        case asSRGFv1
        case asGIGFJson
        case asGIGFExcel

        // MARK: Public

        public var id: String { rawValue }

        public var longName: String {
            switch self {
            case .asUIGFv4: "UIGF v4.0"
            case .asSRGFv1: "SRGF v1.0"
            case .asGIGFJson: "GIGF (UIGF v2.2 … v3.0, JSON)"
            case .asGIGFExcel: "GIGF (UIGF v2.0 … v2.2, Excel XLSX)"
            }
        }

        public var shortNameForPicker: String {
            switch self {
            case .asUIGFv4: "UIGF-v4.0"
            case .asSRGFv1: "SRGF-v1.0"
            case .asGIGFJson: "GIGF-JSON"
            case .asGIGFExcel: "GIGF-XLSX"
            }
        }

        public var supportedGames: [Pizza.SupportedGame] {
            switch self {
            case .asUIGFv4: Pizza.SupportedGame.allCases
            case .asSRGFv1: [.starRail]
            case .asGIGFExcel, .asGIGFJson: [.genshinImpact]
            }
        }

        public var isObsoletedFormat: Bool {
            switch self {
            case .asUIGFv4: false
            case .asSRGFv1: false
            case .asGIGFJson: true
            case .asGIGFExcel: true
            }
        }
    }
}
