// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYo.AbyssReport4HSR

extension HoYo {
    public struct AbyssReport4HSR: AbyssReport {
        // MARK: Lifecycle

        public init(
            forgottenHall: ForgottenHallData,
            pureFiction: PureFictionData,
            apocalypticShadow: ApocalypticShadowData
        ) {
            self.forgottenHall = forgottenHall
            self.pureFiction = pureFiction
            self.apocalypticShadow = apocalypticShadow
        }

        // MARK: Public

        public typealias ViewType = AbyssReportView4HSR

        public var forgottenHall: ForgottenHallData
        public let pureFiction: PureFictionData
        public let apocalypticShadow: ApocalypticShadowData
    }
}

// MARK: - HoYo.AbyssReport4HSR.TreasuresLightwardType

extension HoYo.AbyssReport4HSR {
    public enum TreasuresLightwardType: String, Identifiable, CaseIterable {
        case forgottenHall
        case pureFiction
        case apocalypticShadow

        // MARK: Public

        public var id: String { rawValue }

        public var localizedTitle: String {
            .init(localized: localizedStringKey, bundle: .module)
        }

        // MARK: Internal

        var localizedStringKey: String.LocalizationValue {
            switch self {
            case .forgottenHall:
                .init("hylKit.abyssReportView4HSR.navTitle.forgottenHall")
            case .pureFiction:
                .init("hylKit.abyssReportView4HSR.navTitle.pureFiction")
            case .apocalypticShadow:
                .init("hylKit.abyssReportView4HSR.navTitle.apocalypticShadow")
            }
        }

        var iconFileNameStem: String {
            switch self {
            case .forgottenHall: "hsr_abyss_ForgottenHall"
            case .pureFiction: "hsr_abyss_PureFiction"
            case .apocalypticShadow: "hsr_abyss_ApocalypticShadow"
            }
        }
    }
}
