// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

extension Image {
    public static func from(path: String) -> Image? {
        guard let cgImage = CGImage.instantiate(filePath: path) else { return nil }
        return Image(decorative: cgImage, scale: 1)
    }
}

// MARK: - HelpTextForScrollingOnDesktopComputer

public struct HelpTextForScrollingOnDesktopComputer: View {
    // MARK: Lifecycle

    public init(_ direction: Direction) {
        self.direction = direction
    }

    // MARK: Public

    public enum Direction {
        case horizontal, vertical
    }

    public var body: some View {
        if OS.type == .macOS {
            let mark: String = (direction == .horizontal) ? "⇆ " : "⇅ "
            (Text(verbatim: mark) + Text("operation.scrolling.guide", bundle: Bundle.module))
                .font(.footnote).opacity(0.7)
        } else {
            EmptyView()
        }
    }

    // MARK: Internal

    @State var direction: Direction
}

// MARK: - Trailing Text Label

extension View {
    public func corneredTag(
        _ stringKey: LocalizedStringKey,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        guard stringKey != "", enabled else { return AnyView(self) }
        return AnyView(
            ZStack(alignment: alignment) {
                self
                Text(stringKey)
                    .font(.system(size: textSize))
                    .fontWidth(.condensed)
                    .fontWeight(.medium)
                    .padding(.horizontal, 0.3 * textSize)
                    .adjustedBlurMaterialBackground().clipShape(Capsule())
                    .opacity(opacity)
                    .padding(padding)
                    .fixedSize()
            }
        )
    }

    public func corneredTag(
        verbatim stringVerbatim: String,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        guard stringVerbatim != "", enabled else { return AnyView(self) }
        return AnyView(
            ZStack(alignment: alignment) {
                self
                Text(stringVerbatim)
                    .font(.system(size: textSize))
                    .fontWidth(.condensed)
                    .fontWeight(.medium)
                    .padding(.horizontal, 0.3 * textSize)
                    .adjustedBlurMaterialBackground().clipShape(Capsule())
                    .opacity(opacity)
                    .padding(padding)
                    .fixedSize()
            }
        )
    }
}

// MARK: - Blur Background

extension View {
    public func blurMaterialBackground() -> some View {
        modifier(BlurMaterialBackground())
    }

    public func adjustedBlurMaterialBackground() -> some View {
        modifier(AdjustedBlurMaterialBackground())
    }
}

// MARK: - BlurMaterialBackground

struct BlurMaterialBackground: ViewModifier {
    public func body(content: Content) -> some View {
        content.background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
    }
}

// MARK: - AdjustedBlurMaterialBackground

struct AdjustedBlurMaterialBackground: ViewModifier {
    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                content.background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            } else {
                content.background(
                    .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
        }.contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme
}

extension Font {
    public static let baseFontSize: CGFloat = {
        #if os(OSX)
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
}

extension CGColor {
    public var suiColor: Color {
        .init(cgColor: self)
    }
}

// MARK: - Divided

// Ref: https://stackoverflow.com/a/75538094/4162914
public struct Divided<Content: View>: View {
    // MARK: Lifecycle

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: Public

    public var body: some View {
        _VariadicView.Tree(DividedLayout()) {
            content
        }
    }

    // MARK: Internal

    struct DividedLayout: _VariadicView_MultiViewRoot {
        @ViewBuilder
        public func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id

            ForEach(children) { child in
                child

                if child.id != last {
                    Divider()
                }
            }
        }
    }

    var content: Content
}

// MARK: - View.restoreAppTint.

extension View {
    @ViewBuilder
    public func restoreSystemTint() -> some View {
        // tint(.init(uiColor: UIColor.tintColor))
        tint(.accentColor)
    }
}

// MARK: - View.headerFooterVisibilityEnhanced

extension View {
    @ViewBuilder
    public func secondaryColorVerseBackground() -> some View {
        foregroundColor(.primary.opacity(0.75))
    }
}

// MARK: - AccentVerseBackground

public struct AccentVerseBackground: ViewModifier {
    // MARK: Public

    public func body(content: Content) -> some View {
        switch colorScheme {
        case .light:
            content
                .foregroundColor(Color(UIColor.darkGray))
                .blendMode(.colorDodge)
        case .dark:
            content
                .foregroundColor(Color(UIColor.lightGray))
                .blendMode(.colorDodge)
        @unknown default:
            content
        }
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme
}

extension View {
    public func accentVerseBackground() -> some View {
        modifier(AccentVerseBackground())
    }
}