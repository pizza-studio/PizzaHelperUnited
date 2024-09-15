// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import SwiftUI

extension Enka {
    public struct ProfileNameView: View {
        // MARK: Lifecycle

        public init(uid: String, game: Enka.GameType, name profileName: String? = nil) {
            self.uid = uid
            self.game = game
            self.profileName = profileName
        }

        // MARK: Public

        public let uid: String
        public let game: Enka.GameType
        public let profileName: String?

        @MainActor public var body: some View {
            if let profileName {
                Text(profileName)
            } else {
                switch game {
                case .genshinImpact:
                    if let profile = profiles4GI[uid] {
                        Text(profile.nickname)
                    } else {
                        Text(uid)
                            .onAppear {
                                Task { @MainActor in
                                    try? await Enka.Sputnik.shared.queryAndSave(uid: uid, game: game)
                                }
                            }
                    }
                case .starRail:
                    if let profile = profiles4HSR[uid] {
                        Text(profile.nickname)
                    } else {
                        Text(uid)
                            .onAppear {
                                Task { @MainActor in
                                    try? await Enka.Sputnik.shared.queryAndSave(uid: uid, game: game)
                                }
                            }
                    }
                case .zenlessZone: Text(uid) // 临时设定。
                }
            }
        }

        // MARK: Private

        @Default(.queriedEnkaProfiles4GI) private var profiles4GI
        @Default(.queriedEnkaProfiles4HSR) private var profiles4HSR
    }
}
