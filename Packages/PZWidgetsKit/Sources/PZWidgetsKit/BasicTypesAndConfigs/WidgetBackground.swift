// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Defaults
import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - WidgetBackground

@available(iOS 16.2, macCatalyst 16.2, *)
public struct WidgetBackground: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    // MARK: Public

    public static let defaultBackground: Self = {
        BundledWallpaper.defaultValue(for: appGame).asWidgetBackground
    }()

    public var id: String
    public var displayString: String
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension WidgetBackground {
    public static let colors: [String] = [
        "pzWidgetsKit.widgetBackgroundColorScheme.gray",
        "pzWidgetsKit.widgetBackgroundColorScheme.green",
        "pzWidgetsKit.widgetBackgroundColorScheme.blue",
        "pzWidgetsKit.widgetBackgroundColorScheme.purple",
        "pzWidgetsKit.widgetBackgroundColorScheme.gold",
        "pzWidgetsKit.widgetBackgroundColorScheme.red",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.anemo",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.hydro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.cryo",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.pyro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.geo",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.electro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.dendro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.imago",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.quanto",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.physico",
        "pzWidgetsKit.widgetBackgroundColorScheme.intertwinedFate",
    ]
    public static let elements: [String] = [
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.anemo",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.hydro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.cryo",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.pyro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.geo",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.electro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.dendro",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.imago",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.quanto",
        "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.physico",
    ]

    public static let allStaticGalleryWallpaperOptions: [Self] = BundledWallpaper.allCases
        .map(\.asWidgetBackground)

    public static var allOptions: [Self] {
        UserWallpaper.allCases.map(\.asWidgetBackground)
            + (Self.colors + Self.elements).map {
                .init(id: $0, displayString: $0.i18nPZWidgetsKit)
            } + allStaticGalleryWallpaperOptions
    }

    public static var allOptionsSansPureColors: [Self] {
        UserWallpaper.allCases.map(\.asWidgetBackground)
            + Self.elements.map {
                .init(id: $0, displayString: $0.i18nPZWidgetsKit)
            } + allStaticGalleryWallpaperOptions
    }

    public var userSuppliedWallpaper: UserWallpaper? {
        let uuid = UUID(uuidString: id)
        guard uuid != nil else { return nil }
        return .init(defaultsValueID: id)
    }

    @MainActor public var cachedOnlineBundledImageAsset: Image? {
        let matchedWP = Wallpaper(id: id)
        guard let matchedWP else { return nil }
        guard case let .bundled(bundledWPMatched) = matchedWP else { return nil }
        guard let url = bundledWPMatched.onlineAssetURL else { return nil }
        guard let cgImage = OnlineImageFS.getCGImageFromFS(url.absoluteString.md5) else { return nil }
        return Image(decorative: cgImage, scale: 1)
    }

    public var isValidGalleryWallpaper: Bool {
        WidgetBackground.allStaticGalleryWallpaperOptions.map(\.id).contains(id)
    }

    public var iconName: String? {
        switch id {
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.anemo":
            return "element_Anemo"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.hydro":
            return "element_Hydro"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.cryo":
            return "element_Cryo"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.pyro":
            return "element_Pyro"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.geo":
            return "element_Geo"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.electro":
            return "element_Electro"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.dendro":
            return "element_Dendro"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.imago":
            return "element_Imago"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.quanto":
            return "element_Quanto"
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.physico":
            return "element_Physico"
        default:
            return nil
        }
    }

    public var colors: [Color] {
        switch id {
        case "pzWidgetsKit.widgetBackgroundColorScheme.purple":
            return [
                Color.purple,
                Color.purple.addBrightness(-0.15),
                Color.purple.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gold":
            return [
                Color.yellow,
                Color.yellow.addBrightness(-0.15),
                Color.yellow.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gray":
            return [
                Color.gray,
                Color.gray.addBrightness(-0.15),
                Color.gray.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.green":
            return [
                Color.green,
                Color.green.addBrightness(-0.15),
                Color.green.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.blue":
            return [
                Color.blue,
                Color.blue.addBrightness(-0.15),
                Color.blue.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.red":
            return [
                Color.red,
                Color.red.addBrightness(-0.15),
                Color.red.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.anemo":
            return [
                Color.mint,
                Color.mint.addBrightness(-0.15),
                Color.mint.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.hydro":
            return [
                Color.blue,
                Color.blue.addBrightness(-0.15),
                Color.blue.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.cryo":
            return [
                Color.cyan,
                Color.cyan.addBrightness(-0.15),
                Color.cyan.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.pyro":
            return [
                Color.red,
                Color.red.addBrightness(-0.15),
                Color.red.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.geo":
            return [
                Color.orange,
                Color.orange.addBrightness(-0.15),
                Color.orange.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.electro":
            return [
                Color.purple,
                Color.purple.addBrightness(-0.15),
                Color.purple.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.dendro":
            return [
                Color.green,
                Color.green.addBrightness(-0.15),
                Color.green.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.quanto":
            return [
                Color.indigo,
                Color.indigo.addBrightness(-0.15),
                Color.indigo.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.imago":
            return [
                Color.yellow,
                Color.yellow.addBrightness(-0.15),
                Color.yellow.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.gameElements.physico":
            return [
                Color.gray,
                Color.gray.addBrightness(-0.15),
                Color.gray.addBrightness(-0.3),
            ]
        case "pzWidgetsKit.widgetBackgroundColorScheme.intertwinedFate":
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

@available(iOS 16.2, macCatalyst 16.2, *)
extension WidgetBackground {
    public static var randomBackground: Self {
        let pickedBackgroundId = WidgetBackground.allOptions.randomElement()!
        return WidgetBackground(
            id: pickedBackgroundId.id,
            displayString: pickedBackgroundId.displayString
        )
    }

    public static var randomColorBackground: Self {
        let pickedBackgroundId = WidgetBackground.colors.randomElement()!
        return WidgetBackground(
            id: pickedBackgroundId,
            displayString: pickedBackgroundId
        )
    }

    public static var randomWallpaperBackground: Self {
        let pickedBackgroundId = Wallpaper.allCases.randomElement() ?? .finalFallbackValue
        return pickedBackgroundId.asWidgetBackground
    }

    public static func randomWallpaperBackground4Game(_ game: Pizza.SupportedGame? = nil) -> Self {
        guard let game else { return randomWallpaperBackground }
        let pickedBackgroundId = BundledWallpaper.allCases(for: game).randomElement() ?? .defaultValue(for: game)
        return pickedBackgroundId.asWidgetBackground
    }

    public static func randomWallpaperBackground4Games(_ games: Set<Pizza.SupportedGame> = []) -> Self {
        guard !games.isEmpty else { return randomWallpaperBackground }
        guard let game = games.randomElement() else { return randomWallpaperBackground }
        let pickedBackgroundId = BundledWallpaper.allCases(for: game).randomElement() ?? .defaultValue(for: game)
        return pickedBackgroundId.asWidgetBackground
    }

    public static var randomElementBackground: Self {
        let pickedBackgroundId = WidgetBackground.elements.randomElement()!
        return WidgetBackground(
            id: pickedBackgroundId,
            displayString: pickedBackgroundId
        )
    }

    public static var randomElementOrWallpaperBackground: Self {
        let pickedBackgroundId = WidgetBackground.allOptionsSansPureColors.randomElement()!
        return WidgetBackground(
            id: pickedBackgroundId.id,
            displayString: pickedBackgroundId.displayString
        )
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension BundledWallpaper {
    public var asWidgetBackground: WidgetBackground {
        .init(id: id, displayString: localizedNameForWidgets)
    }

    private var localizedNameForWidgets: String {
        Defaults[.useRealCharacterNames]
            ? localizedRealName
            : localizedName
    }
}

// MARK: - User Wallpaper Implementations.

@available(iOS 16.2, macCatalyst 16.2, *)
extension UserWallpaper {
    fileprivate var asWidgetBackground: WidgetBackground {
        .init(id: id.uuidString, displayString: "\(name) (\(dateString))")
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Wallpaper {
    fileprivate var asWidgetBackground: WidgetBackground {
        switch self {
        case let .bundled(bundledWallpaper): bundledWallpaper.asWidgetBackground
        case let .user(userWallpaper): userWallpaper.asWidgetBackground
        }
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension BundledWallpaper {
    func saveOnlineBackgroundAsset() async {
        guard let url = onlineAssetURL else { return }
        let fileNameStem = url.absoluteString.md5
        guard !OnlineImageFS.checkExistence(fileNameStem) else { return }
        let data: Data = (try? await AF.request(url).serializingData().value) ?? .init([])
        guard let cgImage = CGImage.instantiate(data: data) else { return }
        try? OnlineImageFS.insertCGImageToFSIfMissing(fileNameStem, cgImage: cgImage)
    }
}
