// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WallpaperKit

// MARK: - WidgetViewConfiguration

@available(watchOS, unavailable)
struct WidgetViewConfiguration {
    // MARK: Lifecycle

    init(_ intent: some SelectProfileIntentProtocol, _ noticeMessage: String?) {
        self.showAccountName = true
        self.showTransformer = intent.showTransformer
        self.trounceBlossomDisplayMethod = intent.trounceBlossomDisplayMethod
        self.echoOfWarDisplayMethod = intent.echoOfWarDisplayMethod
        self.randomBackground = intent.randomBackground
        let backgrounds = intent.chosenBackgrounds.filter {
            Set(BackgroundOptions.allOptions.map(\.0)).contains($0.id)
        }
        self.selectedBackgrounds = backgrounds.isEmpty ? [.defaultBackground] : backgrounds
        self.isDarkModeRespected = intent.isDarkModeRespected
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget
        self.showStaminaOnly = intent.showStaminaOnly
        self.useTinyGlassDisplayStyle = intent.useTinyGlassDisplayStyle
        self.expeditionDisplayPolicy = intent.expeditionDisplayPolicy
    }

    init(noticeMessage: String? = nil) {
        self.showAccountName = true
        self.showTransformer = true
        self.trounceBlossomDisplayMethod = .disappearAfterCompleted
        self.echoOfWarDisplayMethod = .disappearAfterCompleted
        self.selectedBackgrounds = [.defaultBackground]
        self.randomBackground = false
        self.isDarkModeRespected = true
        self.showMaterialsInLargeSizeWidget = true
        self.noticeMessage = noticeMessage
        self.showStaminaOnly = false
        self.useTinyGlassDisplayStyle = false
        self.expeditionDisplayPolicy = .displayWhenAvailable
    }

    init(
        showAccountName: Bool,
        showTransformer: Bool,
        showExpeditionCompleteTime: Bool,
        showWeeklyBosses: Bool,
        noticeMessage: String?
    ) {
        self.showAccountName = showAccountName
        self.showTransformer = showTransformer
        self.trounceBlossomDisplayMethod = .disappearAfterCompleted
        self.echoOfWarDisplayMethod = .disappearAfterCompleted
        self.randomBackground = false
        self.selectedBackgrounds = [.defaultBackground]
        self.isDarkModeRespected = true
        self.showMaterialsInLargeSizeWidget = true
        self.showStaminaOnly = false
        self.useTinyGlassDisplayStyle = false
        self.expeditionDisplayPolicy = .displayWhenAvailable
    }

    // MARK: Internal

    static let defaultConfig = Self()

    var showAccountName: Bool
    var showTransformer: Bool
    var trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum
    var echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum
    var noticeMessage: String?
    var isDarkModeRespected: Bool
    var showStaminaOnly: Bool
    var useTinyGlassDisplayStyle: Bool
    var showMaterialsInLargeSizeWidget: Bool
    var randomBackground: Bool
    var expeditionDisplayPolicy: ExpeditionDisplayPolicyAppEnum
    var selectedBackgrounds: [WidgetBackgroundAppEntity]

    var neverDisplayExpeditionList: Bool { expeditionDisplayPolicy == .neverDisplay }

    var background: WidgetBackgroundAppEntity {
        guard !randomBackground else {
            return WidgetBackgroundAppEntity.randomElementOrNamecardBackground
        }
        if selectedBackgrounds.isEmpty {
            return .defaultBackground
        } else {
            return selectedBackgrounds.randomElement() ?? .defaultBackground
        }
    }

    mutating func addMessage(_ msg: String) {
        noticeMessage = msg
    }
}
