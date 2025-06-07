// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WallpaperKit

@available(watchOS, unavailable)
extension WidgetViewConfig {
    public init(_ intent: some SelectProfileIntentProtocol, _ noticeMessage: String?) {
        self = .defaultConfig // 作为拓展 constructor 使用时，此行必需。
        self.showTransformer = intent.showTransformer
        self.trounceBlossomDisplayMethod = intent.trounceBlossomDisplayMethod.realValue
        self.echoOfWarDisplayMethod = intent.echoOfWarDisplayMethod.realValue
        self.randomBackground = intent.randomBackground
        var backgroundsGiven = intent.chosenBackgrounds.filter {
            Set(BackgroundOptions.allOptions.map(\.0)).contains($0.id)
        }
        if backgroundsGiven.isEmpty {
            backgroundsGiven = [.defaultBackground]
        }
        self.selectedBackgrounds = backgroundsGiven.asRawEntitySet
        self.isDarkModeRespected = intent.isDarkModeRespected
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget
        self.showStaminaOnly = intent.showStaminaOnly
        self.useTinyGlassDisplayStyle = intent.useTinyGlassDisplayStyle
        self.expeditionDisplayPolicy = intent.expeditionDisplayPolicy.realValue
    }

    public var background: WidgetBackgroundAppEntity {
        guard !randomBackground else {
            return .randomElementOrNamecardBackground
        }
        if selectedBackgrounds.isEmpty {
            return .defaultBackground
        } else {
            return selectedBackgrounds.randomElement()?.asAppEntity ?? .defaultBackground
        }
    }
}
