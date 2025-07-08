// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    public struct ProfileNameView: View {
        // MARK: Lifecycle

        public init(uid: String, game: Enka.GameType, name profileName: String? = nil, onlineUpdate: Bool = false) {
            self.uid = uid
            self.game = game
            self.profileName = profileName
            self.onlineUpdate = onlineUpdate
        }

        // MARK: Public

        public let uid: String
        public let game: Enka.GameType
        public let profileName: String?

        public var body: some View {
            if let profileName {
                Text(profileName)
            } else {
                Group {
                    switch game {
                    case .genshinImpact:
                        if let profile = sharedDB.db4GI.getCachedProfileRAW(uid: uid) {
                            Text(profile.nickname)
                        } else {
                            Text(uid)
                                .task(priority: .background) {
                                    if onlineUpdate {
                                        try? await Enka.Sputnik.commonActor.queryAndSave(uid: uid, game: game)
                                    }
                                }
                        }
                    case .starRail:
                        if let profile = sharedDB.db4HSR.getCachedProfileRAW(uid: uid) {
                            Text(profile.nickname)
                        } else {
                            Text(uid)
                                .task(priority: .background) {
                                    if onlineUpdate {
                                        try? await Enka.Sputnik.commonActor.queryAndSave(uid: uid, game: game)
                                    }
                                }
                        }
                    case .zenlessZone: Text(uid) // 临时设定。
                    }
                }
                .id(latestHash)
            }
        }

        // MARK: Private

        @State private var sharedDB: Enka.Sputnik = .shared
        @State private var broadcaster = Broadcaster.shared

        private let onlineUpdate: Bool

        private var uidWithGame: String { "\(game.uidPrefix)-\(uid)" }

        private var latestHash: Int {
            let mostRecentDate = broadcaster.eventForUpdatingLocalEnkaAvatarCache[uidWithGame]
            let timeInterval = (mostRecentDate ?? .distantPast).timeIntervalSince1970
            return timeInterval.hashValue
        }
    }
}
