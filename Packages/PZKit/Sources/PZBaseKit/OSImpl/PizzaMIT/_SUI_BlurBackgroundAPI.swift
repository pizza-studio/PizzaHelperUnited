// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Bill Haku

import SwiftUI

// MARK: - Blur Background

extension View {
    @ViewBuilder
    public func blurMaterialBackground<T: Shape>(enabled: Bool = true, shape: T) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground(shape: shape))
        } else {
            self
        }
    }

    @ViewBuilder
    public func blurMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground(shape: .rect))
        } else {
            self
        }
    }

    @ViewBuilder
    public func corneredTagMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            modifier(CorneredTagMaterialBackground())
        } else {
            self
        }
    }

    @ViewBuilder
    public func listRowMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *), enabled {
            if #available(iOS 26.0, macCatalyst 26.0, watchOS 26.0, *) {
                listRowBackground(
                    Color.clear.glassEffect(.regular, in: .rect)
                )
            } else {
                listRowBackground(
                    Color.clear.background(.thinMaterial, in: .rect)
                )
            }
        } else {
            self
        }
    }
}

// MARK: - BlurMaterialBackground

@available(iOS 15.0, macCatalyst 15.0, watchOS 10.0, *)
struct BlurMaterialBackground<T: Shape>: ViewModifier {
    // MARK: Lifecycle

    public init(shape: T) {
        self.shape = shape
    }

    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 26.0, macCatalyst 26.0, watchOS 26.0, *) {
            content
                .clipShape(shape) // 必需
                .glassEffect(.regular, in: shape)
                .contentShape(shape)
        } else {
            content
                .clipShape(shape) // 必需
                .background(
                    .regularMaterial,
                    in: shape
                )
                .contentShape(shape)
        }
    }

    // MARK: Private

    private let shape: T
}
