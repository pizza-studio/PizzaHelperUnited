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

    public init(theVM: Coordinator) {
        self.theVM = theVM
    }

    // MARK: Public

    @MainActor public var body: some View {
        if let profile = theVM.profile {
            coreBody(profile: profile)
        }
    }

    @MainActor @ViewBuilder
    public func coreBody(profile: PZProfileMO) -> some View {
        switch theVM.characterInventoryStatus {
        case .progress:
            InformationRowView(Self.navTitle) {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView(Self.navTitle) {
                let region = profile.server.region.withGame(profile.game)
                let suffix = region.characterInventoryRetrievalPath
                let apiPath = "https://api-takumi-record.mihoyo.com" + suffix
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
                    NavigationLink(destination: AnyView(data.asView(isMiyousheUID: false))) {
                        thisLabel
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

    @State private var theVM: Coordinator
}

// MARK: CharInventoryNav.Coordinator

extension CharInventoryNav {
    @Observable
    public final class Coordinator {
        // MARK: Lifecycle

        public init(profile: PZProfileMO? = nil) {
            self.profile = profile
            Task {
                await fetchCharacterInventoryList()
            }
        }

        // MARK: Public

        public enum Status<T> {
            case progress(Task<Void, Never>)
            case fail(Error)
            case succeed(T)
            case standby

            // MARK: Internal

            var isBusy: Bool {
                switch self {
                case .progress: return true
                default: return false
                }
            }
        }

        public var characterInventoryStatus: Status<any CharacterInventory> = .standby

        public weak var profile: PZProfileMO? {
            didSet {
                refresh()
            }
        }

        // MARK: Internal

        func refresh() {
            Task {
                await fetchCharacterInventoryList()
            }
        }

        // MARK: Private

        @MainActor
        private func fetchCharacterInventoryList() async {
            if case let .progress(task) = characterInventoryStatus { task.cancel() }
            let task = Task {
                do {
                    guard let profile = self.profile,
                          let queryResult = try await HoYo.getCharacterInventory(for: profile)
                    else { return }
                    Task.detached { @MainActor in
                        withAnimation {
                            self.characterInventoryStatus = .succeed(queryResult)
                        }
                    }
                } catch {
                    Task.detached { @MainActor in
                        withAnimation {
                            self.characterInventoryStatus = .fail(error)
                        }
                    }
                }
            }
            Task.detached { @MainActor in
                withAnimation {
                    self.characterInventoryStatus = .progress(task)
                }
            }
        }
    }
}
