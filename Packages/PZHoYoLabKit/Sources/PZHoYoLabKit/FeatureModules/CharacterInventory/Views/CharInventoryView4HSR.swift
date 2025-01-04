// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - CharacterInventoryView4HSR

public struct CharacterInventoryView4HSR: CharacterInventoryView {
    // MARK: Lifecycle

    public init(data: InventoryData, uidWithGame: String) {
        self.data = data
        let theDB = Enka.Sputnik.shared.db4HSR
        self.summaries = (Defaults[.queriedHoYoProfiles4HSR][uidWithGame] ?? []).compactMap {
            .init(summary: $0.summarize(theDB: theDB))
        }
        self.currentAvatarSummaryID = ""
    }

    // MARK: Public

    public typealias InventoryData = HoYo.CharInventory4HSR

    public let data: InventoryData
    public let summaries: [SummaryPtr]

    @ViewBuilder public var body: some View {
        basicBody
            .overlay {
                AvatarStatCollectionTabView(
                    selectedAvatarID: $currentAvatarSummaryID,
                    summarizedAvatars: summaries.map(\.wrappedValue)
                ) {
                    currentAvatarSummaryID = ""
                    simpleTaptic(type: .medium)
                }
                .tag(currentAvatarSummaryID)
            }
    }

    // MARK: Internal

    @ViewBuilder var basicBody: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats, bundle: .module)
                    if expanded {
                        Text(goldStats, bundle: .module)
                    }
                }.font(.footnote)
            }.listRowMaterialBackground()
            Group {
                if expanded {
                    renderAllAvatarListFull()
                } else {
                    renderAllAvatarListCondensed()
                }
            }.listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .containerRelativeFrame(.horizontal) { length, _ in
            Task { @MainActor in
                withAnimation { containerWidth = length - 48 }
            }
            return length
        }
        .navigationTitle("hylKit.inventoryView.characters.title".i18nHYLKit)
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Picker("".description, selection: $expanded.animation()) {
                    Text("hylKit.inventoryView.expand.tabText".i18nHYLKit).tag(true)
                    Text("hylKit.inventoryView.collapse.tabText".i18nHYLKit).tag(false)
                }
                .pickerStyle(.menu)
                Menu {
                    ForEach(
                        InventoryViewFilterType.allCases,
                        id: \.rawValue
                    ) { choice in
                        Button(choice.rawValue.i18nHYLKit) {
                            withAnimation {
                                allAvatarListDisplayType = choice
                            }
                        }
                    }
                } label: {
                    Image(systemSymbol: .arrowLeftArrowRightCircle)
                }
            }
        }
    }

    @ViewBuilder
    func renderAllAvatarListFull() -> some View {
        Section {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItemHSR(avatar: avatar, condensed: false)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        let idObj = avatar.wrappedValue.mainInfo.idExpressable
                        idObj.asRowBG()
                    }
                    .compositingGroup()
                    .onTapGesture {
                        currentAvatarSummaryID = avatar.id
                        simpleTaptic(type: .medium)
                    }
            }
        }
        .textCase(.none)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @ViewBuilder
    func renderAllAvatarListCondensed() -> some View {
        StaggeredGrid(
            columns: lineCapacity, outerPadding: false,
            scroll: false, spacing: 2, list: showingAvatars
        ) { avatar in
            // WIDTH: 70, HEIGHT: 63
            AvatarListItemHSR(avatar: avatar, condensed: true)
                .padding(.vertical, 4)
                .compositingGroup()
                .matchedGeometryEffect(id: avatar.wrappedValue.id, in: animation)
                .onTapGesture {
                    currentAvatarSummaryID = avatar.id
                    simpleTaptic(type: .medium)
                }
        }
        .environment(orientation)
    }

    // MARK: Private

    @State private var allAvatarListDisplayType: InventoryViewFilterType = .all
    @State private var containerWidth: CGFloat = 320
    @State private var expanded: Bool = false
    @State private var currentAvatarSummaryID: String
    @Namespace private var animation: Namespace.ID
    @StateObject private var orientation = DeviceOrientation()
    @Environment(\.dismiss) private var dismiss

    private var showingAvatars: [SummaryPtr] {
        filterAvatarSummaries(type: allAvatarListDisplayType)
    }

    private var lineCapacity: Int {
        Int(floor((containerWidth - 20) / 70))
    }
}

// MARK: - AvatarListItemHSR

private struct AvatarListItemHSR: View {
    // MARK: Lifecycle

    public init(
        avatar: CharacterInventoryView.SummaryPtr,
        condensed: Bool
    ) {
        self.condensed = condensed
        self.summary = avatar
    }

    // MARK: Public

    public var body: some View {
        let avatar = summary.wrappedValue
        HStack(spacing: condensed ? 0 : 3) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    avatar.mainInfo.idExpressable.avatarPhoto(size: 55, circleClipped: true, clipToHead: true)
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            }
            .frame(width: condensed ? 70 : 75, alignment: .leading)
            .corneredTag(
                verbatim: "Lv.\(avatar.mainInfo.avatarLevel)",
                alignment: .topTrailing
            )
            .corneredTag(
                verbatim: "❖\(avatar.mainInfo.constellation)",
                alignment: .trailing
            )
            if !condensed {
                VStack(spacing: 3) {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        charName
                            .font(.system(size: 20)).bold().fontWidth(.compressed)
                            .fixedSize(horizontal: true, vertical: false)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        ForEach(avatar.artifacts, id: \.id) { artifact in
                            artifact.localFittingIcon4SUI
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        Spacer().frame(height: 20)
                    }
                }
            }
            if !condensed, let weapon = avatar.equippedWeapon {
                ZStack(alignment: .bottomLeading) {
                    weapon.localFittingIcon4SUI
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .corneredTag(
                    verbatim: "❖\(weapon.refinement)",
                    alignment: .topLeading
                )
                .corneredTag(
                    verbatim: "Lv.\(weapon.trainedLevel)",
                    alignment: .bottomTrailing
                )
            }
        }
    }

    // MARK: Private

    @State private var condensed: Bool

    private let summary: CharacterInventoryView.SummaryPtr

    @Default(.useRealCharacterNames) private var useRealName: Bool

    @ViewBuilder private var charName: some View {
        let charStr: String = summary.wrappedValue.mainInfo.idExpressable.nameObj.i18n(
            theDB: Enka.Sputnik.shared.db4HSR,
            officialNameOnly: !useRealName
        )
        Text(charStr)
    }
}
