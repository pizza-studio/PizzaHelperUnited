// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import WallpaperKit
import WidgetKit

// MARK: - PZWidgets

public enum PZWidgets {}

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZWidgets {
    @MainActor
    public static func startupTask() {
        if !Pizza.isAppStoreReleaseAsLatteHelper {
            // 不能再让小工具有权限存取 CoreData / SwiftData 了，已经炸了至少一万多起案例了。
            UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
        }
        // OS 27 起 WidgetKit 可能在 cold boot 時使用 stale 的 entity resolution 快取，
        // 導致 widget configuration 中的 AppEntity 無法正確解析。
        // 主動要求 reload 以確保 entity 能被重新 resolve。
        WidgetCenter.shared.reloadAllTimelines()
    }
}
