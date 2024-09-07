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

    public static var abyssIcon: Image { Image("gi_abyss", bundle: .module) }

    public var data: AbyssReportData

    @MainActor public var body: some View {
        GeometryReader { geometry in
            contents.onAppear {
                containerWidth = geometry.size.width
            }.onChange(of: geometry.size.width) { _, newSize in
                containerWidth = newSize
            }
        }
    }

    // MARK: Internal

    @MainActor @ViewBuilder var contents: some View {
        Form {
            stats
            floorList
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }

    @MainActor @ViewBuilder var stats: some View {
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
    @State private var orientation = DeviceOrientation()
    @Namespace private var animation

    private var columns: Int { min(max(Int(floor($containerWidth.wrappedValue / 200)), 2), 4) }
}

extension AbyssReportView4GI {
    @MainActor @ViewBuilder fileprivate var floorList: some View {
        ForEach(data.floors.reversed(), id: \.index) { floorData in
            Section {
                VStack {
                    ForEach(floorData.levels, id: \.index) { battleRoom in
                        drawBattleRoom(levelData: battleRoom)
                    }
                }
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
            .listRowMaterialBackground()
        }
    }

    @MainActor @ViewBuilder
    fileprivate func drawBattleRoom(levelData: HoYo.AbyssReport4GI.Floor.Level) -> some View {
        VStack {
            HStack {
                Text("hylKit.abyssReport.room.title:\(levelData.index.description)", bundle: .module)
                Spacer()
                Text(verbatim: String(repeating: " ⭐️", count: levelData.star))
            }
            // 每一间在产生记录时，一定会同时有上下两半场同时被登记。
            let theContent = Group {
                drawBattleNode(levelData.battles[0], spacers: false)
                Spacer()
                drawBattleNode(levelData.battles[1], spacers: false)
            }
            let theContentLabeled = Group {
                drawBattleNode(levelData.battles[0], label: "hylKit.abyssReport.floor.1stHalf".i18nHYLKit)
                Spacer()
                drawBattleNode(levelData.battles[1], label: "hylKit.abyssReport.floor.2ndHalf".i18nHYLKit)
            }
            let theContentLabeledSansSpacers = Group {
                drawBattleNode(
                    levelData.battles[0],
                    label: "hylKit.abyssReport.floor.1stHalf".i18nHYLKit,
                    spacers: false
                )
                Spacer()
                drawBattleNode(
                    levelData.battles[1],
                    label: "hylKit.abyssReport.floor.2ndHalf".i18nHYLKit,
                    spacers: false
                )
            }
            ViewThatFits(in: .horizontal) {
                HStack { theContentLabeled }
                HStack { theContentLabeledSansSpacers }
                HStack { theContent }
                VStack { theContentLabeled }
                VStack { theContentLabeledSansSpacers }
                VStack { theContent }
            }
        }
    }

    @MainActor @ViewBuilder
    fileprivate func drawBattleNode(
        _ node: HoYo.AbyssReport4GI.Floor.Level.Battle,
        label: String = "",
        spacers: Bool = true
    )
        -> some View {
        HStack {
            if !label.isEmpty {
                Text(label)
                    .fontDesign(.monospaced)
            }
            if spacers { Spacer() }
            var guardedAvatars: [HoYo.AbyssReport4GI.Floor.Level.Battle.Avatar] {
                var result = node.avatars
                while result.count < 4 {
                    result.append(.init(id: -213, icon: "", level: -213, rarity: 5))
                }
                return result
            }
            ForEach(node.avatars) { avatar in
                let decoratedIconSize = decoratedIconSize
                Group {
                    if avatar.id == -114_514 {
                        Color.primary.opacity(0.3)
                    } else if ThisDevice.isSmallestHDScreenPhone {
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
                    } else {
                        CharacterIconView(charID: avatar.id.description, cardSize: decoratedIconSize / 0.74)
                            .corneredTag(
                                verbatim: "Lv.\(avatar.level.description)",
                                alignment: .bottom,
                                textSize: 11
                            )
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

    @MainActor @ViewBuilder
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
        Form {
            AbyssReportView4GI(data: try! AbyssReportTestAssets.giCurr.getReport4GI())
        }
        .formStyle(.grouped)
    }
    .frame(width: 480, height: 720)
}

#endif
