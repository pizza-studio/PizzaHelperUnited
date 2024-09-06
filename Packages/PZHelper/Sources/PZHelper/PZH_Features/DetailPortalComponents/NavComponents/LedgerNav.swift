// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - LedgerNav

public struct LedgerNav: View {
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
        switch theVM.taskStatus4Ledger {
        case .progress:
            InformationRowView(navTitle) {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView(navTitle) {
                let region = profile.server.region.withGame(profile.game)
                let suffix = region.ledgerDataRetrievalPath
                let apiPath = URLRequestConfig.ledgerAPIURLHost(region: region) + suffix
                HoYoAPIErrorView(profile: profile, apiPath: apiPath, error: error) {
                    theVM.refresh()
                }
            }
        case let .succeed(data):
            if let data = data as? HoYo.LedgerData4GI {
                NavigationLink(destination: data.asView()) {
                    InformationRowView(navTitle) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            LedgerView4GI.primogemImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            Text(verbatim: "\(data.monthData.currentPrimogems)")
                                .font(.title)
                            Spacer()
                        }
                    }
                }
            } else if let data = data as? HoYo.LedgerData4HSR {
                NavigationLink(destination: data.asView()) {
                    InformationRowView(navTitle) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            LedgerView4HSR.stellarJadeImage
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            Text(verbatim: "\(data.monthData.currentStellarJades)")
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

    @MainActor var navTitle: String {
        switch theVM.currentProfile?.game {
        case .genshinImpact: LedgerView4GI.navTitle
        case .starRail: LedgerView4HSR.navTitle
        default: "N/A"
        }
    }

    // MARK: Private

    @State private var theVM: DetailPortalViewModel
    @State private var broadcaster = Broadcaster.shared
}
