// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - BattleReportView4GI.TreasuresStarwardType

extension BattleReportView4GI {
    typealias TreasuresStarwardType = HoYo.BattleReport4GI.TreasuresStarwardType
}

extension BattleReportView4GI.TreasuresStarwardType {
    public var asIcon: Image {
        Image(iconFileNameStem, bundle: .module)
    }
}

// MARK: - BattleReportView4GI

public struct BattleReportView4GI: BattleReportView {
    // MARK: Lifecycle

    public init(data: BattleReportData, profile: PZProfileSendable?) {
        self.profile = profile
        self.data = data
        self.summaryMap = Self.getSummaryMap(data: data, profile: profile)
    }

    // MARK: Public

    public typealias SummaryPtr = Enka.AvatarSummarized.SharedPointer
    public typealias BattleReportData = HoYo.BattleReport4GI

    public static let navTitle = "hylKit.battleReportView4GI.navTitle.treasuresStarward".i18nHYLKit
    public static let navTitleTiny = "hylKit.battleReportView4GI.navTitle.treasuresStarward.tiny".i18nHYLKit

    public var data: BattleReportData

    public var body: some View {
        contents
    }

    // MARK: Internal

    @ViewBuilder var contents: some View {
        Form {
            formContents4SpiralAbyss
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                let picker = Picker("".description, selection: $contentType.animation()) {
                    ForEach(TreasuresStarwardType.allCases) { contentTypeCase in
                        Text(verbatim: contentTypeCase.localizedTitle).tag(contentTypeCase)
                    }
                }
                .labelsHidden()
                ViewThatFits(in: .horizontal) {
                    picker
                        .pickerStyle(.segmented)
                        .fixedSize()
                    picker
                        .pickerStyle(.menu)
                        .fixedSize()
                        .blurMaterialBackground(enabled: true) // 在正中心位置时，不是玻璃按钮，所以始终启用。
                        .clipShape(.capsule)
                }
            }
        }
        .onChange(of: broadcaster.eventForUpdatingLocalHoYoLABAvatarCache) {
            Task { @MainActor in
                withAnimation {
                    summaryMap = Self.getSummaryMap(data: data, profile: profile)
                }
            }
        }
    }

    // MARK: Private

    @State private var contentType: TreasuresStarwardType = .spiralAbyss
    @StateObject private var screenVM: ScreenVM = .shared
    @StateObject private var broadcaster = Broadcaster.shared
    @Namespace private var animation
    @State private var summaryMap: [String: SummaryPtr]

    private let profile: PZProfileSendable?

    private var containerWidth: CGFloat {
        screenVM.mainColumnCanvasSizeObserved.width - 48
    }

    private var columns: Int { min(max(Int(floor(containerWidth / 200)), 2), 4) }

    private var data4SA: BattleReportData.SpiralAbyssData { data.spiralAbyss }

    private static func getSummaryMap(
        data: BattleReportData,
        profile: PZProfileSendable?
    )
        -> [String: SummaryPtr] {
        guard let profile else {
            return [:]
        }
        let allCharIDsEnumerated: Set<Int> = data.spiralAbyss.allCharIDsEnumerated
        let theDB = Enka.Sputnik.shared.db4GI
        var summaries: [String: SummaryPtr] = [:]
        let summariesData = HYQueriedModels.HYLAvatarDetail4GI.getLocalHoYoAvatars(
            theDB: theDB, uid: profile.uid
        )
        summariesData.forEach { currentSummary in
            let ucid = currentSummary.mainInfo.uniqueCharId
            guard let intUCID = Int(ucid) else { return }
            guard allCharIDsEnumerated.contains(intUCID) else { return }
            summaries[ucid] = .init(summaryNotNulled: currentSummary)
        }
        return summaries
    }
}

// MARK: - Contents for Spiral Abyss.

extension BattleReportView4GI {
    @ViewBuilder private var formContents4SpiralAbyss: some View {
        stats4SpiralAbyss
        floorList4SpiralAbyss
    }

    @ViewBuilder private var stats4SpiralAbyss: some View {
        Section {
            StaggeredGrid(
                columns: columns,
                outerPadding: false,
                scroll: false,
                list: data4SA.summarizedIntoCells(compact: columns % 2 == 0),
                content: { currentCell in
                    drawAbyssValueCell(currentCell)
                        .id(currentCell.id)
                }
            )
            .environment(screenVM)
        } header: {
            HStack {
                Text("hylKit.battleReport.gi.stat.summary".i18nHYLKit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("hylKit.battleReport.stat.seasonID".i18nHYLKit + " \(data4SA.scheduleID)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder private var floorList4SpiralAbyss: some View {
        ForEach(data4SA.floors.reversed(), id: \.index) { floorData in
            Section {
                VStack {
                    ForEach(floorData.levels, id: \.index) { battleRoom in
                        drawBattleRoom(levelData: battleRoom)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                HStack {
                    Text(
                        "hylKit.battleReport.floor.title:\(floorData.index.description)",
                        bundle: .module
                    )
                    Spacer()
                    Text(verbatim: "\(floorData.star) / \(floorData.maxStar)")
                    Self.drawAbyssStarIcon(size: 16)
                }
            }
            .listRowSeparator(.hidden)
            .listRowMaterialBackground()
        }
    }

    @ViewBuilder
    private func drawBattleRoom(levelData: HoYo.BattleReport4GI.SpiralAbyssData.Floor.Level) -> some View {
        VStack {
            HStack {
                Text("hylKit.battleReport.room.title:\(levelData.index.description)", bundle: .module)
                    .fontWeight(.black)
                Spacer()
                HStack(spacing: 0) {
                    ForEach(1 ... levelData.star, id: \.self) { _ in
                        Self.drawAbyssStarIcon()
                    }
                }
            }
            ViewThatFits(in: .horizontal) {
                drawLevelInnerContents(levelData, vertical: false, hasLabel: true, hasSpacers: true)
                drawLevelInnerContents(levelData, vertical: false, hasLabel: true, hasSpacers: false)
                drawLevelInnerContents(levelData, vertical: false, hasLabel: false, hasSpacers: true)
                drawLevelInnerContents(levelData, vertical: false, hasLabel: false, hasSpacers: false)
                drawLevelInnerContents(levelData, vertical: true, hasLabel: true, hasSpacers: true)
                drawLevelInnerContents(levelData, vertical: true, hasLabel: true, hasSpacers: false)
                drawLevelInnerContents(levelData, vertical: true, hasLabel: false, hasSpacers: true)
                drawLevelInnerContents(levelData, vertical: true, hasLabel: false, hasSpacers: false)
            }
        }
    }

    @ViewBuilder
    func drawLevelInnerContents(
        _ levelData: HoYo.BattleReport4GI.SpiralAbyssData.Floor.Level,
        vertical: Bool,
        hasLabel: Bool,
        hasSpacers: Bool
    )
        -> some View {
        let hasLabel = levelData.battles.count > 1 ? hasLabel : false
        let theContent = Group {
            drawBattleNode(
                levelData.battles[0],
                label: hasLabel ? "hylKit.battleReport.floor.1stHalf".i18nHYLKit : ""
            )
            if levelData.battles.count > 1 {
                if hasSpacers, !vertical { Spacer() }
                drawBattleNode(
                    levelData.battles[1],
                    label: hasLabel ? "hylKit.battleReport.floor.2ndHalf".i18nHYLKit : ""
                )
            }
        }
        if vertical {
            VStack { theContent }
        } else {
            HStack { theContent }
        }
    }

    @ViewBuilder
    private func drawBattleNode(
        _ node: HoYo.BattleReport4GI.SpiralAbyssData.Floor.Level.Battle,
        label: String = "",
        spacers: Bool = true
    )
        -> some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .fontDesign(.monospaced)
            }
            if spacers { Spacer() }
            var guardedAvatars: [HoYo.BattleReport4GI.SpiralAbyssData.Floor.Level.Battle.Avatar] {
                var result = node.avatars
                while result.count < 4 {
                    result.append(.init(id: -114_514, icon: "", level: -213, rarity: 5))
                }
                return result
            }
            ForEach(guardedAvatars) { avatar in
                let decoratedIconSize = decoratedIconSize
                let isNullAvatar: Bool = avatar.id == -114_514
                let maybeSummary = summaryMap[avatar.id.description]
                let maybeID = maybeSummary?.wrappedValue.mainInfo.idExpressable
                Group {
                    if ThisDevice.isHDPhoneOrPodTouch {
                        if isNullAvatar {
                            AnonymousIconView(decoratedIconSize, cutType: .roundRectangle)
                        } else {
                            ZStack {
                                if let maybeID {
                                    maybeID.avatarPhoto(
                                        size: decoratedIconSize,
                                        circleClipped: false,
                                        clipToHead: true
                                    )
                                } else {
                                    CharacterIconView(
                                        charID: avatar.id.description,
                                        size: decoratedIconSize,
                                        circleClipped: false,
                                        clipToHead: true
                                    )
                                }
                            }
                            .corneredTag(
                                verbatim: avatar.level.description,
                                alignment: .bottomTrailing,
                                textSize: 11
                            )
                        }
                    } else {
                        if isNullAvatar {
                            AnonymousIconView(decoratedIconSize / 0.74, cutType: .card)
                        } else {
                            ZStack {
                                if let maybeID {
                                    maybeID.cardIcon(
                                        size: decoratedIconSize / 0.74
                                    )
                                } else {
                                    CharacterIconView(
                                        charID: avatar.id.description,
                                        cardSize: decoratedIconSize / 0.74
                                    )
                                }
                            }
                            .corneredTag(
                                verbatim: "Lv.\(avatar.level.description)",
                                alignment: .bottom,
                                textSize: 11
                            )
                        }
                    }
                }.frame(
                    width: decoratedIconSize,
                    height: ThisDevice.isHDPhoneOrPodTouch ? decoratedIconSize : (decoratedIconSize / 0.74)
                )
                if spacers { Spacer() }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func drawAbyssValueCell(_ cellData: AbyssValueCell) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text(verbatim: cellData.value)
                    .lineLimit(1)
                    .font(.title)
                    .fontWeight(.heavy)
                    .fontWidth(.compressed)
                    .minimumScaleFactor(0.3)
                Text(cellData.description)
                    .lineLimit(1)
                    .font(.caption)
                    .minimumScaleFactor(0.3)
                    .fontWidth(.condensed)
            }
            .frame(maxWidth: .infinity)
            cellData.makeAvatar()
        }
        .frame(maxWidth: .infinity, minHeight: 48)
        .padding(8)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 8, style: .circular)
        )
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        BattleReportView4GI(
            data: try! BattleReportTestAssets.giSACurr.getReport4GI(),
            profile: nil
        ).formStyle(.grouped)
    }
    .environment(\.colorScheme, .dark)
}

#endif
