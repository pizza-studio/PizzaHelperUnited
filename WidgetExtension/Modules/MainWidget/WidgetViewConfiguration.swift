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
        self.prioritizeExpeditionDisplay = intent.prioritizeExpeditionDisplay
        self.showStaminaOnly = intent.showStaminaOnly
        self.useTinyGlassDisplayStyle = intent.useTinyGlassDisplayStyle
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
        self.prioritizeExpeditionDisplay = false
        self.showStaminaOnly = false
        self.useTinyGlassDisplayStyle = false
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
        self.prioritizeExpeditionDisplay = false
        self.showStaminaOnly = false
        self.useTinyGlassDisplayStyle = false
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
    var prioritizeExpeditionDisplay: Bool
    var randomBackground: Bool
    var selectedBackgrounds: [WidgetBackgroundAppEntity]

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

@available(watchOS, unavailable)
extension WidgetBackgroundAppEntity {
    var userSuppliedWallpaper: UserWallpaper? {
        let uuid = UUID(uuidString: id)
        guard uuid != nil else { return nil }
        return .init(defaultsValueID: id)
    }

    var imageName: String? {
        if BackgroundOptions.allStaticGalleryWallpaperOptions.map(\.0).contains(id) {
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
                PZWidgetsSPM.Colors.Background.IntertwinedFate.color1.suiColor,
                PZWidgetsSPM.Colors.Background.IntertwinedFate.color2.suiColor,
                PZWidgetsSPM.Colors.Background.IntertwinedFate.color3.suiColor,
            ]
        default:
            return []
        }
    }
}
