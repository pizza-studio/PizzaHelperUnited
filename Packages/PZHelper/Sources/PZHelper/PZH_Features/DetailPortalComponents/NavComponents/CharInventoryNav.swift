// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - CharInventoryNav

public struct CharInventoryNav: View {
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
        switch theVM.taskStatus4CharInventory {
        case .progress:
            InformationRowView(Self.navTitle) {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView(Self.navTitle) {
                let region = profile.server.region.withGame(profile.game)
                let suffix = region.characterInventoryRetrievalPath
                let apiPath = URLRequestConfig.recordURLAPIHost(region: region) + suffix
                HoYoAPIErrorView(profile: profile, apiPath: apiPath, error: error) {
                    theVM.refresh()
                }
            }
        case let .succeed(data):
            InformationRowView(Self.navTitle) {
                let thisLabel = HStack(spacing: 3) {
                    ForEach(data.avatars.prefix(5), id: \.id) { avatar in
                        if let charIdExp = Enka.AvatarSummarized.CharacterID(
                            id: avatar.id.description, costumeID: avatar.firstCostumeID?.description
                        ) {
                            charIdExp.avatarPhoto(
                                size: 30, circleClipped: true, clipToHead: true
                            )
                        } else {
                            Color.gray.frame(width: 30, height: 30, alignment: .top).clipShape(Circle())
                                .overlay(alignment: .top) {
                                    AsyncImage(url: avatar.icon.asURL) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                        }
                    }
                }
                if data.avatars.isEmpty {
                    Text("dpv.characterInventory.notice.EmptyInventoryResult".i18nPZHelper).font(.caption)
                } else {
                    if let data = data as? HoYo.CharInventory4GI {
                        NavigationLink(destination: data.asView(isMiyousheUID: false)) {
                            thisLabel
                        }
                    } else if let data = data as? HoYo.CharInventory4HSR {
                        NavigationLink(destination: data.asView(isMiyousheUID: false)) {
                            thisLabel
                        }
                    }
                }
            }
        case .standby:
            EmptyView()
        }
    }

    // MARK: Internal

    static let navTitle = "dpv.characterInventory.navTitle".i18nPZHelper

    // MARK: Private

    @State private var theVM: DetailPortalViewModel
    @State private var broadcaster = Broadcaster.shared
}
