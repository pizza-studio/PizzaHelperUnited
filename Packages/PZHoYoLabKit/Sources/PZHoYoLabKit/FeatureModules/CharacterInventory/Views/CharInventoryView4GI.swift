// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - CharacterInventoryView4GI

public struct CharacterInventoryView4GI: CharacterInventoryView {
    // MARK: Lifecycle

    public init(data: InventoryData) {
        self.data = data
    }

    // MARK: Public

    public typealias InventoryData = HoYo.CharInventory4GI

    public let data: InventoryData

    @MainActor public var body: some View {
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

    @MainActor @ViewBuilder
    func renderAllAvatarListFull() -> some View {
        Section {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItem4GI(avatar: avatar, condensed: false)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        if let idObj = Enka.AvatarSummarized.CharacterID(id: avatar.id.description) {
                            idObj.asRowBG(element: .init(rawValue: avatar.element))
                        }
                    }
                    .compositingGroup()
            }
        }
        .textCase(.none)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @MainActor @ViewBuilder
    func renderAllAvatarListCondensed() -> some View {
        StaggeredGrid(
            columns: lineCapacity, outerPadding: false,
            scroll: false, spacing: 2, list: showingAvatars
        ) { avatar in
            // WIDTH: 70, HEIGHT: 63
            AvatarListItem4GI(avatar: avatar, condensed: true)
                .padding(.vertical, 4)
                .compositingGroup()
        }
        .environment(orientation)
        .overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    containerSize = geometry.size
                }.onChange(of: geometry.size, initial: true) { _, newSize in
                    containerSize = newSize
                }
            }
        }
    }

    // MARK: Private

    @State private var allAvatarListDisplayType: InventoryViewFilterType = .all
    @State private var expanded: Bool = true
    @State private var containerSize: CGSize = .init(width: 320, height: 320)
    @State private var orientation = DeviceOrientation()
    @Environment(\.dismiss) private var dismiss

    private var showingAvatars: [HoYo.CharInventory4GI.HYAvatar4GI] {
        filterAvatars(type: allAvatarListDisplayType)
    }

    private var lineCapacity: Int {
        Int(floor((containerSize.width - 20) / 70))
    }
}

// MARK: - AvatarListItem4GI

private struct AvatarListItem4GI: View {
    // MARK: Lifecycle

    public init(avatar: HoYo.CharInventory4GI.HYAvatar4GI, condensed: Bool) {
        self.avatar = avatar
        self.condensed = condensed
    }

    // MARK: Public

    @MainActor public var body: some View {
        HStack(spacing: condensed ? 0 : 3) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let charIdExp = Enka.AvatarSummarized.CharacterID(
                        id: avatar.id.description, costumeID: avatar.firstCostumeID?.description
                    ) {
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
                verbatim: "❖\(avatar.activedConstellationNum)",
                alignment: .trailing
            )
            if !condensed {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        charName
                            .font(.system(size: 20)).bold().fontWidth(.compressed)
                            .fixedSize(horizontal: true, vertical: false)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        // 此处的 relicSetIDs 与 relicIconURLs 的容量必定相等，无须额外的 sanity check。
                        if let relicSetIDs = avatar.relicSetIDs, let relicIconURLs = avatar.relicIconURLs {
                            ForEach(Array(relicSetIDs.enumerated()), id: \.offset) { offset, relicSetID in
                                let relicSetIDStr = relicSetID.description.dropFirst().dropLast().description
                                if let artifactType = Enka.ArtifactType(typeID: offset + 1, game: .genshinImpact) {
                                    Group {
                                        let assetName = "gi_relic_\(relicSetIDStr)_\(artifactType.assetSuffix)"
                                        if let img = Enka.queryImageAssetSUI(for: assetName) {
                                            img.resizable()
                                                .frame(width: 22.5, height: 22.5)
                                                .clipped()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                        } else {
                                            AsyncImage(url: relicIconURLs[offset].asURL) { image in
                                                image.resizable()
                                                    .frame(width: 22.5, height: 22.5)
                                                    .clipped()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            .clipShape(Circle())
                                        }
                                    }
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }.frame(height: 20)
                }
            }
            if !condensed {
                ZStack(alignment: .bottomLeading) {
                    Group {
                        if let img = Enka.queryImageAssetSUI(for: "gi_weapon_\(avatar.weapon.id)") {
                            img.resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            AsyncImage(url: avatar.weapon.icon.asURL) { image in
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
                    verbatim: "❖\(avatar.weapon.affixLevel)",
                    alignment: .topLeading
                )
                .corneredTag(
                    verbatim: "Lv.\(avatar.weapon.level)",
                    alignment: .bottomTrailing
                )
            }
        }
    }

    // MARK: Private

    private let avatar: HoYo.CharInventory4GI.HYAvatar4GI

    @State private var condensed: Bool

    @Default(.useRealCharacterNames) private var useRealName: Bool

    private var fetterTag: String {
        condensed ? "" : "♡\(avatar.fetter)"
    }

    @MainActor @ViewBuilder private var charName: some View {
        let charStr: String = if let charIdExp = Enka.AvatarSummarized.CharacterID(id: avatar.id.description) {
            charIdExp.nameObj.i18n(theDB: Enka.Sputnik.shared.db4GI, officialNameOnly: !useRealName)
        } else {
            avatar.name
        }
        Text(charStr)
    }
}
