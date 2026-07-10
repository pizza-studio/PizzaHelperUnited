// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WidgetKit

// MARK: - WidgetAccessibilityBackground

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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
        if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
            modifier(WidgetAccessibilityBackground(enabled: enabled))
        } else {
            self
        }
    }
}

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, *)
extension Widget {
    public var extraLargePortraitFamilies: [WidgetFamily] {
        if #available(iOS 27.0, macCatalyst 27.0, *) {
            // 直接藉由 rawValue 構築，繞過 OS26 SDK 的限制。
            return [WidgetFamily(rawValue: 4)].compactMap(\.self)
        }
        // `WidgetFamily(rawValue: 4)` 在 OS26 不是 nil，會出現「假陽性」的問題。
        // 使用者看到 ExtraLargePortrait 尺寸可以選，但選了之後小工具不會切換到該尺寸。
        // 這屬於會被審核員打槍的情形。
        return []
    }
}

extension WidgetFamily {
    public var isSystemExtraLargePortrait: Bool {
        // 直接藉由 rawValue 構築，繞過 OS26 SDK 的限制。
        rawValue == 4
        // 上述操作不會讓 OS26 錯誤地出現對 ExtraLargePortrait 的假陽性支援。
        // 詳見 `extraLargePortraitFamilies` 的內文註解。
    }

    public var isExtraLargeOrExtraLargePortrait: Bool {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            return isSystemExtraLargePortrait || self == .systemExtraLarge
        }
        return isSystemExtraLargePortrait
    }
}

#endif
