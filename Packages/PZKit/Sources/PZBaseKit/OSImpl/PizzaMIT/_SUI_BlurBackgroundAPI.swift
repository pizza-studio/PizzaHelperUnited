// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Bill Haku

import SwiftUI

// MARK: - Blur Background

extension View {
    @ViewBuilder
    public func blurMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground())
        } else {
            self
        }
    }

    @ViewBuilder
    public func adjustedBlurMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            modifier(AdjustedBlurMaterialBackground())
        } else {
            self
        }
    }

    @ViewBuilder
    public func listRowMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            listRowBackground(
                Color.clear.background(.thinMaterial, in: Rectangle())
            )
        } else {
            self
        }
    }
}

// MARK: - BlurMaterialBackground

@available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *)
struct BlurMaterialBackground: ViewModifier {
    @ViewBuilder
    public func body(content: Content) -> some View {
        content.background(
            .regularMaterial,
            in: .rect
        )
        .contentShape(.rect)
    }
}

// MARK: - AdjustedBlurMaterialBackground

@available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *)
struct AdjustedBlurMaterialBackground: ViewModifier {
    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                content.background(
                    .thinMaterial,
                    in: .rect
                )
            } else {
                content.background(
                    .regularMaterial,
                    in: .rect
                )
            }
        }.contentShape(.rect)
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme
}
