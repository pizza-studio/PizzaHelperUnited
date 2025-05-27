// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - AbyssReportNav

public struct AbyssReportNav: View {
    // MARK: Lifecycle

    public init(theVM: DetailPortalViewModel) {
        self._theVM = .init(wrappedValue: theVM)
    }

    // MARK: Public

    public var body: some View {
        if let profile = theVM.currentProfile {
            coreBody(profile: profile)
                .onChange(of: broadcaster.eventForRefreshingCurrentPage) {
                    theVM.refresh()
                }
        }
    }

    @ViewBuilder
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
                InformationRowView(navTitle) {
                    NavigationLink(destination: data.asView.navigationTitle(navTitleTiny)) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            AbyssReportView4GI.abyssIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            if !data.current.floors.isEmpty {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(verbatim: "\(data.current.maxFloor)")
                                        .font(.title)
                                    HStack(alignment: .center, spacing: 2) {
                                        AbyssReportView4GI.drawAbyssStarIcon()
                                        Text(verbatim: " \(data.current.totalStar)")
                                            .font(.title3)
                                    }
                                }
                                Spacer()
                            } else {
                                Text("hylKit.abyssReport.noDataAvailableForThisSeason".i18nHYLKit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else if let data = data as? AbyssReportSet4HSR {
                InformationRowView(navTitle) {
                    NavigationLink(destination: data.asView.navigationTitle(navTitleTiny)) {
                        HStack(spacing: 10) {
                            let iconFrame: CGFloat = 40
                            AbyssReportView4HSR.abyssIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame, height: iconFrame)
                            let fhData = data.current.forgottenHall
                            if fhData.hasData {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(verbatim: "\(fhData.maxFloorNumStr)")
                                        .font(.title)
                                    HStack(alignment: .center, spacing: 2) {
                                        AbyssReportView4GI.drawAbyssStarIcon()
                                        Text(verbatim: " \(fhData.starNum)")
                                            .font(.title3)
                                    }
                                }
                                Spacer()
                            } else {
                                Text("hylKit.abyssReport.noDataAvailableForThisSeason".i18nHYLKit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
        case .genshinImpact: AbyssReportView4GI.navTitle
        case .starRail: AbyssReportView4HSR.navTitle
        default: "N/A"
        }
    }

    @MainActor var navTitleTiny: String {
        switch theVM.currentProfile?.game {
        case .genshinImpact: AbyssReportView4GI.navTitleTiny
        case .starRail: AbyssReportView4HSR.navTitleTiny
        default: "N/A"
        }
    }

    // MARK: Private

    @StateObject private var theVM: DetailPortalViewModel
    @StateObject private var broadcaster = Broadcaster.shared
}
