// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import SwiftUI
import WallpaperKit

// MARK: - CharacterIconView

public struct CharacterIconView: View {
    // MARK: Lifecycle

    /// 圆形图示。
    public init(
        charID: String,
        size: CGFloat,
        circleClipped: Bool = true,
        clipToHead: Bool = false
    ) {
        /// 原神主角双子的 charID 是十二位，需要去掉后四位。
        var newCharID = charID
        if charID.count == 12 {
            newCharID = charID.prefix(8).description
        }
        self.charIDTruncated = newCharID
        self.charID = charID
        self.size = size
        self.circleClipped = circleClipped
        self.clipToHead = clipToHead
        self.isCard = false
        /// 算上 costume id 后缀的话，原神的 CharID 会更长。所以 >= 8。
        self.game = charID.count >= 8 ? .genshinImpact : .starRail
        self.roundRectCornerRadius = size * Self.roundedRectRatio
    }

    /// 卡片图示。
    public init(
        charID: String,
        cardSize size: CGFloat
    ) {
        /// 原神主角双子的 charID 是十二位，需要去掉后四位。
        var newCharID = charID
        if charID.count == 12 {
            newCharID = charID.prefix(8).description
        }
        self.charIDTruncated = newCharID
        self.charID = charID
        self.size = size
        self.circleClipped = false
        self.clipToHead = false
        self.isCard = true
        /// 算上 costume id 后缀的话，原神的 CharID 会更长。所以 >= 8。
        self.game = charID.count >= 8 ? .genshinImpact : .starRail
        self.roundRectCornerRadius = size * Self.roundedRectRatio
    }

    // MARK: Public

    @MainActor public var body: some View {
        switch (game, isCard) {
        case (.starRail, true): cardIconHSR
        case (.starRail, false): normalIconHSR
        case (.genshinImpact, true): cardIconGI
        case (.genshinImpact, false): normalIconGI
        case (.zenlessZone, _): EmptyView() // 临时设定。
        }
    }

    // MARK: Internal

    @MainActor @ViewBuilder var cardIconGI: some View {
        if let fetched = Enka.queryImageAssetSUI(for: "gi_character_\(charIDGuarded)") {
            fetched
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size * 0.74, height: size)
                .clipped()
                .scaledToFit()
                .background { turnImageAsBlurredBackground4GI(fetched) }
                .clipShape(RoundedRectangle(cornerRadius: size / 10))
                .contentShape(RoundedRectangle(cornerRadius: size / 10))
                .compositingGroup()
        } else {
            blankQuestionedView
        }
    }

    @MainActor @ViewBuilder var normalIconGI: some View {
        if let fetched = Enka.queryImageAssetSUI(for: "gi_character_\(charIDGuarded)") {
            let newResult = fetched
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size * cutType.rawValue, height: size * cutType.rawValue)
                .clipped()
                .scaledToFit()
                .offset(y: cutType.shiftedAmount(containerSize: size))
                .frame(width: size, height: size)

            // Draw.
            let currentBg = turnImageAsBlurredBackground4GI(fetched)
            Group {
                if circleClipped {
                    newResult
                        .background { currentBg }
                        .clipShape(.circle)
                        .contentShape(.circle)
                } else {
                    newResult
                        .background { currentBg }
                        .clipShape(RoundedRectangle(cornerRadius: roundRectCornerRadius))
                        .contentShape(RoundedRectangle(cornerRadius: roundRectCornerRadius))
                }
            }
            .compositingGroup()
        } else {
            blankQuestionedView
        }
    }

    @MainActor @ViewBuilder var cardIconHSR: some View {
        if useGenshinStyleIcon,
           let idPhotoView = IDPhotoView4HSR(pid: charIDGuarded, size, .asCard) {
            idPhotoView
        } else if useGenshinStyleIcon,
                  let idPhotoView = IDPhotoFallbackView4HSR(pid: charIDGuarded, size, .asCard) {
            idPhotoView
        } else if let traditionalFallback = Enka.queryImageAssetSUI(for: proposedPhotoAssetName) {
            traditionalFallback
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(1.5, anchor: .top)
                .scaleEffect(1.4)
                .frame(width: size * 0.74, height: size)
                .background {
                    Color.black.opacity(0.165)
                }
                .clipShape(RoundedRectangle(cornerRadius: size / 10))
                .contentShape(RoundedRectangle(cornerRadius: size / 10))
                .compositingGroup()
        } else {
            blankQuestionedView
        }
    }

    @MainActor @ViewBuilder var normalIconHSR: some View {
        if useGenshinStyleIcon,
           let idPhotoView = IDPhotoView4HSR(pid: charIDGuarded, size, cutType) {
            idPhotoView
        } else if useGenshinStyleIcon,
                  let idPhotoView = IDPhotoFallbackView4HSR(pid: charIDGuarded, size, cutType) {
            idPhotoView
        } else if let result = Enka.queryImageAssetSUI(for: proposedPhotoAssetName) {
            let newResult = result
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(1.5, anchor: .top)
                .offset(y: size / (15 * 1.15))
                .scaleEffect(1.4)
                .frame(maxWidth: size, maxHeight: size)
            // Draw.
            let bgColor = Color.black.opacity(0.165)
            Group {
                if circleClipped {
                    newResult
                        .background { bgColor }
                        .clipShape(.circle)
                        .contentShape(.circle)
                } else {
                    newResult
                        .background { bgColor }
                        .clipShape(RoundedRectangle(cornerRadius: roundRectCornerRadius))
                        .contentShape(RoundedRectangle(cornerRadius: roundRectCornerRadius))
                }
            }
            .compositingGroup()
        } else {
            blankQuestionedView
        }
    }

    // MARK: Private

    private static let roundedRectRatio = 179.649 / 1024

    // Note: Due to the mission-critical fact in this context, we use @AppStorage in lieu of @Default.
    // @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleIcon: Bool
    // @Default(.useNameCardBGWithGICharacters) private var useNameCardBGWithGICharacters: Bool
    @AppStorage("useGenshinStyleCharacterPhotos", store: .baseSuite) private var useGenshinStyleIcon: Bool = true
    @AppStorage(
        "useNameCardBGWithGICharacters",
        store: .baseSuite
    ) private var useNameCardBGWithGICharacters: Bool = true

    private let isCard: Bool
    private let charID: String
    private let charIDTruncated: String? // 仅原神专用，仅用于确认主角双子。
    private let size: CGFloat
    private let circleClipped: Bool
    private let clipToHead: Bool
    private let game: Enka.GameType
    private let roundRectCornerRadius: CGFloat

    private var cutType: IDPhotoView4HSR.IconType {
        if !circleClipped, !isCard {
            .cutFaceRoundedRect
        } else {
            clipToHead ? .cutHead : .cutShoulder
        }
    }

    private var proposedPhotoAssetName: String {
        switch game {
        case .genshinImpact:
            "gi_character_\(charID)"
        case .starRail:
            "hsr_character_\(charID)"
        case .zenlessZone:
            "zzz_character_\(charID)" // 临时设定。
        }
    }

    private var charIDGuarded: String {
        switch game {
        case .genshinImpact: charIDTruncated ?? charID
        case .starRail: charID
        case .zenlessZone: charID // 临时设定。
        }
    }

    private var useNameCardBackgrounds: Bool {
        switch game {
        case .genshinImpact: useNameCardBGWithGICharacters
        case .starRail: false
        case .zenlessZone: false // 临时设定。
        }
    }

    @MainActor @ViewBuilder private var blankQuestionedView: some View {
        Circle().background(.gray).overlay {
            Text(verbatim: "?").foregroundStyle(.white).fontWeight(.black)
        }.frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
            .compositingGroup()
    }

    @MainActor @ViewBuilder private var namecardBg4GI: some View {
        let wallPaper = Wallpaper.findNameCardForGenshinCharacter(charID: charID)
        wallPaper.image4CellphoneWallpaper
            .resizable()
            .aspectRatio(contentMode: .fill)
            .offset(x: size / -3)
            .apply { content in
                let isProtagonist: Bool = ["10000005", "10000007"].contains(charID.prefix(8))
                if isProtagonist, let element = guessGenshinCharacterElement(id: charID) {
                    content
                        .saturation(0)
                        .colorMultiply(element.themeColor.suiColor)
                        .saturation(0.5)
                        .brightness(0.1)
                } else {
                    content
                }
            }
    }

    private func guessGenshinCharacterElement(id: String) -> Enka.GameElement? {
        let str: String?
        switch id.count {
        case 8...:
            str = Enka.Sputnik.shared.db4GI.characters["\(id.prefix(12))"]?.element
                ?? Enka.Sputnik.shared.db4GI.characters["\(id.prefix(8))"]?.element
        default:
            str = Enka.Sputnik.shared.db4HSR.characters[id]?.element
        }
        guard let str, let element = Enka.GameElement(rawValue: str) else { return nil }
        return element
    }

    @MainActor @ViewBuilder
    private func turnImageAsBlurredBackground4GI(_ image: Image) -> some View {
        ZStack {
            if useNameCardBackgrounds {
                namecardBg4GI
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .rotationEffect(.degrees(180))
                    .blur(radius: 6)
                    .scaleEffect(5, anchor: .center)
                Color.black.opacity(0.265)
                if cutType.pathTotemVisible, let element = guessGenshinCharacterElement(id: charID) {
                    element.localFittingIcon4SUI
                        .scaleEffect(1.5)
                        .colorMultiply(Color(cgColor: element.themeColor))
                        .saturation(0.5)
                        .brightness(0.7)
                        .opacity(0.3)
                }
            }
        }
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG
struct IDPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                VStack {
                    IDPhotoView4HSR(pid: "8004", 128, .cutShoulder)
                    IDPhotoView4HSR(pid: "1218", 128, .cutShoulder) // Should be missing if asset is missing.
                    IDPhotoView4HSR(pid: "1221", 128, .cutShoulder) // Should be missing if asset is missing.
                    IDPhotoView4HSR(pid: "1224", 128, .cutShoulder) // Should be missing if asset is missing.
                }.background(.red)

                VStack {
                    CharacterIconView(charID: "8004", size: 128, circleClipped: true, clipToHead: false)
                    CharacterIconView(charID: "1218", size: 128, circleClipped: true, clipToHead: false)
                    CharacterIconView(charID: "1221", size: 128, circleClipped: true, clipToHead: false)
                    CharacterIconView(charID: "1224", size: 128, circleClipped: true, clipToHead: false)
                }.background(.gray)

                VStack {
                    IDPhotoFallbackView4HSR(pid: "8004", 128, .cutShoulder)
                    IDPhotoFallbackView4HSR(pid: "1218", 128, .cutShoulder)
                    IDPhotoFallbackView4HSR(pid: "1221", 128, .cutShoulder)
                    IDPhotoFallbackView4HSR(pid: "1224", 128, .cutShoulder)
                }.background(.blue)
            }
            HStack(spacing: 14) {
                CharacterIconView(charID: "10000042_204201", size: 128, circleClipped: true, clipToHead: false)
                    .background(.red)
                CharacterIconView(charID: "10000070_207001", size: 128, circleClipped: true, clipToHead: false)
                    .background(.gray)
                CharacterIconView(charID: "10000037_203701", size: 128, circleClipped: true, clipToHead: false)
                    .background(.blue)
            }
        }
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                CharacterIconView(charID: "8004", cardSize: 128)
                CharacterIconView(charID: "1218", cardSize: 128)
                CharacterIconView(charID: "1221", cardSize: 128)
            }
            HStack(spacing: 14) {
                CharacterIconView(charID: "10000042_204201", cardSize: 128)
                CharacterIconView(charID: "10000070_207001", cardSize: 128)
                CharacterIconView(charID: "10000037_203701", cardSize: 128)
            }.frame(minHeight: 128)
        }.padding()
    }
}
#endif
