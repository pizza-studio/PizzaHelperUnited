// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Bill Haku & Shiki Suen

import Defaults
import SwiftUI

// MARK: - Blur Background

extension View {
    @ViewBuilder
    public func blurMaterialBackground<T: Shape>(
        enabled: Bool = true,
        shape: T,
        interactive: Bool = false
    )
        -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground(shape: shape, interactive: interactive))
        } else {
            self
        }
    }

    @ViewBuilder
    public func blurMaterialBackground(
        enabled: Bool = true,
        interactive: Bool = false
    )
        -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground(shape: .rect, interactive: interactive))
        } else {
            self
        }
    }

    @ViewBuilder
    public func corneredTagMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(CorneredTagMaterialBackground())
        } else {
            self
        }
    }

    @ViewBuilder
    public func listRowMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            listRowBackground(ListRowMaterialBackgroundView())
        } else {
            self
        }
    }
}

// MARK: - BlurMaterialBackground

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *)
struct BlurMaterialBackground<T: Shape>: ViewModifier {
    // MARK: Lifecycle

    public init(shape: T, interactive: Bool) {
        self.shape = shape
        self.interactive = interactive
    }

    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .clipShape(shape) // 必需
            .background(alignment: .center) {
                if sansTransparency || deviceBannedForUIGlassDecorations {
                    ZStack {
                        Color.primary.colorInvert()
                            .opacity(0.2)
                            .blendMode(colorScheme == .dark ? .darken : .hardLight)
                        fillColor4ReducedTransparency
                            .blendMode(colorScheme == .dark ? .difference : .normal)
                            .opacity(0.5)
                    }
                    .clipShape(shape)
                } else {
                    shape
                        .fill(.regularMaterial)
                }
            }
            .apply { neta in
                if sansTransparency || deviceBannedForUIGlassDecorations {
                    neta
                } else if #available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *),
                          OS.liquidGlassThemeSuspected {
                    neta.glassEffect(.identity.interactive(interactive), in: shape)
                } else {
                    neta
                }
            }
            .contentShape(shape)
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @Default(.reduceUIGlassDecorations) private var reduceUIGlassDecorations

    private let shape: T
    private let interactive: Bool
    private let deviceBannedForUIGlassDecorations = ThisDevice.deviceBannedForUIGlassDecorations

    private var sansTransparency: Bool {
        reduceTransparency || reduceUIGlassDecorations
    }

    @ViewBuilder private var fillColor4ReducedTransparency: some View {
        let luminance: Double = switch colorScheme {
        case .dark: 0.35
        default: 1
        }
        Color(hue: 0, saturation: 0, brightness: luminance, opacity: 0.6)
    }
}

// MARK: - ListRowMaterialBackgroundView

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *)
private struct ListRowMaterialBackgroundView: View {
    // MARK: Internal

    // MARK: View

    var body: some View {
        Group {
            if sansTransparency || deviceBannedForUIGlassDecorations {
                ZStack {
                    Color.primary.colorInvert()
                        .opacity(0.2)
                        .blendMode(colorScheme == .dark ? .darken : .hardLight)
                    fillColor4ReducedTransparency
                        .blendMode(colorScheme == .dark ? .difference : .normal)
                        .opacity(0.5)
                }
                .clipShape(.rect)
            } else {
                Color.clear
                    .background(.thinMaterial, in: .rect)
                // LiquidGlassEffect is not applied here because it causes visual glitches.
            }
        }
    }

    // MARK: Private

    @Default(.reduceUIGlassDecorations) private var reduceUIGlassDecorations
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let deviceBannedForUIGlassDecorations = ThisDevice.deviceBannedForUIGlassDecorations

    private var sansTransparency: Bool {
        reduceTransparency || reduceUIGlassDecorations
    }

    @ViewBuilder private var fillColor4ReducedTransparency: some View {
        let luminance: Double = switch colorScheme {
        case .dark: 0.35
        default: 1
        }
        LinearGradient(
            colors: [
                Color(hue: 0, saturation: 0, brightness: luminance, opacity: 0.6),
                Color(hue: 0, saturation: 0, brightness: luminance, opacity: 0.5),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
