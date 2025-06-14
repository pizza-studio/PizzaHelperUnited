// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - CharacterInventoryView

public struct CharacterInventoryView: View {
    // MARK: Lifecycle

    public init(profile: PZProfileSendable) {
        let uidWithGame = profile.uidWithGame
        let rawSummaries: [SummaryPtr]
        switch profile.game {
        case .genshinImpact:
            let theDB = Enka.Sputnik.shared.db4GI
            rawSummaries = (Defaults[.queriedHoYoProfiles4GI][uidWithGame] ?? []).compactMap {
                .init(summary: $0.summarize(theDB: theDB))
            }
        case .starRail:
            let theDB = Enka.Sputnik.shared.db4HSR
            rawSummaries = (Defaults[.queriedHoYoProfiles4HSR][uidWithGame] ?? []).compactMap {
                .init(summary: $0.summarize(theDB: theDB))
            }
        case .zenlessZone:
            rawSummaries = []
        }
        self.currentAvatarSummaryID = ""
        self.game = profile.game
        self.sortedSummariesMap = Dictionary(grouping: rawSummaries, by: \.wrappedValue.mainInfo.element)
        self.summaries = rawSummaries.sorted {
            $0.wrappedValue.mainInfo.element.tourID < $1.wrappedValue.mainInfo.element.tourID
        }
    }

    // MARK: Public

    public typealias SummaryPtr = Enka.AvatarSummarized.SharedPointer

    public let summaries: [SummaryPtr]
    public let sortedSummariesMap: [Enka.GameElement: [SummaryPtr]]

    @ViewBuilder public var body: some View {
        basicBody
            .appTabBarVisibility(.hidden)
            .overlay {
                AvatarStatCollectionTabView(
                    selectedAvatarID: $currentAvatarSummaryID,
                    summarizedAvatars: summaries.map(\.wrappedValue)
                ) {
                    currentAvatarSummaryID = ""
                    simpleTaptic(type: .medium)
                }
            }
    }

    // MARK: Internal

    @ViewBuilder var basicBody: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats, bundle: .module) + Text(verbatim: " // ") + Text(goldStats, bundle: .module)
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
                containerWidth = length - 48
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
        let allElements = Enka.GameElement.allCases.sorted { $0.tourID < $1.tourID }
        ForEach(allElements, id: \.tourID) { currentElement in
            if let avatarsOfThisElement = sortedSummariesMap[currentElement] {
                let theListFiltered = filterSummaries(type: allAvatarListDisplayType, from: avatarsOfThisElement)
                if !theListFiltered.isEmpty {
                    Section {
                        ForEach(theListFiltered, id: \.id) { avatar in
                            AvatarListItem(game: game, avatar: avatar, condensed: false)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background {
                                    let idObj = avatar.wrappedValue.mainInfo.idExpressable
                                    idObj.asRowBG(element: avatar.wrappedValue.mainInfo.element)
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
            }
        }
    }

    @ViewBuilder
    func renderAllAvatarListCondensed() -> some View {
        let allElements = Enka.GameElement.allCases.sorted { $0.tourID < $1.tourID }
        ForEach(allElements, id: \.tourID) { currentElement in
            if let avatarsOfThisElement = sortedSummariesMap[currentElement] {
                let theListFiltered = filterSummaries(type: allAvatarListDisplayType, from: avatarsOfThisElement)
                if !theListFiltered.isEmpty {
                    StaggeredGrid(
                        columns: lineCapacity, outerPadding: false,
                        scroll: false, spacing: 2, list: theListFiltered
                    ) { avatar in
                        // WIDTH: 70, HEIGHT: 63
                        AvatarListItem(game: game, avatar: avatar, condensed: true)
                            .padding(.vertical, 4)
                            .compositingGroup()
                            .matchedGeometryEffect(id: avatar.wrappedValue.id, in: animation)
                            .onTapGesture {
                                currentAvatarSummaryID = avatar.id
                                simpleTaptic(type: .medium)
                            }
                    }
                    .overlay(alignment: .topLeading) {
                        Color(cgColor: currentElement.themeColor)
                            .frame(width: 8, height: 8)
                            .clipShape(.circle)
                    }
                    .listRowSeparatorTint(.secondary.opacity(0.7))
                    .environment(orientation)
                }
            }
        }
    }

    // MARK: Private

    @State private var allAvatarListDisplayType: InventoryViewFilterType = .all
    @State private var containerWidth: CGFloat = 320
    @State private var expanded: Bool = false
    @State private var currentAvatarSummaryID: String
    @Namespace private var animation: Namespace.ID
    @StateObject private var orientation = DeviceOrientation()
    @Environment(\.dismiss) private var dismiss

    private let game: Pizza.SupportedGame

    private var lineCapacity: Int {
        Int(floor((containerWidth - 20) / 70))
    }
}

// MARK: CharacterInventoryView.AvatarListItem

extension CharacterInventoryView {
    // MARK: - AvatarListItem

    private struct AvatarListItem: View, Identifiable {
        // MARK: Lifecycle

        public init(
            game: Pizza.SupportedGame,
            avatar: SummaryPtr,
            condensed: Bool
        ) {
            self.condensed = condensed
            self.summary = avatar
            self.game = game
        }

        // MARK: Public

        nonisolated public var id: String { summary.id }

        public var body: some View {
            let avatar = summary.wrappedValue
            HStack(spacing: condensed ? 0 : 3) {
                ZStack(alignment: .bottomLeading) {
                    Group {
                        avatar.mainInfo.idExpressable.avatarPhoto(size: 55, circleClipped: true, clipToHead: true)
                    }
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .overlay(alignment: .bottomLeading) {
                        if !condensed {
                            Color(cgColor: avatar.mainInfo.element.themeColor)
                                .frame(width: 8, height: 8)
                                .clipShape(.circle)
                        }
                    }
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
                .corneredTag(
                    verbatim: game == .genshinImpact ? fetterTag : "",
                    alignment: .bottomTrailing
                )
                if !condensed {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text(charNameStr)
                                .font(.system(size: 20)).bold().fontWidth(.compressed)
                                .fixedSize(horizontal: true, vertical: false)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                            Spacer()
                        }
                        HStack(spacing: 0) {
                            ForEach(avatar.artifacts, id: \.id) { artifact in
                                switch game {
                                case .genshinImpact:
                                    artifact.localFittingIcon4SUI
                                        .frame(width: 22.5, height: 22.5)
                                        .clipped()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                case .starRail:
                                    artifact.localFittingIcon4SUI
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                case .zenlessZone:
                                    artifact.localFittingIcon4SUI
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
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
        private let game: Pizza.SupportedGame

        @Default(.useRealCharacterNames) private var useRealName: Bool

        private var fetterTag: String {
            guard let fetter = summary.wrappedValue.mainInfo.fetter else { return "" }
            return condensed ? "" : "♡\(fetter)"
        }

        private var charNameStr: String {
            switch game {
            case .genshinImpact:
                summary.wrappedValue.mainInfo.idExpressable.nameObj.i18n(
                    theDB: Enka.Sputnik.shared.db4GI,
                    officialNameOnly: !useRealName
                )
            case .starRail:
                summary.wrappedValue.mainInfo.idExpressable.nameObj.i18n(
                    theDB: Enka.Sputnik.shared.db4HSR,
                    officialNameOnly: !useRealName
                )
            case .zenlessZone: ""
            }
        }
    }
}

extension CharacterInventoryView {
    // MARK: - GoldNum

    private struct GoldNum {
        let allGold, charGold, weaponGold: Int
    }

    // MARK: - InventoryViewFilterType

    private enum InventoryViewFilterType: String, CaseIterable {
        case all = "hylKit.inventoryView.characters.filter.all"
        case star5 = "hylKit.inventoryView.characters.filter.5star"
        case star4 = "hylKit.inventoryView.characters.filter.4star"
    }

    private var characterStats: LocalizedStringKey {
        let a = summaries.count
        let b = summaries.filter { $0.wrappedValue.mainInfo.rarityStars == 5 }.count
        let c = summaries.filter { $0.wrappedValue.mainInfo.rarityStars == 4 }.count
        return "hylKit.inventoryView.characters.count.character:\(a, specifier: "%lld")\(b, specifier: "%lld")\(c, specifier: "%lld")"
    }

    private var goldStats: LocalizedStringKey {
        let goldNumData = goldNum()
        let d = goldNumData.allGold
        let e = goldNumData.charGold
        let f = goldNumData.weaponGold
        return "hylKit.inventoryView.characters.count.golds:\(d, specifier: "%lld")\(e, specifier: "%lld")\(f, specifier: "%lld")"
    }

    private func filterSummaries(
        type: InventoryViewFilterType,
        from sourceSummaries: [SummaryPtr]
    )
        -> [SummaryPtr] {
        switch type {
        case .all: sourceSummaries
        case .star4: sourceSummaries.filter { $0.wrappedValue.mainInfo.rarityStars == 4 }
        case .star5: sourceSummaries.filter { $0.wrappedValue.mainInfo.rarityStars == 5 }
        }
    }

    private func goldNum() -> GoldNum {
        var charGold = 0
        var weaponGold = 0
        summaries.forEach { summaryPtr in
            let summary = summaryPtr.wrappedValue
            if summary.mainInfo.idExpressable.isProtagonist { return }
            if summary.mainInfo.rarityStars == 5 {
                charGold += 1
                charGold += summary.mainInfo.constellation
            }
            if let weapon = summary.equippedWeapon, weapon.rarityStars == 5 {
                weaponGold += weapon.refinement
            }
        }
        return .init(
            allGold: charGold + weaponGold,
            charGold: charGold,
            weaponGold: weaponGold
        )
    }
}
