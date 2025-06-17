// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportView4HSR.TreasuresLightwardType

extension AbyssReportView4HSR {
    typealias TreasuresLightwardType = HoYo.AbyssReport4HSR.TreasuresLightwardType
}

extension AbyssReportView4HSR.TreasuresLightwardType {
    public var asIcon: Image {
        Image(iconFileNameStem, bundle: .module)
    }
}

// MARK: - AbyssReportView4HSR

public struct AbyssReportView4HSR: AbyssReportView {
    // MARK: Lifecycle

    public init(data: AbyssReportData, profile: PZProfileSendable?) {
        self.data = data
        _ = profile // 目前暫無需求。
    }

    // MARK: Public

    public typealias AbyssReportData = HoYo.AbyssReport4HSR

    public static let navTitle = "hylKit.abyssReportView4HSR.navTitle.treasuresLightward".i18nHYLKit
    public static let navTitleTiny = "hylKit.abyssReportView4HSR.navTitle.treasuresLightward.tiny".i18nHYLKit

    public static var abyssIcon: Image { Image("hsr_abyss_ForgottenHall", bundle: .module) }

    public var data: AbyssReportData

    public var body: some View {
        Form {
            if data4FH.hasData {
                contents
            } else {
                blankView
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .principal) {
                let picker = Picker("".description, selection: $contentType.animation()) {
                    ForEach(TreasuresLightwardType.allCases) { contentTypeCase in
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
            switch contentType {
            case .forgottenHall:
                LabeledContent {
                    Text(verbatim: data4FH.maxFloorNumStr)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.maxFloorConquered".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4FH.starNum.description)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.starsGained".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4FH.battleNum.description)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.numOfBattles".i18nHYLKit)
                }
            case .pureFiction:
                LabeledContent {
                    Text(verbatim: data4PF.maxFloorNumStr)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.maxFloorConquered".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4PF.starNum.description)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.starsGained".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4PF.battleNum.description)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.numOfBattles".i18nHYLKit)
                }
            case .apocalypticShadow:
                LabeledContent {
                    Text(verbatim: data4AS.maxFloorNumStr)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.maxFloorConquered".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4AS.starNum.description)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.starsGained".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4AS.battleNum.description)
                } label: {
                    Text("hylKit.abyssReport.hsr.stat.numOfBattles".i18nHYLKit)
                }
            }
        } header: {
            HStack {
                Text("hylKit.abyssReport.hsr.stats.header".i18nHYLKit)
                Spacer()
                if contentType == .forgottenHall {
                    Text("hylKit.abyssReport.hsr.stat.seasonID".i18nHYLKit + " \(data4FH.scheduleID)")
                }
            }
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder var floorList: some View {
        switch contentType {
        case .forgottenHall:
            ForEach(data4FH.allFloorDetail.trimmed, id: \.mazeID) { floorData in
                Section {
                    if floorData.isSkipped {
                        Text("hylKit.abyssReport.floor.thisFloorIsSkipped".i18nHYLKit)
                    } else {
                        ViewThatFits(in: .horizontal) {
                            drawFloorInnerContents4FH(floorData, vertical: false, hasLabel: true, hasSpacers: true)
                            drawFloorInnerContents4FH(floorData, vertical: false, hasLabel: true, hasSpacers: false)
                            drawFloorInnerContents4FH(floorData, vertical: false, hasLabel: false, hasSpacers: true)
                            drawFloorInnerContents4FH(floorData, vertical: false, hasLabel: false, hasSpacers: false)
                            drawFloorInnerContents4FH(floorData, vertical: true, hasLabel: true, hasSpacers: true)
                            drawFloorInnerContents4FH(floorData, vertical: true, hasLabel: true, hasSpacers: false)
                            drawFloorInnerContents4FH(floorData, vertical: true, hasLabel: false, hasSpacers: true)
                            drawFloorInnerContents4FH(floorData, vertical: true, hasLabel: false, hasSpacers: false)
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
                        if let challengeTime = floorData.node1.challengeTime {
                            Text(verbatim: challengeTime.description)
                        }
                        HStack(spacing: 0) {
                            ForEach(Array(repeating: 0, count: floorData.starNum), id: \.self) { _ in
                                Self.drawAbyssStarIcon()
                            }
                        }
                    }
                }
                .listRowMaterialBackground()
            }
        case .pureFiction:
            ForEach(data4PF.allFloorDetail.trimmed, id: \.mazeID) { floorData in
                Section {
                    if floorData.isSkipped {
                        Text("hylKit.abyssReport.floor.thisFloorIsSkipped".i18nHYLKit)
                    } else {
                        ViewThatFits(in: .horizontal) {
                            drawFloorInnerContents4PF(floorData, vertical: false, hasLabel: true, hasSpacers: true)
                            drawFloorInnerContents4PF(floorData, vertical: false, hasLabel: true, hasSpacers: false)
                            drawFloorInnerContents4PF(floorData, vertical: false, hasLabel: false, hasSpacers: true)
                            drawFloorInnerContents4PF(floorData, vertical: false, hasLabel: false, hasSpacers: false)
                            drawFloorInnerContents4PF(floorData, vertical: true, hasLabel: true, hasSpacers: true)
                            drawFloorInnerContents4PF(floorData, vertical: true, hasLabel: true, hasSpacers: false)
                            drawFloorInnerContents4PF(floorData, vertical: true, hasLabel: false, hasSpacers: true)
                            drawFloorInnerContents4PF(floorData, vertical: true, hasLabel: false, hasSpacers: false)
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
                        if let challengeTime = floorData.node1.challengeTime {
                            Text(verbatim: challengeTime.description)
                        }
                        HStack(spacing: 0) {
                            let starNumInt = floorData.starNum
                            ForEach(Array(repeating: 0, count: starNumInt), id: \.self) { _ in
                                Self.drawAbyssStarIcon()
                            }
                        }
                    }
                }
                .listRowMaterialBackground()
            }
        case .apocalypticShadow:
            ForEach(data4AS.allFloorDetail.trimmed, id: \.mazeID) { floorData in
                Section {
                    if floorData.isSkipped {
                        Text("hylKit.abyssReport.floor.thisFloorIsSkipped".i18nHYLKit)
                    } else {
                        ViewThatFits(in: .horizontal) {
                            drawFloorInnerContents4AS(floorData, vertical: false, hasLabel: true, hasSpacers: true)
                            drawFloorInnerContents4AS(floorData, vertical: false, hasLabel: true, hasSpacers: false)
                            drawFloorInnerContents4AS(floorData, vertical: false, hasLabel: false, hasSpacers: true)
                            drawFloorInnerContents4AS(floorData, vertical: false, hasLabel: false, hasSpacers: false)
                            drawFloorInnerContents4AS(floorData, vertical: true, hasLabel: true, hasSpacers: true)
                            drawFloorInnerContents4AS(floorData, vertical: true, hasLabel: true, hasSpacers: false)
                            drawFloorInnerContents4AS(floorData, vertical: true, hasLabel: false, hasSpacers: true)
                            drawFloorInnerContents4AS(floorData, vertical: true, hasLabel: false, hasSpacers: false)
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
                        if let challengeTime = floorData.node1.challengeTime {
                            Text(verbatim: challengeTime.description)
                        }
                        HStack(spacing: 0) {
                            let starNumInt = Int(floorData.starNum) ?? 0
                            ForEach(Array(repeating: 0, count: starNumInt), id: \.self) { _ in
                                Self.drawAbyssStarIcon()
                            }
                        }
                    }
                }
                .listRowMaterialBackground()
            }
        }
    }

    @ViewBuilder
    func drawFloorInnerContents4FH(
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
    func drawFloorInnerContents4PF(
        _ floorData: HoYo.AbyssReport4HSR.PFFloorDetail,
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
    func drawFloorInnerContents4AS(
        _ floorData: HoYo.AbyssReport4HSR.ASFloorDetail,
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

    // MARK: Private

    @State private var contentType: TreasuresLightwardType = .forgottenHall

    private var data4FH: AbyssReportData.ForgottenHallData { data.forgottenHall }

    private var data4AS: AbyssReportData.ApocalypticShadowData { data.apocalypticShadow }

    private var data4PF: AbyssReportData.PureFictionData { data.pureFiction }
}

#if DEBUG

#Preview {
    NavigationStack {
        AbyssReportView4HSR(
            data: try! AbyssReportTestAssets.getReport4HSR(),
            profile: nil
        ).formStyle(.grouped)
    }
    .environment(\.colorScheme, .dark)
}

#endif
