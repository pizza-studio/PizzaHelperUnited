// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WallpaperKit

@available(iOS 17.0, macCatalyst 17.0, *)
extension WidgetViewConfig {
    public init(_ intent: some ProfileWidgetIntentProtocol, _ noticeMessage: String?) {
        self = .defaultConfig // 作为拓展 constructor 使用时，此行必需。
        self.showTransformer = intent.showTransformer
        self.trounceBlossomDisplayMethod = intent.trounceBlossomDisplayMethod.realValue
        self.echoOfWarDisplayMethod = intent.echoOfWarDisplayMethod.realValue
        self.randomBackground = intent.randomBackground
        let allBackgroundOptionIDs = Set(WidgetBackground.allOptions.map(\.id))
        var backgroundsGiven = intent.chosenBackgrounds.filter {
            allBackgroundOptionIDs.contains($0.id)
        }.map(\.asRawEntity)
        if backgroundsGiven.isEmpty {
            backgroundsGiven = [WidgetBackground.defaultBackground]
        }
        self.selectedBackgrounds = Set(backgroundsGiven)
        self.isDarkModeRespected = intent.isDarkModeRespected
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget
        self.showStaminaOnly = intent.showStaminaOnly
        self.useTinyGlassDisplayStyle = intent.useTinyGlassDisplayStyle
        self.expeditionDisplayPolicy = intent.expeditionDisplayPolicy.realValue
    }
}
