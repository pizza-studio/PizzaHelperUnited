// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
// @_exported import PZIntentKit
import SwiftUI
import WallpaperKit

// MARK: - BackgroundOptions

enum BackgroundOptions {
    static let colors: [String] = [
        "app.background.gray",
        "app.background.green",
        "app.background.blue",
        "app.background.purple",
        "app.background.gold",
        "app.background.red",
        "game.elements.anemo",
        "game.elements.hydro",
        "game.elements.cryo",
        "game.elements.pyro",
        "game.elements.geo",
        "game.elements.electro",
        "game.elements.dendro",
        "app.background.intertwinedFate",
    ]
    static let elements: [String] = [
        "game.elements.anemo",
        "game.elements.hydro",
        "game.elements.cryo",
        "game.elements.pyro",
        "game.elements.geo",
        "game.elements.electro",
        "game.elements.dendro",
    ]
    static let namecards: [String] = Wallpaper.allCases.map(\.assetName4LiveActivity)

    static let allOptions: [(String, String)] = (Self.colors + Self.elements).map { ($0, $0) } + Wallpaper.allCases
        .map(\.asBackgroundOption)

    static let elementsAndNamecard: [(String, String)] = Self.elements.map { ($0, $0) } + Wallpaper.allCases
        .map(\.asBackgroundOption)
}

extension WidgetBackgroundAppEntity {
    static let defaultBackground: Self = {
        Wallpaper.defaultValue(for: appGame).asWidgetBackgroundAppEntity
    }()

    static var randomBackground: Self {
        let pickedBackgroundId = BackgroundOptions.allOptions.randomElement()!
        return WidgetBackgroundAppEntity(
            id: pickedBackgroundId.0,
            displayString: pickedBackgroundId.1
        )
    }

    static var randomColorBackground: Self {
        let pickedBackgroundId = BackgroundOptions.colors.randomElement()!
        return WidgetBackgroundAppEntity(
            id: pickedBackgroundId,
            displayString: pickedBackgroundId
        )
    }

    static var randomNamecardBackground: Self {
        let pickedBackgroundId = Wallpaper.allCases.randomElement() ?? .defaultValue(for: appGame)
        return pickedBackgroundId.asWidgetBackgroundAppEntity
    }

    static func randomNamecardBackground4Game(_ game: Pizza.SupportedGame) -> Self {
        let pickedBackgroundId = Wallpaper.allCases(for: game).randomElement() ?? .defaultValue(for: game)
        return pickedBackgroundId.asWidgetBackgroundAppEntity
    }

    static var randomElementBackground: Self {
        let pickedBackgroundId = BackgroundOptions.elements.randomElement()!
        return WidgetBackgroundAppEntity(
            id: pickedBackgroundId,
            displayString: pickedBackgroundId
        )
    }

    static var randomElementOrNamecardBackground: Self {
        let pickedBackgroundId = BackgroundOptions.elementsAndNamecard.randomElement()!
        return WidgetBackgroundAppEntity(
            id: pickedBackgroundId.0,
            displayString: pickedBackgroundId.1
        )
    }
}

extension Wallpaper {
    fileprivate var asWidgetBackgroundAppEntity: WidgetBackgroundAppEntity {
        .init(id: assetName4LiveActivity, displayString: localizedNameForWidgets)
    }

    fileprivate var asBackgroundOption: (String, String) {
        (assetName4LiveActivity, localizedNameForWidgets)
    }

    private var localizedNameForWidgets: String {
        Defaults[.useRealCharacterNames]
            ? localizedRealName
            : localizedName
    }
}
