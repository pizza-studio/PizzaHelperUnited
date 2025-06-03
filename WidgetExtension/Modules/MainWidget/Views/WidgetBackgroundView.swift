// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WallpaperKit
import WidgetKit

@available(watchOS, unavailable)
struct WidgetBackgroundView: View {
    // MARK: Lifecycle

    init(
        background: WidgetBackgroundAppEntity,
        userWallpaper: WidgetUserWallpaperAppEntity? = nil,
        darkModeOn: Bool
    ) {
        self.background = background
        self.darkModeOn = darkModeOn
        if let userWallpaperObj = userWallpaper?.unwrapped,
           userWallpaperObj.imageSquared != nil,
           userWallpaperObj.imageHorizontal != nil {
            self.userWallpaper = userWallpaper
        } else {
            self.userWallpaper = nil
        }
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily

    let background: WidgetBackgroundAppEntity
    let userWallpaper: WidgetUserWallpaperAppEntity?
    let darkModeOn: Bool

    var body: some View {
        ZStack {
            if let userSuppliedWallpaperLayer {
                userSuppliedWallpaperLayer
                    .resizable()
                    .scaledToFill()
            } else {
                backgroundStackLayers
            }
            Color.black.opacity(shouldEnforceDark ? 0.25 : 0.15) // 调整白点强度
                .blendMode(.multiply) // 很重要。
        }
        .scaleEffect(1.01) // HSR 的名片有光边。
    }

    // MARK: Private

    private var shouldEnforceDark: Bool { colorScheme == .dark && darkModeOn }

    private var isUserSuppliedWallpaperEffective: Bool {
        userWallpaper?.unwrapped != nil
    }

    private var userSuppliedWallpaperLayer: Image? {
        guard let unwrapped = userWallpaper?.unwrapped else { return nil }
        switchFamily: switch widgetFamily {
        case .systemLarge, .systemSmall:
            if let cgImage = unwrapped.imageSquared {
                return Image(decorative: cgImage, scale: 1, orientation: .up)
            }
        case .systemExtraLarge, .systemMedium:
            if let cgImage = unwrapped.imageHorizontal {
                return Image(decorative: cgImage, scale: 1, orientation: .up)
            }
        default: break switchFamily
        }
        return nil
    }

    @ViewBuilder private var backgroundStackLayers: some View {
        if !background.colors.isEmpty {
            LinearGradient(
                colors: background.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        if let backgroundIconName = background.iconName {
            GeometryReader { g in
                Image(backgroundIconName, bundle: .main)
                    .resizable()
                    .scaledToFill()
                    .brightness(0.2)
                    .opacity(0.05)
                    .padding()
                    .frame(width: g.size.width, height: g.size.height)
            }
        }

        if let backgroundImageName = background.imageName {
            let wpMaybe = BundledWallpaper.allCases.first { $0.assetName4LiveActivity == backgroundImageName }
            let wallpaper = (wpMaybe ?? .defaultValue())
            let backgroundImage = wallpaper.image4LiveActivity
            let isGenshinImpact = wallpaper.game == .genshinImpact

            switch widgetFamily {
            case .systemLarge, .systemSmall:
                GeometryReader { g in
                    backgroundImage
                        .resizable()
                        .scaledToFill()
                        .offset(x: isGenshinImpact ? -g.size.width : g.size.width * -0.5)
                }
                .onAppear {
                    NSLog(
                        "[PZHelper] Successfully initialized UIImage: " + backgroundImageName
                    )
                }
            default:
                // 包括 .systemMedium
                backgroundImage
                    .resizable()
                    .scaledToFill()
                    .onAppear {
                        NSLog(
                            "[PZHelper] Successfully initialized UIImage: " + backgroundImageName
                        )
                    }
            }
        }
    }
}
