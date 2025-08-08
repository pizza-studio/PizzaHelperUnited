// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

extension Font {
    public static let baseFontSize: CGFloat = {
        #if os(macOS)
        return NSFont.systemFontSize
        #elseif targetEnvironment(macCatalyst)
        return UIFont.systemFontSize / 0.77
        #elseif os(iOS)
        return UIFont.systemFontSize
        #elseif os(watchOS)
        return 13
        #else
        return 13
        #endif
    }()

    public static let baseFontSizeSmall: CGFloat = {
        #if os(macOS)
        return NSFont.smallSystemFontSize
        #elseif targetEnvironment(macCatalyst)
        return UIFont.smallSystemFontSize / 0.77
        #elseif os(iOS)
        return UIFont.smallSystemFontSize
        #elseif os(watchOS)
        return 11
        #else
        return 11
        #endif
    }()
}

// MARK: - InlineTextDescription

extension View {
    @ViewBuilder
    public func asInlineTextDescription() -> some View {
        if #available(macCatalyst 15.0, iOS 15.0, macOS 12.0, *, *) {
            font(.footnote).foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            font(.footnote).foregroundColor(.primary.opacity(0.8))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - View.headerFooterTextVisibilityEnhanced

extension View {
    @ViewBuilder
    public func headerFooterTextVisibilityEnhanced() -> some View {
        foregroundColor(.primary.opacity(0.725))
    }
}
