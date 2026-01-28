// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - CharacterInventoryView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct CharacterInventoryView: View {
    // MARK: Lifecycle

    public init(profile: PZProfileSendable) {
        self.game = profile.game
        self.profile = profile
        let rawSummaries: [SummaryPtr] = Self.getRawSummaries(profile: profile)
        self.sortedSummariesMap = Dictionary(grouping: rawSummaries, by: \.wrappedValue.mainInfo.element)
        self.summaries = rawSummaries
    }

    // MARK: Public

    public typealias SummaryPtr = Enka.AvatarSummarized.SharedPointer

    @ViewBuilder public var body: some View {
        NavigationStack {
            basicBody
                .appTabBarVisibility(.hidden)
        }
        .react(to: broadcaster.eventForUpdatingLocalHoYoLABAvatarCache) {
            Task { @MainActor in
                let rawSummaries: [SummaryPtr] = Self.getRawSummaries(profile: profile)
                let sortedMap = Dictionary(grouping: rawSummaries, by: \.wrappedValue.mainInfo.element)
                withAnimation {
                    sortedSummariesMap = sortedMap
                    summaries = rawSummaries
                }
            }
        }
    }

    // MARK: Internal

    @ViewBuilder var basicBody: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats, bundle: .currentSPM) + Text(verbatim: " // ") +
                        Text(goldStats, bundle: .currentSPM)
                }.font(.footnote)
                TakeViewShotButton {
                    ShareAsMasterPageView(
                        profile: profile,
                        showingAvatars: filterSummaries(
                            type: allAvatarListDisplayType,
                            from: summaries
                        )
                    )
                } subLabel: {
                    Text("hylKit.inventoryView.shareInventoryListAsImage.buttonTitle", bundle: .currentSPM)
                }
            }.listRowMaterialBackground()
            Group {
                if expanded {
                    renderAllAvatarListFull()
                } else {
                    renderAllAvatarListCondensed()
                }
            }.listRowMaterialBackground()
        }
        .formStyle(.grouped).disableFocusable()
        .navigationLinkIndicatorVisibility(.hidden)
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle("hylKit.inventoryView.characters.title".i18nHYLKit)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Picker("".description, selection: $expanded.animation()) {
                    Text("hylKit.inventoryView.expand.tabText".i18nHYLKit).tag(true)
                    Text("hylKit.inventoryView.collapse.tabText".i18nHYLKit).tag(false)
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .fixedSize()
            }
            if #available(iOS 26.0, macCatalyst 26.0, macOS 26.0, *) {
                ToolbarSpacer(.flexible, placement: .primaryAction)
            }
            ToolbarItemGroup(placement: .primaryAction) {
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
                    Image(systemSymbol: .line3HorizontalDecreaseCircle)
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
                            NavigationLink {
                                InventoryEASVTabViewWrapper(
                                    selectedID: avatar.id,
                                    avatars: summaries.map(\.wrappedValue)
                                )
                                .task { simpleTaptic(type: .medium) }
                            } label: {
                                AvatarListItem(game: game, avatar: avatar, condensed: false)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background {
                                        let idObj = avatar.wrappedValue.mainInfo.idExpressable
                                        idObj.asRowBG(element: avatar.wrappedValue.mainInfo.element)
                                    }
                                    .drawingGroup()
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack {
                            Color(cgColor: currentElement.themeColor)
                                .frame(width: 8, height: 8)
                                .clipShape(.circle)
                            Text(currentElement.localizedName)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                        NavigationLink {
                            InventoryEASVTabViewWrapper(
                                selectedID: avatar.id,
                                avatars: summaries.map(\.wrappedValue)
                            )
                            .task { simpleTaptic(type: .medium) }
                        } label: {
                            Color.clear.frame(width: 70, height: 63)
                                .overlay {
                                    if let image = avatarItemViewCacheMap[avatar.id] {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 70, height: 63)
                                    } else {
                                        WinUI3ProgressRing()
                                    }
                                }
                                .task {
                                    let avatarListItem = AvatarListItem(game: game, avatar: avatar, condensed: true)
                                        .padding(.vertical, 4)
                                        .drawingGroup()
                                    let renderer = ImageRenderer(
                                        content: avatarListItem
                                    )
                                    renderer.scale = 3.0
                                    if let cgImage = renderer.cgImage {
                                        avatarItemViewCacheMap[avatar.id] = Image(
                                            decorative: cgImage,
                                            scale: 1
                                        )
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .id(avatar.id)
                    }
                    .frame(width: screenVM.mainColumnCanvasSizeObserved.width - 64)
                    .overlay(alignment: .topLeading) {
                        Color(cgColor: currentElement.themeColor)
                            .frame(width: 8, height: 8)
                            .clipShape(.circle)
                    }
                    .padding(.top, 5)
                    .listRowSeparatorTint(.secondary.opacity(0.7))
                }
            }
        }
    }

    // MARK: Private

    @State private var summaries: [SummaryPtr]
    @State private var sortedSummariesMap: [Enka.GameElement: [SummaryPtr]]
    @State private var avatarItemViewCacheMap: [String: Image] = [:]
    @State private var allAvatarListDisplayType: InventoryViewFilterType = .all
    @State private var expanded: Bool = false
    @State private var screenVM: ScreenVM = .shared
    @StateObject private var broadcaster = Broadcaster.shared
    @Environment(\.dismiss) private var dismiss

    private let profile: PZProfileSendable

    private let game: Pizza.SupportedGame

    private var containerWidth: CGFloat {
        screenVM.mainColumnCanvasSizeObserved.width - 64
    }

    private var lineCapacity: Int {
        Int(floor((containerWidth - 20) / 70))
    }

    private static func getRawSummaries(profile: PZProfileSendable) -> [SummaryPtr] {
        let rawSummaries: [SummaryPtr]
        switch profile.game {
        case .genshinImpact:
            let theDB = Enka.Sputnik.shared.db4GI
            rawSummaries = HYQueriedModels.HYLAvatarDetail4GI.getLocalHoYoAvatars(
                theDB: theDB, uid: profile.uid
            ).compactMap {
                .init(summary: $0)
            }
        case .starRail:
            let theDB = Enka.Sputnik.shared.db4HSR
            rawSummaries = HYQueriedModels.HYLAvatarDetail4HSR.getLocalHoYoAvatars(
                theDB: theDB, uid: profile.uid
            ).compactMap {
                .init(summary: $0)
            }
        case .zenlessZone:
            rawSummaries = []
        }
        return rawSummaries.sorted {
            $0.wrappedValue.mainInfo.element.tourID < $1.wrappedValue.mainInfo.element.tourID
        }
    }
}

// MARK: CharacterInventoryView.AvatarListItem

@available(iOS 17.0, macCatalyst 17.0, *)
extension CharacterInventoryView {
    // MARK: - AvatarListItem

    private struct AvatarListItem: View, Identifiable {
        // MARK: Lifecycle

        public init(
            game: Pizza.SupportedGame,
            avatar: SummaryPtr,
            condensed: Bool,
            truncateName: Bool = false
        ) {
            self.condensed = condensed
            self.summary = avatar
            self.game = game
            self.truncateName = truncateName
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
                                .font(
                                    .system(size: truncateName ? 18 : 20)
                                )
                                .fontWidth(.compressed)
                                .fontWeight(truncateName ? .regular : .bold)
                                .fixedSize(horizontal: true, vertical: false)
                                .minimumScaleFactor(truncateName ? 1 : 0.5)
                                .lineLimit(1)
                                .layoutPriority(1)
                                .frame(width: truncateName ? 180 : nil, alignment: .leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                            if avatar.artifacts.isEmpty {
                                Spacer().frame(height: 20)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        private let truncateName: Bool

        @Default(.useAlternativeCharacterNames) private var useRealName: Bool

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

@available(iOS 17.0, macCatalyst 17.0, *)
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
        // 此處的計算內容包括開拓者、旅行者、奇偶。
        let allMainIntelStars = summaries.compactMap(\.wrappedValue.mainInfo.rarityStars)
        let a = allMainIntelStars.count
        let b = allMainIntelStars.filter { $0 == 5 }.count
        let c = allMainIntelStars.filter { $0 == 4 }.count
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
        // 此處的計算內容不包括開拓者、旅行者、奇偶。
        var charGold = 0
        var weaponGold = 0
        summaries.forEach { summaryPtr in
            let summary = summaryPtr.wrappedValue
            let mainInfo = summary.mainInfo
            if mainInfo.idExpressable.isProtagonist { return }
            if mainInfo.idExpressable.isManekin { return }
            if mainInfo.rarityStars == 5 {
                charGold += 1
                charGold += mainInfo.constellation
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

// MARK: CharacterInventoryView.ShareAsMasterPageView

@available(iOS 17.0, macCatalyst 17.0, *)
extension CharacterInventoryView {
    private struct ShareAsMasterPageView: View {
        // MARK: Lifecycle

        public init(profile: PZProfileSendable, showingAvatars: [CharacterInventoryView.SummaryPtr]) {
            self.profile = profile
            self.showingAvatars = showingAvatars
        }

        // MARK: Public

        public var body: some View {
            VStack(spacing: 0) {
                // Title
                HStack(alignment: .lastTextBaseline) {
                    Text(verbatim: profile.name).font(.title).bold()
                    Text(verbatim: profile.uid).font(.title3)
                }
                .padding(.bottom, 9)
                // 正文
                HStack(alignment: .top) {
                    ForEach(eachColumnAvatars, id: \.first!.id) { columnAvatars in
                        let view = VStack(alignment: .leading) {
                            ForEach(columnAvatars, id: \.id) { avatar in
                                CharacterInventoryView.AvatarListItem(
                                    game: profile.game,
                                    avatar: avatar,
                                    condensed: false,
                                    truncateName: true
                                )
                            }
                        }
                        .frame(width: 300)
                        if columnAvatars != eachColumnAvatars.last {
                            view.padding(.trailing)
                        } else {
                            view
                        }
                    }
                }
                HStack {
                    Spacer()
                    Image("AppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text(verbatim: Pizza.appTitleLocalizedFull).bold().font(.footnote)
                }
                .padding(.top, 2)
            }
            .padding()
            .background { Color.black }
            .environment(\.colorScheme, .dark)
        }

        // MARK: Private

        private let chunkSize = 16 // 每纵列的角色数
        private let profile: PZProfileSendable
        private let showingAvatars: [CharacterInventoryView.SummaryPtr]

        private var eachColumnAvatars: [[CharacterInventoryView.SummaryPtr]] {
            stride(from: 0, to: showingAvatars.count, by: chunkSize).map {
                let max = min($0 + chunkSize, showingAvatars.count)
                return showingAvatars[$0 ..< max].map(\.self)
            }
        }
    }
}

// MARK: CharacterInventoryView.InventoryEASVTabViewWrapper

@available(iOS 17.0, macCatalyst 17.0, *)
extension CharacterInventoryView {
    private struct InventoryEASVTabViewWrapper: View {
        // MARK: Lifecycle

        public init(selectedID: String, avatars: [Enka.AvatarSummarized]) {
            self.selectedID = selectedID
            self.avatars = avatars
        }

        // MARK: Public

        public var body: some View {
            AvatarStatCollectionTabView(
                selectedAvatarID: $selectedID,
                summarizedAvatars: avatars
            )
        }

        // MARK: Private

        @State private var selectedID: String

        private let avatars: [Enka.AvatarSummarized]
    }
}
