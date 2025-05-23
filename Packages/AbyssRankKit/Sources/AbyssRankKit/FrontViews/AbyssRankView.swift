// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - AbyssRankView

public struct AbyssRankView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle = "abyssRankKit.rank.title".i18nAbyssRank
    public static let navDescription = "abyssRankKit.rank.navDescription".i18nAbyssRank

    @MainActor public static var navIcon: Image {
        Image("gi_tools_abyssRank", bundle: .module)
    }

    public var body: some View {
        VStack {
            switch vmAbyssRank.showingType {
            case .abyssAvatarsUtilization:
                ShowAvatarPercentageViewWithSection()
            case .pvpUtilization:
                if getRemainDays("2023-04-01 00:04:00")!.second! < 0 {
                    ShowAvatarPercentageViewWithSection()
                } else {
                    VStack {
                        Image(systemSymbol: .clockBadgeExclamationmark)
                            .font(.largeTitle)
                        Text("abyssRankKit.availableSince20230401", bundle: .module)
                            .padding()
                            .font(.headline)
                    }
                }
            case .fullStarHoldingRate, .holdingRate:
                ShowAvatarPercentageView()
            case .teamUtilization:
                ShowTeamPercentageView()
            }
        }
        .environment(vmAbyssRank)
        .navBarTitleDisplayMode(.inline)
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                NavigationLink {
                    WebBrowserView(url: Self.faqURL)
                        .navigationTitle("abyssRankKit.rank.faq".i18nAbyssRank)
                        .navBarTitleDisplayMode(.inline)
                } label: {
                    Image(systemSymbol: .questionmarkCircle)
                }
            }
            ToolbarItem(placement: .principal) {
                Menu {
                    ForEach(
                        AbyssRankViewModel.ShowingData.allCases,
                        id: \.rawValue
                    ) { choice in
                        Button(choice.rawValue.i18nAbyssRank) {
                            withAnimation {
                                vmAbyssRank
                                    .showingType = choice
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemSymbol: .arrowLeftArrowRightCircle)
                        Text(vmAbyssRank.showingType.rawValue.i18nAbyssRank)
                    }
                }
            }
            ToolbarItemGroup(placement: .status) {
                switch vmAbyssRank.showingType {
                case .holdingRate:
                    AvatarHoldingParamsSettingBar(
                        params: $vmAbyssRank
                            .holdingParam
                    ).lineLimit(1)
                case .fullStarHoldingRate:
                    FullStarAvatarHoldingParamsSettingBar(
                        params: $vmAbyssRank
                            .fullStarHoldingParam
                    ).lineLimit(1)
                case .abyssAvatarsUtilization:
                    UtilizationParasSettingBar(
                        params: $vmAbyssRank
                            .utilizationParams
                    ).lineLimit(1)
                case .teamUtilization:
                    TeamUtilizationParasSettingBar(
                        params: $vmAbyssRank
                            .teamUtilizationParams
                    ).lineLimit(1)
                case .pvpUtilization:
                    UtilizationParasSettingBar(
                        pvp: true,
                        params: $vmAbyssRank
                            .pvpUtilizationParams
                    ).lineLimit(1)
                }
            }
        }
        .onAppear {
            Task { @MainActor in
                if !vmAbyssRank.initialized {
                    await vmAbyssRank.getData()
                    vmAbyssRank.initialized.toggle()
                }
            }
        }
        .onChange(of: vmAbyssRank.showingType) {
            Task { @MainActor in
                await vmAbyssRank.getData()
            }
        }
        .onChange(of: vmAbyssRank.holdingParam) {
            Task { @MainActor in
                await vmAbyssRank.getAvatarHoldingResult()
            }
        }
        .onChange(of: vmAbyssRank.fullStarHoldingParam) {
            Task { @MainActor in
                await vmAbyssRank.getFullStarHoldingResult()
            }
        }
        .onChange(of: vmAbyssRank.utilizationParams) {
            Task { @MainActor in
                await vmAbyssRank.getUtilizationResult()
            }
        }
        .onChange(of: vmAbyssRank.teamUtilizationParams) {
            Task { @MainActor in
                await vmAbyssRank.getTeamUtilizationResult()
            }
        }
        .onChange(of: vmAbyssRank.pvpUtilizationParams) {
            Task { @MainActor in
                await vmAbyssRank.getPVPUtilizationResult()
            }
        }
    }

    // MARK: Private

    private typealias IntervalDate = (
        month: Int?,
        day: Int?,
        hour: Int?,
        minute: Int?,
        second: Int?
    )

    private static let faqURL: String = {
        switch Bundle.main.preferredLocalizations.first?.prefix(2) {
        case "zh": "https://gi.pizzastudio.org/static/faq_abyss.html"
        case "en": "https://gi.pizzastudio.org/static/faq_abyss_en.html"
        case "ja": "https://gi.pizzastudio.org/static/faq_abyss_ja.html"
        default: "https://gi.pizzastudio.org/static/faq_abyss_en.html"
        }
    }()

    @StateObject private var vmAbyssRank: AbyssRankViewModel = .init()

    @Default(.defaultServer) private var defaultServer4GI: String

    private func getRemainDays(_ endAt: String) -> Date.IntervalDate? {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let cachedServerTyped = HoYo.Server(rawValue: defaultServer4GI) ?? .asia(.genshinImpact)
        dateFormatter.timeZone = cachedServerTyped.timeZone
        let endDate = dateFormatter.date(from: endAt)
        guard let endDate = endDate else {
            return nil
        }
        let interval = endDate - Date()
        return interval
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AbyssRankView()
    }
}
#endif
