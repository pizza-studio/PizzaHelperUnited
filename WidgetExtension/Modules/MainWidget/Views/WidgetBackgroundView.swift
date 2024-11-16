// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WallpaperKit
import WidgetKit

@available(watchOS, unavailable)
struct WidgetBackgroundView: View {
    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.widgetFamily) var widgetFamily: WidgetFamily
    let background: WidgetBackgroundAppEntity
    let darkModeOn: Bool

    var backgroundColors: [Color] { background.colors }
    var backgroundIconName: String? { background.iconName }
    var backgroundImageName: String? { background.imageName }
    var body: some View {
        ZStack {
            if !backgroundColors.isEmpty {
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            if let backgroundIconName = backgroundIconName {
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

            if let backgroundImageName {
                let wpMaybe = Wallpaper.allCases.first { $0.assetName4LiveActivity == backgroundImageName }
                let wallpaper = (wpMaybe ?? .defaultValue())
                let backgroundImage = wallpaper.image4LiveActivity
                let isGenshinImpact = wallpaper.game == .genshinImpact

                switch widgetFamily {
                case .systemLarge, .systemSmall:
                    GeometryReader { g in
                        backgroundImage
                            .resizable()
                            .scaledToFill()
                            .offset(x: isGenshinImpact ? -g.size.width : 0)
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
        .brightness(shouldEnforceDark ? -0.15 : 0)
        .scaleEffect(1.01) // HSR 的名片有光边。
    }

    // MARK: Private

    private var shouldEnforceDark: Bool { colorScheme == .dark && darkModeOn }
}
