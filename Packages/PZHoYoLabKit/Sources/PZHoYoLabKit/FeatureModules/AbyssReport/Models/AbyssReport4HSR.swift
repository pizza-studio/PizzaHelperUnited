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
