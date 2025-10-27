// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Bill Haku

import SwiftUI

// MARK: - Blur Background

extension View {
    @ViewBuilder
    public func blurMaterialBackground<T: Shape>(enabled: Bool = true, shape: T) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground(shape: shape))
        } else {
            self
        }
    }

    @ViewBuilder
    public func blurMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground(shape: .rect))
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
            listRowBackground(
                Color.clear.background(.thinMaterial, in: .rect)
                // LiquidGlassEffect is not applied here because it causes visual glitches.
            )
        } else {
            self
        }
    }
}

// MARK: - BlurMaterialBackground

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *)
struct BlurMaterialBackground<T: Shape>: ViewModifier {
    // MARK: Lifecycle

    public init(shape: T) {
        self.shape = shape
    }

    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .clipShape(shape) // 必需
            .background(
                .regularMaterial,
                in: shape
            )
            .apply { neta in
                if #available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *) {
                    neta.glassEffect(.identity, in: shape)
                } else {
                    neta
                }
            }
            .contentShape(shape)
    }

    // MARK: Private

    private let shape: T
}
