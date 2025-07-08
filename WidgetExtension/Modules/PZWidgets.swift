// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZWidgetsKit
import WallpaperKit

// MARK: - PZWidgets

public enum PZWidgets {}

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZWidgets {
    @MainActor
    public static func startupTask() {
        Task {
            await PZProfileActor.shared.tryAutoInheritOldLocalAccounts(resetNotifications: true)
        }
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }

    public static func getAllProfiles(sortByGame: Bool = false) -> [PZProfileSendable] {
        Defaults[.pzProfiles].values.sorted {
            if sortByGame {
                return $0.game.caseIndex < $1.game.caseIndex && $0.priority < $1.priority
            }
            return $0.priority < $1.priority
        }
    }
}
