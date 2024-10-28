// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportView4GI

public struct AbyssReportView4GI: AbyssReportView {
    // MARK: Lifecycle

    public init(data: AbyssReportData) {
        self.data = data
    }

    // MARK: Public

    public typealias AbyssReportData = HoYo.AbyssReport4GI

    public static let navTitle = "hylKit.abyssReportView4GI.navTitle".i18nHYLKit
    public static let navTitleTiny = "hylKit.abyssReportView4GI.navTitle.tiny".i18nHYLKit

    public static var abyssIcon: Image { Image("gi_abyss", bundle: .module) }

    public var data: AbyssReportData

    public var body: some View {
        contents.overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    containerWidth = geometry.size.width
                }.onChange(of: geometry.size.width, initial: true) { _, newSize in
                    containerWidth = newSize
                }
            }
        }
    }

    // MARK: Internal

    @ViewBuilder var contents: some View {
        Form {
            stats
            floorList
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder var stats: some View {
        Section {
            StaggeredGrid(
                columns: columns,
                outerPadding: false,
                scroll: false,
                list: data.summarizedIntoCells(compact: columns % 2 == 0),
                content: { currentCell in
                    drawAbyssValueCell(currentCell)
                        .matchedGeometryEffect(id: currentCell.id, in: animation)
                }
            )
            .animation(.easeInOut, value: columns)
            .environment(orientation)
        } header: {
            HStack {
                Text("hylKit.abyssReport.gi.stat.summary".i18nHYLKit)
            }
        }
        .listRowMaterialBackground()
    }

    // MARK: Private

    @State private var containerWidth: CGFloat = ThisDevice.basicWindowSize.width
    @StateObject private var orientation = DeviceOrientation()
    @Namespace private var animation

    private var columns: Int { min(max(Int(floor($containerWidth.wrappedValue / 200)), 2), 4) }
}

extension AbyssReportView4GI {
    @ViewBuilder fileprivate var floorList: some View {
        ForEach(data.floors.reversed(), id: \.index) { floorData in
            Section {
                LazyVStack {
                    ForEach(floorData.levels, id: \.index) { battleRoom in
                        drawBattleRoom(levelData: battleRoom)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                HStack {
                    Text(
                        "hylKit.abyssReport.floor.title:\(floorData.index.description)",
                        bundle: .module
                    )
                    Spacer()
                    Text(verbatim: "\(floorData.star) / \(floorData.maxStar) ⭐️")
                }
            }
            .listRowSeparator(.hidden)
            .listRowMaterialBackground()
        }
    }

    @ViewBuilder
    fileprivate func drawBattleRoom(levelData: HoYo.AbyssReport4GI.Floor.Level) -> some View {
        LazyVStack {
            HStack {
                Text("hylKit.abyssReport.room.title:\(levelData.index.description)", bundle: .module)
                    .fontWeight(.black)
                Spacer()
                Text(verbatim: String(repeating: " ⭐️", count: levelData.star))
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
        _ levelData: HoYo.AbyssReport4GI.Floor.Level,
        vertical: Bool,
        hasLabel: Bool,
        hasSpacers: Bool
    )
        -> some View {
        let hasLabel = levelData.battles.count > 1 ? hasLabel : false
        let theContent = Group {
            drawBattleNode(
                levelData.battles[0],
                label: hasLabel ? "hylKit.abyssReport.floor.1stHalf".i18nHYLKit : ""
            )
            if levelData.battles.count > 1 {
                if hasSpacers, !vertical { Spacer() }
                drawBattleNode(
                    levelData.battles[1],
                    label: hasLabel ? "hylKit.abyssReport.floor.2ndHalf".i18nHYLKit : ""
                )
            }
        }
        if vertical {
            LazyVStack { theContent }
        } else {
            HStack { theContent }
        }
    }

    @ViewBuilder
    fileprivate func drawBattleNode(
        _ node: HoYo.AbyssReport4GI.Floor.Level.Battle,
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
            var guardedAvatars: [HoYo.AbyssReport4GI.Floor.Level.Battle.Avatar] {
                var result = node.avatars
                while result.count < 4 {
                    result.append(.init(id: -114_514, icon: "", level: -213, rarity: 5))
                }
                return result
            }
            ForEach(guardedAvatars) { avatar in
                let decoratedIconSize = decoratedIconSize
                let isNullAvatar: Bool = avatar.id == -114_514
                Group {
                    if ThisDevice.isSmallestHDScreenPhone {
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
                    height: ThisDevice.isSmallestHDScreenPhone ? decoratedIconSize : (decoratedIconSize / 0.74)
                )
                if spacers { Spacer() }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    fileprivate func drawAbyssValueCell(_ cellData: AbyssValueCell) -> some View {
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
        AbyssReportView4GI(data: try! AbyssReportTestAssets.giCurr.getReport4GI())
            .formStyle(.grouped)
    }
}

#endif
