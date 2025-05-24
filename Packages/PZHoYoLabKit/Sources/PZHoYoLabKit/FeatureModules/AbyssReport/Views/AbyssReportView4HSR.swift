// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportView4HSR

public struct AbyssReportView4HSR: AbyssReportView {
    // MARK: Lifecycle

    public init(data: AbyssReportData, profile: PZProfileSendable?) {
        self.data = data
        _ = profile // 目前暫無需求。
    }

    // MARK: Public

    public typealias AbyssReportData = HoYo.AbyssReport4HSR

    public static let navTitle = "hylKit.abyssReportView4HSR.navTitle".i18nHYLKit
    public static let navTitleTiny = "hylKit.abyssReportView4HSR.navTitle.tiny".i18nHYLKit

    public static var abyssIcon: Image { Image("hsr_abyss", bundle: .module) }

    public var data: AbyssReportData

    public var body: some View {
        Form {
            if data.hasData {
                contents
            } else {
                blankView
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    // MARK: Internal

    @ViewBuilder var blankView: some View {
        Section {
            Text(verbatim: "hylKit.abyssReport.noDataAvailableForThisSeason".i18nHYLKit)
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder var contents: some View {
        stats
        floorList
    }

    @ViewBuilder var stats: some View {
        Section {
            LabeledContent {
                Text(verbatim: data.maxFloorNumStr)
            } label: {
                Text("hylKit.abyssReport.hsr.stat.maxFloorConquered".i18nHYLKit)
            }
            LabeledContent {
                Text(verbatim: data.starNum.description)
            } label: {
                Text("hylKit.abyssReport.hsr.stat.starsGained".i18nHYLKit)
            }
            LabeledContent {
                Text(verbatim: data.battleNum.description)
            } label: {
                Text("hylKit.abyssReport.hsr.stat.numOfBattles".i18nHYLKit)
            }
        } header: {
            HStack {
                Text("hylKit.abyssReport.hsr.stats.header".i18nHYLKit)
                Spacer()
                Text("hylKit.abyssReport.hsr.stat.seasonID".i18nHYLKit + " \(data.scheduleID)")
            }
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder var floorList: some View {
        ForEach(data.allFloorDetail.trimmed, id: \.mazeID) { floorData in
            Section {
                if floorData.isSkipped {
                    Text("hylKit.abyssReport.floor.thisFloorIsSkipped".i18nHYLKit)
                } else {
                    ViewThatFits(in: .horizontal) {
                        drawFloorInnerContents(floorData, vertical: false, hasLabel: true, hasSpacers: true)
                        drawFloorInnerContents(floorData, vertical: false, hasLabel: true, hasSpacers: false)
                        drawFloorInnerContents(floorData, vertical: false, hasLabel: false, hasSpacers: true)
                        drawFloorInnerContents(floorData, vertical: false, hasLabel: false, hasSpacers: false)
                        drawFloorInnerContents(floorData, vertical: true, hasLabel: true, hasSpacers: true)
                        drawFloorInnerContents(floorData, vertical: true, hasLabel: true, hasSpacers: false)
                        drawFloorInnerContents(floorData, vertical: true, hasLabel: false, hasSpacers: true)
                        drawFloorInnerContents(floorData, vertical: true, hasLabel: false, hasSpacers: false)
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                HStack {
                    Text(
                        "hylKit.abyssReport.floor.title:\(floorData.floorNumStr)",
                        bundle: .module
                    )
                    Spacer()
                    Text(verbatim: floorData.node1.challengeTime.description)
                    HStack(spacing: 0) {
                        ForEach(Array(repeating: 0, count: floorData.starNum), id: \.self) { _ in
                            Self.drawAbyssStarIcon()
                        }
                    }
                }
            }
            .listRowMaterialBackground()
        }
    }

    @ViewBuilder
    func drawFloorInnerContents(
        _ floorData: HoYo.AbyssReport4HSR.FHFloorDetail,
        vertical: Bool,
        hasLabel: Bool,
        hasSpacers: Bool
    )
        -> some View {
        if floorData.isSkipped {
            Text("hylKit.abyssReport.floor.thisFloorIsSkipped".i18nHYLKit)
        } else {
            let theContent = Group {
                drawBattleNode(
                    floorData.node1,
                    label: hasLabel ? "hylKit.abyssReport.floor.1stHalf".i18nHYLKit : ""
                )
                if hasSpacers, !vertical { Spacer() }
                drawBattleNode(
                    floorData.node2,
                    label: hasLabel ? "hylKit.abyssReport.floor.2ndHalf".i18nHYLKit : ""
                )
            }
            if vertical {
                LazyVStack { theContent }
            } else {
                HStack { theContent }
            }
        }
    }

    @ViewBuilder
    func drawBattleNode(_ node: HoYo.AbyssReport4HSR.FHNode, label: String = "", spacers: Bool = true) -> some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .fontDesign(.monospaced)
            }
            if spacers { Spacer() }
            var guardedAvatars: [HoYo.AbyssReport4HSR.FHAvatar] {
                var result = node.avatars
                while result.count < 4 {
                    result.append(.init(id: -114_514, level: 0, icon: "", rarity: 0, element: "", eidolon: 0))
                }
                return result
            }
            ForEach(guardedAvatars) { avatar in
                let decoratedIconSize = decoratedIconSize
                let isNullAvatar: Bool = avatar.id == -114_514
                Group {
                    if ThisDevice.isHDPhoneOrPodTouch {
                        if isNullAvatar {
                            AnonymousIconView(decoratedIconSize, cutType: .roundRectangle)
                        } else {
                            CharacterIconView(
                                charID: avatar.id.description,
                                size: decoratedIconSize,
                                circleClipped: false,
                                clipToHead: true
                            )
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
                            CharacterIconView(charID: avatar.id.description, cardSize: decoratedIconSize / 0.74)
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
}

#if DEBUG

#Preview {
    NavigationStack {
        AbyssReportView4HSR(
            data: try! AbyssReportTestAssets.hsrCurr.getReport4HSR(),
            profile: nil
        ).formStyle(.grouped)
    }
    .environment(\.colorScheme, .dark)
}

#endif
