// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WidgetKit

// MARK: - WidgetAccessibilityBackground

private struct WidgetAccessibilityBackground: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )
        } else {
            content
        }
    }
}

extension View {
    public func widgetAccessibilityBackground(enabled: Bool) -> some View {
        modifier(WidgetAccessibilityBackground(enabled: enabled))
    }
}

// MARK: - ContainerBackgroundModifier

extension View {
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

    @ViewBuilder
    public func smartStackWidgetContainerBackground(@ViewBuilder _ background: @escaping () -> some View) -> some View {
        modifier(SmartStackWidgetContainerBackground(background: background))
    }
}

// MARK: - SmartStackWidgetContainerBackground

private struct SmartStackWidgetContainerBackground<B: View>: ViewModifier {
    let background: () -> B

    func body(content: Content) -> some View {
        content.containerBackground(for: .widget) {
            background()
        }
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier: ViewModifier {
    var viewConfig: WidgetViewConfig

    func body(content: Content) -> some View {
        content.containerBackgroundStandbyDetector(viewConfig: viewConfig)
    }
}

// MARK: - ContainerBackgroundStandbyDetector

@available(watchOS, unavailable)
private struct ContainerBackgroundStandbyDetector: ViewModifier {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode: WidgetRenderingMode
    @Environment(\.widgetContentMargins) var widgetContentMargins: EdgeInsets

    var viewConfig: WidgetViewConfig

    func body(content: Content) -> some View {
        if widgetContentMargins.top < 5 {
            content.containerBackground(for: .widget) {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeRespected
                )
            }
        } else {
            content.padding(-15).containerBackground(for: .widget) {
                WidgetBackgroundView(
                    background: viewConfig.background,
                    darkModeOn: viewConfig.isDarkModeRespected
                )
            }
        }
    }
}
