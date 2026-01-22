// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - BattleReportView4HSR.TreasuresLightwardType

@available(iOS 17.0, macCatalyst 17.0, *)
extension BattleReportView4HSR {
    typealias TreasuresLightwardType = HoYo.BattleReport4HSR.TreasuresLightwardType
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension BattleReportView4HSR.TreasuresLightwardType {
    public var asIcon: Image {
        Image(iconFileNameStem, bundle: .currentSPM)
    }
}

// MARK: - BattleReportView4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
public struct BattleReportView4HSR: BattleReportView {
    // MARK: Lifecycle

    public init(data: BattleReportData, profile: PZProfileSendable?) {
        self.data = data
        _ = profile // 目前暫無需求。
    }

    // MARK: Public

    public typealias BattleReportData = HoYo.BattleReport4HSR

    public static let navTitle = "hylKit.battleReportView4HSR.navTitle.treasuresLightward".i18nHYLKit
    public static let navTitleTiny = "hylKit.battleReportView4HSR.navTitle.treasuresLightward.tiny".i18nHYLKit

    public var data: BattleReportData

    public var body: some View {
        Form {
            if data4FH.hasData || data4AS.hasData || data4PF.hasData {
                contents
                    .frame(width: containerWidth)
                    .animation(.default, value: screenVM.mainColumnCanvasSizeObserved)
            } else {
                blankView
            }
        }
        .formStyle(.grouped).disableFocusable()
        .scrollContentBackground(.hidden)
        .navigationTitle(contentType.localizedTitle)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker(selection: $contentType.animation()) {
                    ForEach(TreasuresLightwardType.allCases) { contentTypeCase in
                        Text(verbatim: contentTypeCase.localizedTitle).tag(contentTypeCase)
                    }
                } label: {
                    LabeledContent {
                        Text("hylKit.battleReportView.challengeType", bundle: .currentSPM)
                    } label: {
                        Image(systemSymbol: .line3HorizontalDecreaseCircle)
                    }
                    .fixedSize()
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .blurMaterialBackground(shape: .capsule, interactive: true)
            }
        }
    }

    // MARK: Internal

    @ViewBuilder var blankView: some View {
        Section {
            Text(verbatim: "hylKit.battleReport.noDataAvailableForThisSeason".i18nHYLKit)
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
                    Text("hylKit.battleReport.hsr.stat.maxFloorConquered".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4FH.starNum.description)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.starsGained".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4FH.battleNum.description)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.numOfBattles".i18nHYLKit)
                }
            case .pureFiction:
                LabeledContent {
                    Text(verbatim: data4PF.maxFloorNumStr)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.maxFloorConquered".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4PF.starNum.description)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.starsGained".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4PF.battleNum.description)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.numOfBattles".i18nHYLKit)
                }
            case .apocalypticShadow:
                LabeledContent {
                    Text(verbatim: data4AS.maxFloorNumStr)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.maxFloorConquered".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4AS.starNum.description)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.starsGained".i18nHYLKit)
                }
                LabeledContent {
                    Text(verbatim: data4AS.battleNum.description)
                } label: {
                    Text("hylKit.battleReport.hsr.stat.numOfBattles".i18nHYLKit)
                }
            }
        } header: {
            HStack {
                Text("hylKit.battleReport.hsr.stats.header".i18nHYLKit)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if contentType == .forgottenHall {
                    Text("hylKit.battleReport.stat.seasonID".i18nHYLKit + " \(data4FH.scheduleID)")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .listRowMaterialBackground()
    }

    @ViewBuilder var floorList: some View {
        switch contentType {
        case .forgottenHall:
            ForEach(data4FH.allFloorDetail.trimmed, id: \.mazeID) { floorData in
                Section {
                    if floorData.isSkipped {
                        Text("hylKit.battleReport.floor.thisFloorIsSkipped".i18nHYLKit)
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
                            "hylKit.battleReport.floor.title:\(floorData.floorNumStr)",
                            bundle: .currentSPM
                        )
                        Spacer()
                        if let challengeTime = floorData.node1.challengeTime {
                            Text(verbatim: challengeTime.description)
                        }
                        if floorData.starNum > 0 {
                            HStack(spacing: 0) {
                                ForEach(1 ... floorData.starNum, id: \.self) { _ in
                                    Self.drawAbyssStarIcon()
                                }
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
                        Text("hylKit.battleReport.floor.thisFloorIsSkipped".i18nHYLKit)
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
                            "hylKit.battleReport.floor.title:\(floorData.floorNumStr)",
                            bundle: .currentSPM
                        )
                        Spacer()
                        if let challengeTime = floorData.node1.challengeTime {
                            Text(verbatim: challengeTime.description)
                        }

                        let starNumInt = floorData.starNum
                        if starNumInt > 0 {
                            HStack(spacing: 0) {
                                ForEach(1 ... starNumInt, id: \.self) { _ in
                                    Self.drawAbyssStarIcon()
                                }
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
                        Text("hylKit.battleReport.floor.thisFloorIsSkipped".i18nHYLKit)
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
                            "hylKit.battleReport.floor.title:\(floorData.floorNumStr)",
                            bundle: .currentSPM
                        )
                        Spacer()
                        if let challengeTime = floorData.node1.challengeTime {
                            Text(verbatim: challengeTime.description)
                        }
                        let starNumInt = Int(floorData.starNum) ?? 0
                        if starNumInt > 0 {
                            HStack(spacing: 0) {
                                ForEach(1 ... starNumInt, id: \.self) { _ in
                                    Self.drawAbyssStarIcon()
                                }
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
        _ floorData: HoYo.BattleReport4HSR.FHFloorDetail,
        vertical: Bool,
        hasLabel: Bool,
        hasSpacers: Bool
    )
        -> some View {
        if floorData.isSkipped {
            Text("hylKit.battleReport.floor.thisFloorIsSkipped".i18nHYLKit)
        } else {
            let theContent = Group {
                drawBattleNode(
                    floorData.node1,
                    label: hasLabel ? "hylKit.battleReport.floor.1stHalf".i18nHYLKit : ""
                )
                if hasSpacers, !vertical { Spacer() }
                drawBattleNode(
                    floorData.node2,
                    label: hasLabel ? "hylKit.battleReport.floor.2ndHalf".i18nHYLKit : ""
                )
            }
            if vertical {
                VStack { theContent }
            } else {
                HStack { theContent }
            }
        }
    }

    @ViewBuilder
    func drawFloorInnerContents4PF(
        _ floorData: HoYo.BattleReport4HSR.PFFloorDetail,
        vertical: Bool,
        hasLabel: Bool,
        hasSpacers: Bool
    )
        -> some View {
        if floorData.isSkipped {
            Text("hylKit.battleReport.floor.thisFloorIsSkipped".i18nHYLKit)
        } else {
            let theContent = Group {
                drawBattleNode(
                    floorData.node1,
                    label: hasLabel ? "hylKit.battleReport.floor.1stHalf".i18nHYLKit : ""
                )
                if hasSpacers, !vertical { Spacer() }
                drawBattleNode(
                    floorData.node2,
                    label: hasLabel ? "hylKit.battleReport.floor.2ndHalf".i18nHYLKit : ""
                )
            }
            if vertical {
                VStack { theContent }
            } else {
                HStack { theContent }
            }
        }
    }

    @ViewBuilder
    func drawFloorInnerContents4AS(
        _ floorData: HoYo.BattleReport4HSR.ASFloorDetail,
        vertical: Bool,
        hasLabel: Bool,
        hasSpacers: Bool
    )
        -> some View {
        if floorData.isSkipped {
            Text("hylKit.battleReport.floor.thisFloorIsSkipped".i18nHYLKit)
        } else {
            let theContent = Group {
                drawBattleNode(
                    floorData.node1,
                    label: hasLabel ? "hylKit.battleReport.floor.1stHalf".i18nHYLKit : ""
                )
                if hasSpacers, !vertical { Spacer() }
                drawBattleNode(
                    floorData.node2,
                    label: hasLabel ? "hylKit.battleReport.floor.2ndHalf".i18nHYLKit : ""
                )
            }
            if vertical {
                VStack { theContent }
            } else {
                HStack { theContent }
            }
        }
    }

    @ViewBuilder
    func drawBattleNode(_ node: HoYo.BattleReport4HSR.FHNode, label: String = "", spacers: Bool = true) -> some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .fontDesign(.monospaced)
            }
            if spacers { Spacer() }
            var guardedAvatars: [HoYo.BattleReport4HSR.FHAvatar] {
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
    @State private var screenVM: ScreenVM = .shared

    private var containerWidth: CGFloat {
        screenVM.mainColumnCanvasSizeObserved.width - 64
    }

    private var data4FH: BattleReportData.ForgottenHallData { data.forgottenHall }

    private var data4AS: BattleReportData.ApocalypticShadowData { data.apocalypticShadow }

    private var data4PF: BattleReportData.PureFictionData { data.pureFiction }
}

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    NavigationStack {
        BattleReportView4HSR(
            data: try! BattleReportTestAssets.getReport4HSR(),
            profile: nil
        ).formStyle(.grouped).disableFocusable()
    }
    .environment(\.colorScheme, .dark)
}

#endif
