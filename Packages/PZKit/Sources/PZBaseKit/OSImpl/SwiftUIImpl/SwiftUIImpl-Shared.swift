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

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 9.0, *)
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
                .font(.caption2)
                .fontWidth(.condensed)
                .opacity(0.7)
        } else {
            EmptyView()
        }
    }

    // MARK: Internal

    @State var direction: Direction
}

// MARK: - CornerTaggedViewModifier

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 10.0, *)
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
        if enabled, #available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 10.0, *) {
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
        if enabled, #available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 10.0, *) {
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

// MARK: - Blur Background

extension View {
    @ViewBuilder
    public func blurMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(BlurMaterialBackground())
        } else {
            self
        }
    }

    @ViewBuilder
    public func adjustedBlurMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            modifier(AdjustedBlurMaterialBackground())
        } else {
            self
        }
    }

    @ViewBuilder
    public func listRowMaterialBackground(enabled: Bool = true) -> some View {
        if #available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *), enabled {
            listRowBackground(
                Color.clear.background(.thinMaterial, in: Rectangle())
            )
        } else {
            self
        }
    }
}

// MARK: - BlurMaterialBackground

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *)
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

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 10.0, *)
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

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 8.0, *)
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

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 8.0, *)
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

    @ViewBuilder
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
    @ViewBuilder
    public func accentVerseBackground() -> some View {
        modifier(AccentVerseBackground())
    }
}

// MARK: - Make OptionsSet Bindable.

// Ref: https://gist.github.com/vibrazy/79d407cf2eac2b0e65a61ab07f584105

extension Binding where Value: OptionSet, Value == Value.Element {
    public func bindedValue(_ options: Value) -> Bool {
        wrappedValue.contains(options)
    }

    @MainActor
    public func bind(
        _ options: Value,
        animate: Bool = false
    )
        -> Binding<Bool> {
        .init { () -> Bool in
            self.wrappedValue.contains(options)
        } set: { newValue in
            let body = {
                if newValue {
                    self.wrappedValue.insert(options)
                } else {
                    self.wrappedValue.remove(options)
                }
            }
            guard animate else {
                body()
                return
            }
            withAnimation {
                body()
            }
        }
    }
}

// MARK: - Optional Modifier Wrappers

extension View {
    public func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

// MARK: - NavBarTitleDisplayMode.

extension View {
    @ViewBuilder
    public func navBarTitleDisplayMode(_ mode: NavBarTitleDisplayMode?) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        switch mode {
        case .inline: self.navigationBarTitleDisplayMode(.inline)
        case .large: self.navigationBarTitleDisplayMode(.large)
        case nil: self.navigationBarTitleDisplayMode(.automatic)
        }
        #else
        self
        #endif
    }
}

// MARK: - NavBarTitleDisplayMode

/// This one is compatible to macOS on compilation.
public enum NavBarTitleDisplayMode {
    case inline
    case large
}

// MARK: - InlineTextDescription

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 8.0, *)
extension View {
    @ViewBuilder
    public func asInlineTextDescription() -> some View {
        font(.footnote).foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
