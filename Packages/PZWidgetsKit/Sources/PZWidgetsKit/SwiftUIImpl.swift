// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WidgetKit

// MARK: - WidgetAccessibilityBackground

@available(iOS 16.2, macCatalyst 16.2, watchOS 10.0, *)
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
    @ViewBuilder
    public func widgetAccessibilityBackground(enabled: Bool) -> some View {
        if #available(iOS 16.2, macCatalyst 16.2, watchOS 10.0, *) {
            modifier(WidgetAccessibilityBackground(enabled: enabled))
        } else {
            self
        }
    }
}

#if !os(watchOS)
@available(iOS 16.2, macCatalyst 16.2, *)
extension Widget {
    public var extraLargePortraitFamilies: [WidgetFamily] {
        #if compiler(>=6.4)
        if #available(iOS 27.0, macCatalyst 27.0, *) {
            return [.systemExtraLargePortrait]
        }
        return [WidgetFamily(rawValue: 4)].compactMap(\.self)
        #else
        return [WidgetFamily(rawValue: 4)].compactMap(\.self)
        #endif
    }
}

extension WidgetFamily {
    public var isSystemExtraLargePortrait: Bool {
        #if compiler(>=6.4)
        if #available(iOS 27.0, macCatalyst 27.0, *) {
            return self == .systemExtraLargePortrait
        }
        return rawValue == 4
        #else
        return rawValue == 4
        #endif
    }

    public var isExtraLargeOrExtraLargePortrait: Bool {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            return isSystemExtraLargePortrait || self == .systemExtraLarge
        }
        return isSystemExtraLargePortrait
    }
}

#endif
