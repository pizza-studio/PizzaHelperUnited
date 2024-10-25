// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZIntentKit
import SwiftUI
import WallpaperKit

typealias WidgetBackground = WidgetBackgroundAppEntity
typealias ExpeditionShowingMethod = ExpeditionShowingMethodAppEnum

extension WidgetBackgroundAppEntity {}

// MARK: - WidgetViewConfiguration

struct WidgetViewConfiguration {
    // MARK: Lifecycle

    init(_ intent: SelectAccountIntent, _ noticeMessage: String?) {
        self.showAccountName = true
        self.showTransformer = intent.showTransformer ?? true
        self.weeklyBossesShowingMethod = intent.weeklyBossesShowingMethod ?? .disappearAfterCompleted
        self.randomBackground = intent.randomBackground ?? false
        if let backgrounds = intent.background {
            self.selectedBackgrounds = backgrounds.isEmpty ? [.defaultBackground] : backgrounds
        } else {
            self.selectedBackgrounds = [.defaultBackground]
        }
        self.isDarkModeOn = intent.isDarkModeOn ?? true
        self.showMaterialsInLargeSizeWidget = intent.showMaterialsInLargeSizeWidget ?? true
    }

    init(noticeMessage: String? = nil) {
        self.showAccountName = true
        self.showTransformer = true
        self.weeklyBossesShowingMethod = .disappearAfterCompleted
        self.selectedBackgrounds = [.defaultBackground]
        self.randomBackground = false
        self.isDarkModeOn = true
        self.showMaterialsInLargeSizeWidget = true
        self.noticeMessage = noticeMessage
    }

    init(
        showAccountName: Bool,
        showTransformer: Bool,
        noticeExpeditionWhenAllCompleted: Bool,
        showExpeditionCompleteTime: Bool,
        showWeeklyBosses: Bool,
        noticeMessage: String?
    ) {
        self.showAccountName = showAccountName
        self.showTransformer = showTransformer
        self.weeklyBossesShowingMethod = .disappearAfterCompleted
        self.randomBackground = false
        self.selectedBackgrounds = [.defaultBackground]
        self.isDarkModeOn = true
        self.showMaterialsInLargeSizeWidget = true
    }

    // MARK: Internal

    static let defaultConfig = Self()

    let showAccountName: Bool
    let showTransformer: Bool
    let weeklyBossesShowingMethod: WeeklyBossesShowingMethodAppEnum
    var noticeMessage: String?

    let isDarkModeOn: Bool

    let showMaterialsInLargeSizeWidget: Bool

    var randomBackground: Bool
    var selectedBackgrounds: [WidgetBackground]

    var background: WidgetBackground {
        guard !randomBackground else {
            return WidgetBackground.randomElementOrNamecardBackground
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

// MARK: - ExpeditionViewConfiguration

struct ExpeditionViewConfiguration {
    let noticeExpeditionWhenAllCompleted: Bool
    let expeditionShowingMethod: ExpeditionShowingMethod
}

extension WidgetBackground {
    var imageName: String? {
        if BackgroundOptions.namecards.contains(id) {
            return id
        } else { return nil }
    }

    var iconName: String? {
        switch id {
        case "game.elements.anemo":
            return "风元素图标"
        case "game.elements.hydro":
            return "水元素图标"
        case "game.elements.cryo":
            return "冰元素图标"
        case "game.elements.pyro":
            return "火元素图标"
        case "game.elements.geo":
            return "岩元素图标"
        case "game.elements.electro":
            return "雷元素图标"
        case "game.elements.dendro":
            return "草元素图标"
        default:
            return nil
        }
    }

    var colors: [Color] {
        switch id {
        case "app.background.purple":
            return [
                Color("bgColor.purple.1"),
                Color("bgColor.purple.2"),
                Color("bgColor.purple.3"),
            ]
        case "app.background.gold":
            return [
                Color("bgColor.yellow.1"),
                Color("bgColor.yellow.2"),
                Color("bgColor.yellow.3"),
            ]
        case "app.background.gray":
            return [
                Color("bgColor.gray.1"),
                Color("bgColor.gray.2"),
                Color("bgColor.gray.3"),
            ]
        case "app.background.green":
            return [
                Color("bgColor.green.1"),
                Color("bgColor.green.2"),
                Color("bgColor.green.3"),
            ]
        case "app.background.blue":
            return [
                Color("bgColor.blue.1"),
                Color("bgColor.blue.2"),
                Color("bgColor.blue.3"),
            ]
        case "app.background.red":
            return [
                Color("bgColor.red.1"),
                Color("bgColor.red.2"),
                Color("bgColor.red.3"),
            ]

        case "game.elements.anemo":
            return [
                Color("bgColor.wind.1"),
                Color("bgColor.wind.2"),
                Color("bgColor.wind.3"),
            ]
        case "game.elements.hydro":
            return [
                Color("bgColor.water.1"),
                Color("bgColor.water.2"),
                Color("bgColor.water.3"),
            ]
        case "game.elements.cryo":
            return [
                Color("bgColor.ice.1"),
                Color("bgColor.ice.2"),
                Color("bgColor.ice.3"),
            ]
        case "game.elements.pyro":
            return [
                Color("bgColor.fire.1"),
                Color("bgColor.fire.2"),
                Color("bgColor.fire.3"),
            ]
        case "game.elements.geo":
            return [
                Color("bgColor.stone.1"),
                Color("bgColor.stone.2"),
                Color("bgColor.stone.3"),
            ]
        case "game.elements.electro":
            return [
                Color("bgColor.thunder.1"),
                Color("bgColor.thunder.2"),
                Color("bgColor.thunder.3"),
            ]
        case "game.elements.dendro":
            return [
                Color("bgColor.glass.1"),
                Color("bgColor.glass.2"),
                Color("bgColor.glass.3"),
            ]
        case "app.background.intertwinedFate":
            return [
                Color("bgColor.intertwinedFate.1"),
                Color("bgColor.intertwinedFate.2"),
                Color("bgColor.intertwinedFate.3"),
            ]
        default:
            return []
        }
    }
}
