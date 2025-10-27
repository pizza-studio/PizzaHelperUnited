// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - EachAvatarStatView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct EachAvatarStatView: View {
    // MARK: Lifecycle

    public init(data: Enka.AvatarSummarized, background: Bool = false) {
        self.showBackground = background
        self.data = data
    }

    // MARK: Public

    public let data: Enka.AvatarSummarized

    public var body: some View {
        // 按照 iPhone SE2-SE3 的标准画面解析度（375 × 667）制作。
        VStack(spacing: outerContentSpacing) {
            data.mainInfo.asView(fontSize: fontSize)
            VStack(spacing: 2 * Self.zoomFactor) {
                if let weapon = data.equippedWeapon {
                    WeaponPanelView(for: weapon, fontSize: fontSize)
                }
                renderPropertyGrid()
                artifactRatingSummaryRow
            }
            .padding(.horizontal, 11 * Self.zoomFactor)
            .padding(.vertical, 6 * Self.zoomFactor)
            .background {
                propsPanelBackground
            }
            artifactGrid
        }
        .clipShape(.rect)
        .environment(\.colorScheme, .dark)
        .padding(Self.spacingDeltaAmount * 5)
        .frame(width: 375 * Self.zoomFactor) // 输出画面刚好 375*500，可同时相容于 iPad。
        .padding(Self.spacingDeltaAmount * 2)
        .padding(.vertical, Self.spacingDeltaAmount * 5)
        .background {
            if showBackground {
                ZStack {
                    Color(hue: 0, saturation: 0, brightness: 0.1)
                    data.asBackground()
                        .scaledToFill()
                        .scaleEffect(1.2)
                        .clipped()
                }
                .drawingGroup()
                .ignoresSafeArea(.all)
            }
        }
        .contentShape(.rect)
    }

    // MARK: Internal

    @Default(.artifactRatingRules) var artifactRatingRules: ArtifactRating.Rules

    @ViewBuilder var artifactRatingSummaryRow: some View {
        if artifactRatingRules.contains(.enabled), let ratingResult = data.artifactRatingResult {
            HStack {
                Text(verbatim: " → " + data.mainInfo.terms.artifactRatingName)
                    .fontWidth(.compressed)
                Spacer()
                Text(
                    verbatim: ratingResult.sumExpression
                        + ratingResult.allpt.description
                        + "(\(ratingResult.result))"
                )
                .fontWeight(.bold)
                .fontWidth(.condensed)
            }
            .font(.system(size: fontSize * 0.7))
            .opacity(0.9)
            .padding(.top, 2)
        }
    }

    @ViewBuilder var artifactGrid: some View {
        StaggeredGrid(
            columns: 2,
            showsIndicators: false,
            outerPadding: false,
            scroll: false,
            spacing: outerContentSpacing,
            list: data.artifacts
        ) { currentArtifact in
            currentArtifact.asView(fontSize: fontSize, langTag: data.mainInfo.terms.langTag)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 18 * Self.zoomFactor)
    }

    @ViewBuilder var propsPanelBackground: some View {
        let clipShape: some Shape = .rect(
            cornerSize: CGSize(
                width: fontSize * 0.5,
                height: fontSize * 0.5
            )
        )
        Group {
            Color.black.opacity(0.2)
                .blurMaterialBackground(shape: clipShape)
        }
        .overlay {
            Image(data.isEnka ? "EnkanomiyaAsBG" : "HoYoLABIconAsBG", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.05)
                .padding()
        }
    }

    @ViewBuilder
    func renderPropertyGrid() -> some View {
        let max = data.avatarPropertiesA.count
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            if data.game == .genshinImpact {
                GridRow {
                    AttributeTagPair(
                        icon: Enka.PropertyType.allDamageTypeAddedRatio.iconAssetName,
                        title: "YJSNPI",
                        valueStr: "114514",
                        fontSize: fontSize * 0.8
                    )
                    AttributeTagPair(
                        icon: Enka.PropertyType.allDamageTypeAddedRatio.iconAssetName,
                        title: "YJSNPI",
                        valueStr: "114514",
                        fontSize: fontSize * 0.8
                    )
                }
                .hidden()
                .overlay {
                    Divider().overlay {
                        Color.primary.opacity(0.4)
                    }.frame(maxHeight: 4)
                }
            }

            ForEach(0 ..< max, id: \.self) {
                let property1 = data.avatarPropertiesA[$0]
                let property2 = data.avatarPropertiesB[$0]
                GridRow {
                    AttributeTagPair(
                        icon: property1.type.iconAssetName,
                        title: property1.localizedTitle,
                        valueStr: property1.valueString,
                        fontSize: fontSize * 0.8
                    )
                    AttributeTagPair(
                        icon: property2.type.iconAssetName,
                        title: property2.localizedTitle,
                        valueStr: property2.valueString,
                        fontSize: fontSize * 0.8
                    )
                }
            }
        }
    }

    // MARK: Private

    private static let zoomFactor: CGFloat = 1.66
    private static let spacingDeltaAmount: CGFloat = 5

    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var screenVM: ScreenVM = .shared

    private let showBackground: Bool

    private var shouldOptimizeForPhone: Bool {
        #if os(macOS) || targetEnvironment(macCatalyst)
        return false
        #else
        // ref: https://forums.developer.apple.com/forums/thread/126878
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular): return false
        default: return screenVM.orientation != .landscape && !screenVM.isExtremeCompact
        }
        #endif
    }

    private var fontSize: CGFloat {
        (shouldOptimizeForPhone ? 17 : 15) * Self.zoomFactor
    }

    private var outerContentSpacing: CGFloat {
        (shouldOptimizeForPhone ? 8 : 4) * Self.zoomFactor
    }

    private var innerContentSpacing: CGFloat {
        (shouldOptimizeForPhone ? 4 : 2) * Self.zoomFactor
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.CharacterID {
    @MainActor @ViewBuilder
    public func asRowBG(element: Enka.GameElement? = nil) -> some View {
        switch game {
        case .starRail:
            if let commonCharData = Enka.Sputnik.shared.db4HSR.characters[id],
               let element = Enka.GameElement(rawValue: commonCharData.element),
               let lifePath = Enka.LifePath(rawValue: commonCharData.avatarBaseType) {
                let elementColor = element.themeColor.suiColor
                let bgPath = Enka.queryImageAssetSUI(for: lifePath.iconAssetName)?
                    .resizable()
                    .scaledToFill()
                    .colorMultiply(elementColor)
                    .opacity(0.05)
                bgPath
                    // .frame(maxHeight: 63).clipped()
                    .drawingGroup()
            }
        case .genshinImpact:
            let wallpaper = BundledWallpaper.findNameCardForGenshinCharacter(charID: id)
            wallpaper.image4CellphoneWallpaper
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(Color(Color.colorSystemGray6).opacity(0.5))
                .apply { content in
                    ZStack {
                        if self.isProtagonist || self.isManekin, let element {
                            content
                                .saturation(0)
                                .colorMultiply(element.themeColor.suiColor)
                                .contrast(2)
                                .saturation(0.3)
                                .brightness(0.4)
                        } else {
                            content
                        }
                    }
                    .opacity(0.6)
                    // .frame(maxHeight: 63).clipped()
                    .drawingGroup()
                }
        case .zenlessZone: EmptyView() // 临时设定。
        }
    }

    @MainActor @ViewBuilder
    public func asBackground(useNameCardBG: Bool = false, element: Enka.GameElement? = nil) -> some View {
        if useNameCardBG, game == .genshinImpact {
            let wallpaper = BundledWallpaper.findNameCardForGenshinCharacter(charID: id)
            wallpaper.image4CellphoneWallpaper
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(1.2)
                .ignoresSafeArea(.all)
                .blur(radius: 30)
                .overlay(Color(Color.colorSystemGray6).opacity(0.5))
                .apply { content in
                    ZStack {
                        if self.isProtagonist || self.isManekin, let element {
                            content
                                .saturation(0)
                                .colorMultiply(element.themeColor.suiColor)
                                .contrast(2)
                                .saturation(0.3)
                                .brightness(0.4)
                        } else {
                            content
                        }
                    }
                    .drawingGroup()
                }
        } else {
            localIcon4SUI
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 60)
                .saturation(3)
                .opacity(0.47)
        }
    }

    @ViewBuilder
    public func asPortrait() -> some View {
        localIcon4SUI
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background {
                Color.black.opacity(0.165)
            }
    }

    @MainActor @ViewBuilder
    public func avatarPhoto(
        size: CGFloat,
        circleClipped: Bool = true,
        clipToHead: Bool = false,
        energySavingMode: Bool = false
    )
        -> some View {
        CharacterIconView(
            charID: id,
            size: size,
            circleClipped: circleClipped,
            clipToHead: clipToHead,
            energySavingMode: energySavingMode
        )
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @MainActor @ViewBuilder
    public func cardIcon(size: CGFloat) -> some View {
        CharacterIconView(charID: id, cardSize: size)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized {
    @MainActor @ViewBuilder
    public func asView(background: Bool = false) -> some View {
        EachAvatarStatView(data: self, background: background)
    }

    @MainActor @ViewBuilder
    public func asBackground(useNameCardBG: Bool = false) -> some View {
        mainInfo.idExpressable.asBackground(
            useNameCardBG: useNameCardBG,
            element: mainInfo.element
        )
    }

    @ViewBuilder
    public func asPortrait() -> some View {
        mainInfo.idExpressable.asPortrait()
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @MainActor @ViewBuilder
    public func asCardIcon(_ size: CGFloat)
        -> some View {
        mainInfo.idExpressable.cardIcon(size: size)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo {
    @MainActor @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: fontSize * 0.55) {
            idExpressable.avatarPhoto(size: fontSize * 5)
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    Text(name)
                        .font(.system(size: fontSize * 1.6))
                        .fontWeight(.heavy)
                        .fontWidth(.compressed)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    switch lifePath {
                    case .none:
                        ZStack(alignment: .center) {
                            Color.black.opacity(0.1)
                                .clipShape(.circle)
                            Enka.queryImageAssetSUI(for: element.iconAssetName)?.resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.circle)
                                .opacity(0.9)
                        }.padding(fontSize * 0.3)
                            .frame(
                                width: fontSize * 2.6,
                                height: fontSize * 2
                            )
                    default:
                        ZStack(alignment: .center) {
                            Color.black.opacity(0.1)
                                .clipShape(.circle)
                            Enka.queryImageAssetSUI(for: lifePath.iconAssetName)?.resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.circle)
                        }.frame(
                            width: fontSize * 2.6,
                            height: fontSize * 2
                        ).overlay(alignment: .bottomTrailing) {
                            ZStack(alignment: .center) {
                                Color.black.opacity(0.05)
                                    .clipShape(.circle)
                                Enka.queryImageAssetSUI(for: element.iconAssetName)?.resizable()
                                    .brightness(0.1)
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(.circle)
                            }.frame(
                                width: fontSize * 0.95,
                                height: fontSize * 0.95
                            )
                            .background {
                                Color.black
                                    .opacity(0.3)
                                    .blurMaterialBackground(shape: .circle)
                            }
                        }
                    }
                }
                HStack {
                    VStack(spacing: 1) {
                        AttributeTagPair(
                            title: terms.levelName, valueStr: self.avatarLevel.description,
                            fontSize: fontSize * 0.8
                        )
                        let constUnitName = switch self.game {
                        case .genshinImpact: "C"
                        case .starRail: "E"
                        case .zenlessZone: "M"
                        }
                        AttributeTagPair(
                            title: terms.constellationName, valueStr: "\(constUnitName)\(self.constellation)",
                            fontSize: fontSize * 0.8
                        )
                    }
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        let baseSkillsArray = baseSkills.toArray
                        if game == .genshinImpact {
                            // 排版占位符
                            baseSkillsArray.first?.asView(fontSize: fontSize).fixedSize().opacity(0)
                        }
                        ForEach(baseSkillsArray.prefix(availableSkillsPrefixNumber), id: \.type) { skill in
                            skill.asView(fontSize: fontSize).fixedSize()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.5)
                }.fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var availableSkillsPrefixNumber: Int {
        switch game {
        case .genshinImpact: 3
        case .starRail: 4
        case .zenlessZone: 4 // 临时设定。
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill {
    @ViewBuilder
    func levelDisplay(size: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(verbatim: "\(baseLevel)").font(.system(size: size * 0.8, weight: .heavy))
            if let additionalLevel = self.levelAddition {
                Text(verbatim: "+\(additionalLevel)").font(.system(size: size * 0.65, weight: .black))
            }
        }
        .foregroundStyle(.white) // Always use white color for the text of these information.
    }

    @MainActor @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            VStack {
                ZStack(alignment: .center) {
                    Color.black.opacity(0.1)
                        .clipShape(.circle)
                    Enka.queryImageAssetSUI(for: iconAssetName)?.resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.circle)
                        .scaleEffect(0.8)
                        .blendMode(.colorDodge)
                }.frame(
                    width: fontSize * 2.2,
                    height: fontSize * 2
                )
                Spacer()
            }
            // 这里不用 corneredTag，因为要动态调整图示与等级数字之间的显示距离。
            // 而且 skill.levelDisplay 也不是纯文本，而是 some View。
            ZStack(alignment: .center) {
                Color.black.opacity(0.1)
                    .clipShape(Capsule())
                levelDisplay(size: fontSize * 0.9)
                    .padding(.horizontal, 4)
            }.frame(height: fontSize).fixedSize()
        }
    }
}

// MARK: - WeaponPanelView

@available(iOS 17.0, macCatalyst 17.0, *)
private struct WeaponPanelView: View {
    // MARK: Lifecycle

    public init(for weapon: Enka.AvatarSummarized.WeaponPanel, fontSize: CGFloat) {
        self.fontSize = fontSize
        self.weapon = weapon
        self.iconImg = weapon.localIcon4SUI
    }

    // MARK: Public

    public var body: some View {
        HStack(spacing: fontSize * 0.4) {
            background
                .frame(width: fontSize * 4.46, height: fontSize * 4.46)
                .overlay {
                    iconImg?
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .corneredTag(
                    verbatim: corneredTagText,
                    alignment: .bottom, textSize: fontSize * 0.8
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(weapon.localizedName)
                    .font(.system(size: fontSize, weight: .bold))
                    .fontWidth(.compressed)
                Divider().overlay {
                    Color.primary.opacity(0.4)
                }.padding(.vertical, 2)
                HStack {
                    ForEach(weapon.basicProps, id: \.type) { propUnit in
                        AttributeTagPair(
                            icon: propUnit.iconAssetName,
                            title: shouldShowPropertyTitle ? propUnit.localizedTitle : "",
                            valueStr: "+\(propUnit.valueString)",
                            fontSize: fontSize * 0.8
                        ).fixedSize(horizontal: !shouldShowPropertyTitle, vertical: true)
                    }
                }
                HStack {
                    ForEach(weapon.specialProps, id: \.type) { propUnit in
                        AttributeTagPair(
                            icon: propUnit.iconAssetName,
                            title: shouldShowPropertyTitle ? propUnit.localizedTitle : "",
                            valueStr: "+\(propUnit.valueString)",
                            fontSize: fontSize * 0.8
                        ).fixedSize(horizontal: !shouldShowPropertyTitle, vertical: true)
                    }
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Internal

    var corneredTagText: String {
        "Lv.\(weapon.trainedLevel) ★\(weapon.rarityStars) ❖\(weapon.refinement)"
    }

    var shouldShowPropertyTitle: Bool {
        weapon.game == .genshinImpact
    }

    @ViewBuilder var background: some View {
        switch weapon.game {
        case .starRail:
            Color.primary.opacity(0.075)
                .clipShape(.circle)
        case .genshinImpact:
            ZStack {
                Color.gray.opacity(0.075)
                    .clipShape(.circle)
                weapon.localFittingIcon4SUI
                    .scaleEffect(4)
                    .offset(y: -10)
                    .blur(radius: 5)
                    .saturation(0.5)
                    .brightness(-0.1)
                    .opacity(0.5)
            }
            .clipShape(.circle)
        case .zenlessZone: EmptyView() // 临时设定。
        }
    }

    // MARK: Private

    private let weapon: Enka.AvatarSummarized.WeaponPanel
    private let fontSize: CGFloat
    private let iconImg: Image?
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.WeaponPanel {
    @MainActor @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        WeaponPanelView(for: self, fontSize: fontSize)
    }
}

// MARK: - ArtifactView

@available(iOS 17.0, macCatalyst 17.0, *)
private struct ArtifactView: View {
    // MARK: Lifecycle

    public init(
        _ artifact: Enka.AvatarSummarized.ArtifactInfo,
        fontSize: CGFloat,
        langTag: String
    ) {
        self.artifact = artifact
        self.fontSize = fontSize
        self.langTag = langTag
    }

    // MARK: Public

    public var body: some View {
        coreBody(fontSize: fontSize, langTag: langTag)
            .padding(.vertical, fontSize * 0.13)
            .padding(.horizontal, fontSize * 0.3)
            .background {
                Color.black.opacity(0.2)
                    .blurMaterialBackground(shape: backgroundClipShape)
            }
    }

    // MARK: Private

    @State private var artifact: Enka.AvatarSummarized.ArtifactInfo
    @State private var fontSize: CGFloat
    @State private var langTag: String

    @Default(.colorizeArtifactSubPropCounts) private var colorizeArtifactSubPropCounts: Bool
    @Default(.artifactRatingRules) private var artifactRatingRules: ArtifactRating.Rules

    private var backgroundClipShape: some Shape {
        .rect(cornerSize: .init(width: fontSize * 0.5, height: fontSize * 0.5))
    }

    @ViewBuilder
    private func coreBody(fontSize: CGFloat, langTag: String) -> some View {
        HStack(alignment: .top) {
            Color.clear.frame(width: fontSize * 2.6)
            VStack(spacing: 0) {
                AttributeTagPair(
                    icon: artifact.mainProp.iconAssetName,
                    title: "",
                    valueStr: artifact.mainProp.valueString,
                    fontSize: fontSize * 0.86
                )
                Divider().overlay {
                    Color.primary.opacity(0.6)
                }
                StaggeredGrid(
                    columns: 2,
                    showsIndicators: false,
                    outerPadding: false,
                    scroll: false,
                    spacing: 0,
                    list: artifact.subProps
                ) { prop in
                    let propDisplay = HStack(spacing: 0) {
                        Enka.queryImageAssetSUI(for: prop.iconAssetName)?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: fontSize * 1.25, height: fontSize * 1.25)
                        Text(prop.valueString)
                            .lineLimit(1)
                            .font(.system(size: fontSize * 0.86))
                            .fontWidth(.compressed)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: .infinity)

                    if colorizeArtifactSubPropCounts {
                        propDisplay
                            .colorMultiply(colorToMultiply(on: prop))
                    } else {
                        propDisplay
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: fontSize * 4)
        .fixedSize(horizontal: false, vertical: true)
        .corneredTag(
            verbatim: "Lv.\(artifact.trainedLevel) ★\(artifact.rarityStars)",
            alignment: .bottomLeading, textSize: fontSize * 0.7
        )
        .background(alignment: .topLeading) {
            handleArtifactIcon(fontSize: fontSize, content: artifact.localFittingIcon4SUI)
                .opacity(0.9)
                .corneredTag(
                    verbatim: scoreText(lang: langTag),
                    alignment: .bottomLeading, textSize: fontSize * 0.8
                )
                .scaleEffect(0.8, anchor: .topLeading)
        }
    }

    @ViewBuilder
    private func handleArtifactIcon(fontSize: CGFloat, content: (some View)?) -> some View {
        if artifact.game == .starRail {
            content
        } else {
            content?
                .frame(width: fontSize * 4.5, height: fontSize * 4.5)
                .clipped()
                .scaledToFit()
                .frame(width: fontSize * 4, height: fontSize * 4)
        }
    }

    private func scoreText(lang: String) -> String {
        guard artifactRatingRules.contains(.enabled) else { return "" }
        let extraTerms = Enka.ExtraTerms(lang: lang, game: artifact.game)
        let unit = extraTerms.artifactRatingUnit
        if let score = artifact.ratedScore?.description {
            return score + unit
        }
        return ""
    }

    @MainActor
    private func colorToMultiply(on subProp: Enka.PVPair) -> Color {
        guard colorizeArtifactSubPropCounts else { return .primary }
        return switch subProp.count {
        case 1: .primary.opacity(0.6)
        case 2: .primary
        case 3: .orange.opacity(0.95)
        case 4: .yellow.opacity(0.95)
        case 5 ..< 10: .red.opacity(0.95)
        case 10...: .brown
        default: .secondary.opacity(0.1)
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.ArtifactInfo {
    @MainActor @ViewBuilder
    public func asView(fontSize: CGFloat, langTag: String) -> some View {
        ArtifactView(self, fontSize: fontSize, langTag: langTag)
    }
}

// MARK: - AttributeTagPair

@available(iOS 17.0, macCatalyst 17.0, *)
public struct AttributeTagPair: View {
    // MARK: Lifecycle

    public init(
        icon iconAssetName: String? = nil,
        title: String,
        valueStr: String,
        fontSize givenFontSize: CGFloat
    ) {
        self.title = title
        self.valueStr = valueStr
        self.fontSize = givenFontSize
        self.shortenedTitle = {
            var title = title
            Enka.GameElement.elementConversionDict.forEach { key, value in
                title = title.replacingOccurrences(of: key, with: value)
            }
            let suffix = title.count > 18 ? "…" : ""
            return "\(title.prefix(18))\(suffix)"
        }()

        if let iconAssetName = iconAssetName, let img = Enka.queryImageAssetSUI(for: iconAssetName) {
            self.iconImg = img.resizable()
        } else {
            self.iconImg = nil
        }
    }

    // MARK: Public

    public let title: String
    public let valueStr: String
    public let fontSize: CGFloat
    public let shortenedTitle: String
    public let iconImg: Image?

    public var body: some View {
        HStack(spacing: 0) {
            iconImg?
                .aspectRatio(contentMode: .fit)
                .frame(width: fontSize * 1.5, height: fontSize * 1.5)
            Text(shortenedTitle)
                .fixedSize()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Spacer().frame(minWidth: 1)
            Text(valueStr)
                .fixedSize()
                .lineLimit(1)
                .font(.system(size: fontSize))
                .fontWidth(.compressed)
                .fontWeight(.bold)
                .padding(.horizontal, 5)
                .background {
                    Color.secondary.opacity(0.2).clipShape(.capsule)
                }
        }.font(.system(size: fontSize))
            .fontWidth(.compressed)
            .fontWeight(.regular)
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor private let summariesHSR: [Enka.AvatarSummarized] = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    let enkaDatabase = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
    let profile = try! Enka.QueriedResultHSR.exampleData()
    let summaries = profile.detailInfo!.avatarDetailList.compactMap { $0.summarize(theDB: enkaDatabase) }
    return summaries
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor private let summariesGI: [Enka.AvatarSummarized] = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    let enkaDatabase = try! Enka.EnkaDB4GI(locTag: "zh-tw")
    let profile = try! Enka.QueriedResultGI.exampleData()
    let summaries = profile.detailInfo!.avatarDetailList.compactMap { $0.summarize(theDB: enkaDatabase) }
    return summaries
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor private let summariesHSRofHoYoLAB: [Enka.AvatarSummarized] = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    let enkaDatabase = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
    let profile = try! HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
    let summaries = profile.avatarList.compactMap { $0.summarize(theDB: enkaDatabase) }
    return summaries
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor private let summariesGIofHoYoLAB: [Enka.AvatarSummarized] = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    let enkaDatabase = try! Enka.EnkaDB4GI(locTag: "zh-tw")
    let profile = try! HYQueriedModels.HYLAvatarDetail4GI.exampleData()
    let summaries = profile.avatarList.compactMap { $0.summarize(theDB: enkaDatabase) }
    return summaries
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    TabView {
        TabView {
            ForEach(summariesGIofHoYoLAB) { summary in
                summary.asView(background: true)
                    .tabItem {
                        Text(summary.mainInfo.name)
                    }
            }
        }.tabItem { Text(verbatim: "GI_HoYoLAB") }
        TabView {
            ForEach(summariesHSRofHoYoLAB) { summary in
                summary.asView(background: true)
                    .tabItem {
                        Text(summary.mainInfo.name)
                    }
            }
        }.tabItem { Text(verbatim: "HSR_HoYoLAB") }
        TabView {
            ForEach(summariesGI) { summary in
                summary.asView(background: true)
                    .tabItem {
                        Text(summary.mainInfo.name)
                    }
            }
        }.tabItem { Text(verbatim: "GI_Enka") }
        TabView {
            ForEach(summariesHSR) { summary in
                summary.asView(background: true)
                    .tabItem {
                        Text(summary.mainInfo.name)
                    }
            }
        }.tabItem { Text(verbatim: "HSR_Enka") }
    }.fixedSize().clipped()
}

#endif
