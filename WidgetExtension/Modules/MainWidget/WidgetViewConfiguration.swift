// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - WidgetViewConfiguration

@available(watchOS, unavailable)
struct WidgetViewConfiguration {
    // MARK: Lifecycle

    init(_ intent: SelectAccountIntent, _ noticeMessage: String?) {
        self.showAccountName = true
        self.showTransformer = intent.showTransformer
        self.trounceBlossomDisplayMethod = intent.trounceBlossomDisplayMethod
        self.echoOfWarDisplayMethod = intent.echoOfWarDisplayMethod
        self.randomBackground = intent.randomBackground
        let backgrounds = intent.chosenBackgrounds
        self.selectedBackgrounds = backgrounds.isEmpty ? [.defaultBackground] : backgrounds
        self.isDarkModeRespected = intent.isDarkModeRespected
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget
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
    }

    // MARK: Internal

    static let defaultConfig = Self()

    let showAccountName: Bool
    let showTransformer: Bool
    let trounceBlossomDisplayMethod: WeeklyBossesDisplayMethodAppEnum
    let echoOfWarDisplayMethod: WeeklyBossesDisplayMethodAppEnum
    var noticeMessage: String?

    let isDarkModeRespected: Bool

    let showMaterialsInLargeSizeWidget: Bool

    var randomBackground: Bool
    var selectedBackgrounds: [WidgetBackgroundAppEntity]

    var background: WidgetBackgroundAppEntity {
        guard !randomBackground else {
            return WidgetBackgroundAppEntity.randomElementOrNamecardBackground
        }
        if selectedBackgrounds.isEmpty {
            return .defaultBackground
        } else {
            return selectedBackgrounds.randomElement()!
        }
    }

    mutating func addMessage(_ msg: String) {
        noticeMessage = msg
    }
}

@available(watchOS, unavailable)
extension WidgetBackgroundAppEntity {
    var imageName: String? {
        if BackgroundOptions.namecards.contains(id) {
            return id
        } else { return nil }
    }

    var iconName: String? {
        switch id {
        case "game.elements.anemo":
            return "element_Anemo"
        case "game.elements.hydro":
            return "element_Hydro"
        case "game.elements.cryo":
            return "element_Cryo"
        case "game.elements.pyro":
            return "element_Pyro"
        case "game.elements.geo":
            return "element_Geo"
        case "game.elements.electro":
            return "element_Electro"
        case "game.elements.dendro":
            return "element_Dendro"
        case "game.elements.imago":
            return "element_Imago"
        case "game.elements.quanto":
            return "element_Quanto"
        case "game.elements.physico":
            return "element_Physico"
        default:
            return nil
        }
    }

    var colors: [Color] {
        switch id {
        case "app.background.purple":
            return [
                Color.purple,
                Color.purple.addBrightness(-0.15),
                Color.purple.addBrightness(-0.3),
            ]
        case "app.background.gold":
            return [
                Color.yellow,
                Color.yellow.addBrightness(-0.15),
                Color.yellow.addBrightness(-0.3),
            ]
        case "app.background.gray":
            return [
                Color.gray,
                Color.gray.addBrightness(-0.15),
                Color.gray.addBrightness(-0.3),
            ]
        case "app.background.green":
            return [
                Color.green,
                Color.green.addBrightness(-0.15),
                Color.green.addBrightness(-0.3),
            ]
        case "app.background.blue":
            return [
                Color.blue,
                Color.blue.addBrightness(-0.15),
                Color.blue.addBrightness(-0.3),
            ]
        case "app.background.red":
            return [
                Color.red,
                Color.red.addBrightness(-0.15),
                Color.red.addBrightness(-0.3),
            ]
        case "game.elements.anemo":
            return [
                Color.mint,
                Color.mint.addBrightness(-0.15),
                Color.mint.addBrightness(-0.3),
            ]
        case "game.elements.hydro":
            return [
                Color.blue,
                Color.blue.addBrightness(-0.15),
                Color.blue.addBrightness(-0.3),
            ]
        case "game.elements.cryo":
            return [
                Color.cyan,
                Color.cyan.addBrightness(-0.15),
                Color.cyan.addBrightness(-0.3),
            ]
        case "game.elements.pyro":
            return [
                Color.red,
                Color.red.addBrightness(-0.15),
                Color.red.addBrightness(-0.3),
            ]
        case "game.elements.geo":
            return [
                Color.orange,
                Color.orange.addBrightness(-0.15),
                Color.orange.addBrightness(-0.3),
            ]
        case "game.elements.electro":
            return [
                Color.purple,
                Color.purple.addBrightness(-0.15),
                Color.purple.addBrightness(-0.3),
            ]
        case "game.elements.dendro":
            return [
                Color.green,
                Color.green.addBrightness(-0.15),
                Color.green.addBrightness(-0.3),
            ]
        case "game.elements.quanto":
            return [
                Color.indigo,
                Color.indigo.addBrightness(-0.15),
                Color.indigo.addBrightness(-0.3),
            ]
        case "game.elements.imago":
            return [
                Color.yellow,
                Color.yellow.addBrightness(-0.15),
                Color.yellow.addBrightness(-0.3),
            ]
        case "game.elements.physico":
            return [
                Color.gray,
                Color.gray.addBrightness(-0.15),
                Color.gray.addBrightness(-0.3),
            ]
        case "app.background.intertwinedFate":
            return [
                Color("bgColor.intertwinedFate.1", bundle: .main),
                Color("bgColor.intertwinedFate.2", bundle: .main),
                Color("bgColor.intertwinedFate.3", bundle: .main),
            ]
        default:
            return []
        }
    }
}
