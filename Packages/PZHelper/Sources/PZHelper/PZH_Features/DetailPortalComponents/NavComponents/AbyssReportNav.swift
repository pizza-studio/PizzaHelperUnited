// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - AbyssReportNav

public struct AbyssReportNav: View {
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
        switch theVM.taskStatus4AbyssReport {
        case .progress:
            InformationRowView(navTitle) {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView(navTitle) {
                let region = profile.server.region.withGame(profile.game)
                let suffix = region.abyssReportRetrievalPath
                let apiPath = URLRequestConfig.recordURLAPIHost(region: region) + suffix
                HoYoAPIErrorView(profile: profile, apiPath: apiPath, error: error) {
                    theVM.refresh()
                }
            }
        case let .succeed(data):
            if let data = data as? AbyssReportSet4GI {
                NavigationLink(destination: data.current.asView()) {
                    InformationRowView(navTitle) {
                        Text(verbatim: "Abyss Data")
                    }
                }
                if let prevData = data.previous {
                    NavigationLink(destination: prevData.asView()) {
                        InformationRowView(navTitle) {
                            Text(verbatim: "Abyss Data (Previous)")
                        }
                    }
                }
            } else if let data = data as? AbyssReportSet4HSR {
                NavigationLink(destination: data.current.asView()) {
                    InformationRowView(navTitle) {
                        Text(verbatim: "Abyss Data")
                    }
                }
                if let prevData = data.previous {
                    NavigationLink(destination: prevData.asView()) {
                        InformationRowView(navTitle) {
                            Text(verbatim: "Abyss Data (Previous)")
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
        case .genshinImpact: AbyssReportView4GI.navTitle
        case .starRail: AbyssReportView4HSR.navTitle
        default: "N/A"
        }
    }

    // MARK: Private

    @State private var theVM: DetailPortalViewModel
    @State private var broadcaster = Broadcaster.shared
}
