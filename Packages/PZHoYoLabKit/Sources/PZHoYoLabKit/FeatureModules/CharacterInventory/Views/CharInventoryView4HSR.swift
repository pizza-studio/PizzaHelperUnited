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

    public init(data: InventoryData) {
        self.data = data
    }

    // MARK: Public

    public typealias InventoryData = HoYo.CharInventory4HSR

    public let data: InventoryData

    public var body: some View {
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

    // MARK: Internal

    @ViewBuilder
    func renderAllAvatarListFull() -> some View {
        Section {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItemHSR(avatar: avatar, condensed: false)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        if let idObj = Enka.AvatarSummarized.CharacterID(id: avatar.id.description) {
                            idObj.asRowBG() // 星穹铁道不需要 element: .init(rawValue: avatar.element)
                        }
                    }
                    .compositingGroup()
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
                .matchedGeometryEffect(id: avatar.id, in: animation)
        }
        .environment(orientation)
    }

    // MARK: Private

    @State private var allAvatarListDisplayType: InventoryViewFilterType = .all
    @State private var containerWidth: CGFloat = 320
    @State private var expanded: Bool = false
    @Namespace private var animation: Namespace.ID
    @StateObject private var orientation = DeviceOrientation()
    @Environment(\.dismiss) private var dismiss

    private var showingAvatars: [HoYo.CharInventory4HSR.HYAvatar4HSR] {
        filterAvatars(type: allAvatarListDisplayType)
    }

    private var lineCapacity: Int {
        Int(floor((containerWidth - 20) / 70))
    }
}

// MARK: - AvatarListItemHSR

private struct AvatarListItemHSR: View {
    // MARK: Lifecycle

    public init(avatar: HoYo.CharInventory4HSR.HYAvatar4HSR, condensed: Bool) {
        self.avatar = avatar
        self.condensed = condensed
    }

    // MARK: Public

    public var body: some View {
        HStack(spacing: condensed ? 0 : 3) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let charIdExp = Enka.AvatarSummarized.CharacterID(id: avatar.id.description) {
                        charIdExp.avatarPhoto(size: 55, circleClipped: true, clipToHead: true)
                    } else {
                        Color.gray.frame(width: 55, height: 55, alignment: .top).clipShape(Circle())
                            .overlay(alignment: .top) {
                                AsyncImage(url: avatar.icon.asURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(Circle())
                            }
                    }
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            }
            .frame(width: condensed ? 70 : 75, alignment: .leading)
            .corneredTag(
                verbatim: "Lv.\(avatar.level)",
                alignment: .topTrailing
            )
            .corneredTag(
                verbatim: "❖\(avatar.rank)",
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
                        ForEach(avatar.allArtifacts, id: \.id) { artifact in
                            Group {
                                if let img = queryArtifactImg(for: artifact) {
                                    img.resizable()
                                } else {
                                    AsyncImage(url: artifact.icon.asURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .clipShape(Circle())
                                }
                            }
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        }
                        Spacer().frame(height: 20)
                    }
                }
                if let equip = avatar.equip {
                    ZStack(alignment: .bottomLeading) {
                        Group {
                            if let img = Enka.queryImageAssetSUI(for: "hsr_light_cone_\(equip.id)") {
                                img.resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                AsyncImage(url: equip.icon.asURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .clipShape(Circle())
                            }
                        }
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    }
                    .corneredTag(
                        verbatim: "❖\(equip.rank)",
                        alignment: .topLeading
                    )
                    .corneredTag(
                        verbatim: "Lv.\(equip.level)",
                        alignment: .bottomTrailing
                    )
                }
            }
        }
    }

    // MARK: Private

    @State private var condensed: Bool

    private let avatar: HoYo.CharInventory4HSR.HYAvatar4HSR

    @Default(.useRealCharacterNames) private var useRealName: Bool

    @ViewBuilder private var charName: some View {
        let charStr: String = if let charIdExp = Enka.AvatarSummarized.CharacterID(id: avatar.id.description) {
            charIdExp.nameObj.i18n(theDB: Enka.Sputnik.shared.db4HSR, officialNameOnly: !useRealName)
        } else {
            avatar.name
        }
        Text(charStr)
    }

    @MainActor
    private func queryArtifactImg(for target: any HoyoArtifactProtocol4HSR) -> Image? {
        guard let neutralData = Enka.Sputnik.shared.db4HSR.artifacts[target.id.description] else { return nil }
        guard let type = Enka.ArtifactType(typeID: target.pos, game: .starRail) else { return nil } // Might need fix.
        let assetName = "hsr_relic_\(neutralData.setID)_\(type.assetSuffix)"
        return Enka.queryImageAssetSUI(for: assetName)
    }
}
