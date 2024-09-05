// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - TravelStatsNav

public struct TravelStatsNav: View {
    // MARK: Lifecycle

    public init(theVM: DetailPortalViewModel) {
        self.theVM = theVM
    }

    // MARK: Public

    @MainActor public var body: some View {
        if let profile = theVM.currentProfile {
            coreBody(profile: profile)
                .onChange(of: broadcaster.eventForRefreshingCurrentPage) {
                    theVM.refresh()
                }
        }
    }

    @MainActor @ViewBuilder
    public func coreBody(profile: PZProfileMO) -> some View {
        switch theVM.taskStatus4TravelStats {
        case .progress:
            InformationRowView(navTitle) {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView(navTitle) {
                let region = profile.server.region.withGame(profile.game)
                let suffix = region.genshinTravelStatsDataRetrievalPath
                let apiPath = URLRequestConfig.recordURLAPIHost(region: region) + suffix
                HoYoAPIErrorView(profile: profile, apiPath: apiPath, error: error) {
                    theVM.refresh()
                }
            }
        case let .succeed(data):
            InformationRowView(navTitle) {
                if let data = data as? HoYo.TravelStatsData4GI {
                    NavigationLink(destination: data.asView()) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            TravelStatsView4GI.treasureBoxImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            Text(verbatim: "\(data.stats.luxuriousChestNumber)")
                                .font(.title)
                            Spacer()
                        }
                    }
                } else if let data = data as? HoYo.TravelStatsData4HSR {
                    NavigationLink(destination: data.asView()) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            TravelStatsView4HSR.treasureBoxImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            Text(verbatim: "\(data.stats.chestNum)")
                                .font(.title)
                            Spacer()
                        }
                    }
                }
            }
        case .standby:
            EmptyView()
        }
    }

    // MARK: Internal

    var navTitle: String {
        switch theVM.currentProfile?.game {
        case .genshinImpact: TravelStatsView4GI.navTitle
        case .starRail: TravelStatsView4HSR.navTitle
        default: "N/A"
        }
    }

    // MARK: Private

    @State private var theVM: DetailPortalViewModel
    @State private var broadcaster = Broadcaster.shared
}
