// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZWidgetsKit
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

    static let allStaticGalleryWallpaperOptions: [(String, String)] = BundledWallpaper.allCases
        .map(\.asBackgroundOption)

    static var allOptions: [(String, String)] {
        UserWallpaper.allCases.map(\.asBackgroundOption)
            + (Self.colors + Self.elements).map {
                ($0, $0.i18nWidgets)
            } + allStaticGalleryWallpaperOptions
    }

    static var allOptionsSansPureColors: [(String, String)] {
        UserWallpaper.allCases.map(\.asBackgroundOption)
            + Self.elements.map {
                ($0, $0.i18nWidgets)
            } + allStaticGalleryWallpaperOptions
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
