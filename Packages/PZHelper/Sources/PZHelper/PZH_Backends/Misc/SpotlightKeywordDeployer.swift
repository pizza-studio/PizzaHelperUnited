// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreSpotlight
import Foundation
import PZBaseKit
import UniformTypeIdentifiers

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZHelper {
    static func setupSpotlightSearch() {
        #if os(iOS)
        let activity = NSUserActivity(activityType: sharedBundleIDHeader + ".search")
        activity.title = "ThePizzaHelper"
        activity.keywords = [
            "原神", "星穹铁道", "星穹鐵道", "絕區零", "绝区零",
            "Genshin", "HSR", "Star Rail", "ZZZ",
            "ゼンレスゾンゼロ", "スターレイル", "スタレ", "ゲンシン", "崩スタ", "ピザ",
        ]
        activity.isEligibleForSearch = true
        activity.isEligibleForPublicIndexing = true
        activity.becomeCurrent()

        // 添加 Core Spotlight 支持
        let searchableItemAttributeSet = CSSearchableItemAttributeSet(
            itemContentType: UTType.text.identifier
        )
        searchableItemAttributeSet.title = activity.title
        searchableItemAttributeSet.keywords = .init(activity.keywords)
        searchableItemAttributeSet.contentDescription = "Open The Pizza Helper"

        let searchableItem = CSSearchableItem(
            uniqueIdentifier: sharedBundleIDHeader,
            domainIdentifier: "ThePizzaHelper",
            attributeSet: searchableItemAttributeSet
        )
        CSSearchableIndex.default().indexSearchableItems([searchableItem]) { error in
            if let error = error {
                print("Failed to index item: \(error.localizedDescription)")
            } else {
                print("Item successfully indexed!")
            }
        }
        #else
        print("// setupSpotlightSearch() is skipped on macOS.")
        #endif
    }
}
