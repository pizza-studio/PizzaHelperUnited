// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
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
        "game.elements.imago",
        "game.elements.quanto",
        "game.elements.physico",
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
        "game.elements.imago",
        "game.elements.quanto",
        "game.elements.physico",
    ]
    static let namecards: [String] = BundledWallpaper.allCases.map(\.assetName4LiveActivity)

    static let allOptions: [(String, String)] = UserWallpaper.allCases.map(\.asBackgroundOption)
        + (Self.colors + Self.elements).map {
            ($0, $0.i18nWidgets)
        } + BundledWallpaper.allCases.map(\.asBackgroundOption)

    static let allOptionsSansPureColors: [(String, String)] = UserWallpaper.allCases.map(\.asBackgroundOption)
        + Self.elements.map {
            ($0, $0.i18nWidgets)
        } + Wallpaper.allCases.map(\.asBackgroundOption)
}

extension WidgetBackgroundAppEntity {
    static let defaultBackground: Self = {
        BundledWallpaper.defaultValue(for: appGame).asWidgetBackgroundAppEntity
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
        let pickedBackgroundId = Wallpaper.allCases.randomElement() ?? .finalFallbackValue
        return pickedBackgroundId.asWidgetBackgroundAppEntity
    }

    static func randomNamecardBackground4Game(_ game: Pizza.SupportedGame? = nil) -> Self {
        guard let game else { return randomNamecardBackground }
        let pickedBackgroundId = BundledWallpaper.allCases(for: game).randomElement() ?? .defaultValue(for: game)
        return pickedBackgroundId.asWidgetBackgroundAppEntity
    }

    static func randomNamecardBackground4Games(_ games: Set<Pizza.SupportedGame> = []) -> Self {
        guard !games.isEmpty else { return randomNamecardBackground }
        guard let game = games.randomElement() else { return randomNamecardBackground }
        let pickedBackgroundId = BundledWallpaper.allCases(for: game).randomElement() ?? .defaultValue(for: game)
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
        let pickedBackgroundId = BackgroundOptions.allOptionsSansPureColors.randomElement()!
        return WidgetBackgroundAppEntity(
            id: pickedBackgroundId.0,
            displayString: pickedBackgroundId.1
        )
    }
}

extension BundledWallpaper {
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

// MARK: - User Wallpaper Implementations.

extension UserWallpaper {
    fileprivate var asWidgetBackgroundAppEntity: WidgetBackgroundAppEntity {
        .init(id: id.uuidString, displayString: "\(name) (\(dateString))")
    }

    fileprivate var asBackgroundOption: (String, String) {
        (id.uuidString, name)
    }
}

extension Wallpaper {
    fileprivate var asWidgetBackgroundAppEntity: WidgetBackgroundAppEntity {
        switch self {
        case let .bundled(bundledWallpaper): bundledWallpaper.asWidgetBackgroundAppEntity
        case let .user(userWallpaper): userWallpaper.asWidgetBackgroundAppEntity
        }
    }

    fileprivate var asBackgroundOption: (String, String) {
        switch self {
        case let .bundled(bundledWallpaper): bundledWallpaper.asBackgroundOption
        case let .user(userWallpaper): userWallpaper.asBackgroundOption
        }
    }
}
