// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - BattleReportNav

@available(iOS 17.0, macCatalyst 17.0, *)
public struct BattleReportNav: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        if let profile = theVM.currentProfile {
            coreBody(profile: profile)
                .react(to: broadcaster.eventForRefreshingCurrentPage) {
                    theVM.refresh()
                }
        }
    }

    @ViewBuilder
    public func coreBody(profile: PZProfileSendable) -> some View {
        switch theVM.taskStatus4BattleReport {
        case .progress, .standby:
            InformationRowView(navTitle) {
                WinUI3ProgressRing().id(UUID())
            }
        case let .fail(error):
            InformationRowView(navTitle) {
                let region = profile.server.region.withGame(profile.game)
                let suffix: String = switch profile.game {
                case .genshinImpact:
                    HoYo.BattleReport4GI.TreasuresStarwardType.spiralAbyss.getAPIPath(
                        region: region
                    )
                case .starRail:
                    HoYo.BattleReport4HSR.TreasuresLightwardType.forgottenHall.getAPIPath(
                        region: region
                    )
                case .zenlessZone:
                    ""
                }
                let apiPath = URLRequestConfig.recordURLAPIHost(region: region) + suffix
                HoYoAPIErrorView(profile: profile, apiPath: apiPath, error: error) {
                    theVM.refresh()
                }
            }
        case let .succeed(data):
            if let data = data as? BattleReportSet4GI {
                InformationRowView(navTitle) {
                    NavigationLink(destination: data.asView.navigationTitle(navTitleTiny)) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            data.current.latestChallengeType?.asIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            let latestChallenge = data.current.latestChallengeIntel
                            if let latestChallenge {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(verbatim: "\(latestChallenge.deepestLevel)")
                                        .font(.title)
                                    switch latestChallenge.type {
                                    case .spiralAbyss:
                                        HStack(alignment: .center, spacing: 2) {
                                            BattleReportView4GI.drawAbyssStarIcon()
                                            Text(verbatim: " \(latestChallenge.totalStarsGained)")
                                                .font(.title3)
                                        }
                                    case .stygianOnslaught:
                                        HStack(alignment: .center, spacing: 2) {
                                            Image(systemSymbol: .timer)
                                                .foregroundStyle(.yellow)
                                                .shadow(radius: 4)
                                                .frame(width: 24, height: 24)
                                            Text(verbatim: "\(latestChallenge.totalStarsGained)s")
                                                .font(.title3)
                                        }
                                    }
                                }
                                Spacer()
                            } else {
                                Text("hylKit.battleReport.noDataAvailableForThisSeason".i18nHYLKit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else if let data = data as? BattleReportSet4HSR {
                InformationRowView(navTitle) {
                    NavigationLink(destination: data.asView.navigationTitle(navTitleTiny)) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            data.current.latestChallengeType?.asIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            let latestChallenge = data.current.latestChallengeIntel
                            if let latestChallenge {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(verbatim: "\(latestChallenge.deepestLevel)")
                                        .font(.title)
                                    HStack(alignment: .center, spacing: 2) {
                                        BattleReportView4HSR.drawAbyssStarIcon()
                                        Text(verbatim: " \(latestChallenge.totalStarsGained)")
                                            .font(.title3)
                                    }
                                }
                                Spacer()
                            } else {
                                Text("hylKit.battleReport.noDataAvailableForThisSeason".i18nHYLKit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Internal

    @MainActor var navTitle: String {
        switch theVM.currentProfile?.game {
        case .genshinImpact: BattleReportView4GI.navTitle
        case .starRail: BattleReportView4HSR.navTitle
        default: "N/A"
        }
    }

    @MainActor var navTitleTiny: String {
        switch theVM.currentProfile?.game {
        case .genshinImpact: BattleReportView4GI.navTitleTiny
        case .starRail: BattleReportView4HSR.navTitleTiny
        default: "N/A"
        }
    }

    // MARK: Private

    @Environment(DetailPortalViewModel.self) private var theVM
    @StateObject private var broadcaster = Broadcaster.shared
}
