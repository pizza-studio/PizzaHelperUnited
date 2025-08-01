// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

// MARK: - CornerTaggedViewModifier

@available(iOS 16.0, macCatalyst 16.0, *)
struct CornerTaggedViewModifier<T: View>: ViewModifier {
    // MARK: Lifecycle

    public init(
        verbatim: String,
        alignment: Alignment,
        textSize: CGFloat,
        opacity: CGFloat,
        padding: CGFloat,
        backgroundOverride: T? = nil
    ) {
        self.stringVerbatim = verbatim
        self.alignment = alignment
        self.textSize = textSize
        self.opacity = opacity
        self.padding = padding
        self.backgroundOverride = backgroundOverride
    }

    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        switch stringVerbatim != "" {
        case false: content
        case true:
            content.overlay(alignment: alignment) {
                theTagCapsule
            }
        }
    }

    // MARK: Private

    @Environment(\.colorScheme) private var colorScheme

    private let stringVerbatim: String
    private let alignment: Alignment
    private let textSize: CGFloat
    private let opacity: CGFloat
    private let padding: CGFloat
    private let backgroundOverride: T?

    @ViewBuilder private var theTagCapsule: some View {
        Text(stringVerbatim)
            .font(.system(size: textSize))
            .fontWidth(.condensed)
            .fontWeight(.medium)
            .padding(.horizontal, 0.3 * textSize)
            .apply { content in
                if let backgroundOverride {
                    content
                        .background {
                            backgroundOverride
                        }
                } else {
                    content
                        .adjustedBlurMaterialBackground()
                }
            }
            .clipShape(Capsule())
            .opacity(opacity)
            .padding(padding)
            .fixedSize()
            .foregroundStyle(.white)
    }
}

extension View {
    @ViewBuilder
    public func corneredTag<T: View>(
        verbatim stringVerbatim: String,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0,
        @ViewBuilder backgroundOverride: () -> some View
    )
        -> some View {
        if enabled, #available(iOS 16.0, macCatalyst 16.0, *) {
            modifier(
                CornerTaggedViewModifier(
                    verbatim: stringVerbatim,
                    alignment: alignment,
                    textSize: textSize,
                    opacity: opacity,
                    padding: padding,
                    backgroundOverride: backgroundOverride()
                )
            )
            .environment(\.colorScheme, .dark)
        } else {
            self
        }
    }

    @ViewBuilder
    public func corneredTag(
        verbatim stringVerbatim: String,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        if enabled, #available(iOS 16.0, macCatalyst 16.0, *) {
            modifier(
                CornerTaggedViewModifier<EmptyView>(
                    verbatim: stringVerbatim,
                    alignment: alignment,
                    textSize: textSize,
                    opacity: opacity,
                    padding: padding,
                    backgroundOverride: nil
                )
            )
            .environment(\.colorScheme, .dark)
        } else {
            self
        }
    }
}
