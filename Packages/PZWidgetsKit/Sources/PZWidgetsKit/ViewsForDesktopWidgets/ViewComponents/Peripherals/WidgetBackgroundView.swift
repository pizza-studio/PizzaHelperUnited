// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI
import WallpaperKit
import WidgetKit

#if !os(watchOS)

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public typealias WidgetBackgroundView = WidgetBackgroundView4DesktopWidgets
}

// MARK: - WidgetBackgroundView4DesktopWidgets

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
public struct WidgetBackgroundView4DesktopWidgets: View {
    // MARK: Lifecycle

    public init(
        background: WidgetBackground,
        darkModeOn: Bool
    ) {
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
        self.background = background
        self.darkModeOn = darkModeOn
    }

    // MARK: Public

    public var body: some View {
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
        .id(broadcaster.eventForUserWallpaperDidSave)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.widgetFamily) private var widgetFamily: WidgetFamily
    @StateObject private var broadcaster = Broadcaster.shared

    private let background: WidgetBackground
    private let darkModeOn: Bool

    private var shouldEnforceDark: Bool { colorScheme == .dark && darkModeOn }

    private var userSuppliedWallpaperLayer: Image? {
        guard let userWP = background.userSuppliedWallpaper else { return nil }
        switchFamily: switch widgetFamily {
        case .systemLarge, .systemSmall:
            if let cgImage = userWP.imageSquared {
                return Image(decorative: cgImage, scale: 1, orientation: .up)
            }
        case .systemExtraLarge, .systemMedium:
            if let cgImage = userWP.imageHorizontal {
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
                Image(backgroundIconName, bundle: .module)
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

#endif

// MARK: - ContainerBackgroundModifier

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension View {
    #if !os(watchOS)
    @available(watchOS, unavailable)
    @ViewBuilder
    public func pzWidgetContainerBackground(
        viewConfig: WidgetViewConfig?
    )
        -> some View {
        if let viewConfig {
            modifier(ContainerBackgroundModifier(viewConfig: viewConfig))
        } else {
            self
        }
    }

    @available(watchOS, unavailable)
    @ViewBuilder
    public func containerBackgroundStandbyDetector(
        viewConfig: WidgetViewConfig
    )
        -> some View {
        modifier(ContainerBackgroundStandbyDetector(viewConfig: viewConfig))
    }
    #endif

    @available(watchOS 10.0, *)
    @ViewBuilder
    public func smartStackWidgetContainerBackground(@ViewBuilder _ background: @escaping () -> some View) -> some View {
        modifier(SmartStackWidgetContainerBackground(background: background))
    }
}

// MARK: - SmartStackWidgetContainerBackground

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
private struct SmartStackWidgetContainerBackground<B: View>: ViewModifier {
    let background: () -> B

    func body(content: Content) -> some View {
        content.containerBackground(for: .widget) {
            background()
        }
    }
}

#if !os(watchOS)

// MARK: - ContainerBackgroundModifier

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
private struct ContainerBackgroundModifier: ViewModifier {
    var viewConfig: WidgetViewConfig

    func body(content: Content) -> some View {
        content.containerBackgroundStandbyDetector(viewConfig: viewConfig)
    }
}

// MARK: - ContainerBackgroundStandbyDetector

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
private struct ContainerBackgroundStandbyDetector: ViewModifier {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode: WidgetRenderingMode
    @Environment(\.widgetContentMargins) var widgetContentMargins: EdgeInsets

    var viewConfig: WidgetViewConfig

    func body(content: Content) -> some View {
        if widgetContentMargins.top < 5 {
            content.containerBackground(for: .widget) {
                WidgetBackgroundView4DesktopWidgets(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeRespected
                )
            }
        } else {
            content.padding(-15).containerBackground(for: .widget) {
                WidgetBackgroundView4DesktopWidgets(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeRespected
                )
            }
        }
    }
}

#endif
