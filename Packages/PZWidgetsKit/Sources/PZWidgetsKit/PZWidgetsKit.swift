// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - PZWidgetsSPM

@available(iOS 17.0, macCatalyst 17.0, *)
public struct PZWidgetsSPM: AppIntentsPackage {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static func getAllProfiles(sortByGame: Bool = false) -> [PZProfileSendable] {
        Defaults[.pzProfiles].values.sorted {
            if sortByGame {
                return $0.game.caseIndex < $1.game.caseIndex && $0.priority < $1.priority
            }
            return $0.priority < $1.priority
        }
    }
}
