// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Defaults
import Foundation
import Observation

// MARK: - Enka.ProfileSummarized

extension Enka {
    @Observable
    public class ProfileSummarized<P: EKQueriedProfileProtocol> {
        // MARK: Lifecycle

        public init(db theDB: DBType, rawInfo: P) {
            self.game = theDB.game
            self.theDB = theDB
            self.rawInfo = rawInfo
            self.summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB) // 肯定是一致的，不用怀疑了。

            cancellables.append(
                Defaults.publisher(.artifactRatingRules).sink { _ in
                    Task.detached { @MainActor in
                        self.evaluateArtifactRatings() // 选项有变更时，给圣遗物重新评分。
                    }
                }
            )
            cancellables.append(
                Defaults.publisher(.useRealCharacterNames).sink { _ in
                    Task.detached { @MainActor in
                        self.update(newRawInfo: rawInfo, dropExistingData: false)
                    }
                }
            )
            cancellables.append(
                Defaults.publisher(.forceCharacterWeaponNameFixed).sink { _ in
                    Task.detached { @MainActor in
                        self.update(newRawInfo: rawInfo, dropExistingData: false)
                    }
                }
            )
            cancellables.append(
                Defaults.publisher(.customizedNameForWanderer).sink { _ in
                    Task.detached { @MainActor in
                        self.update(newRawInfo: rawInfo, dropExistingData: false)
                    }
                }
            )
        }

        // MARK: Public

        public typealias OriginType = P

        public typealias DBType = P.DBType

        public let game: Enka.GameType
        public private(set) var theDB: DBType
        public private(set) var rawInfo: P
        public private(set) var summarizedAvatars: [Enka.AvatarSummarized]

        // MARK: Private

        private var cancellables: [AnyCancellable] = []
    }
}

extension Enka.ProfileSummarized {
    @MainActor
    public func update(newRawInfo: P, dropExistingData: Bool = false) {
        rawInfo = dropExistingData ? newRawInfo : newRawInfo.inheritAvatars(from: rawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
    }

    @MainActor
    public func evaluateArtifactRatings() {
        summarizedAvatars = summarizedAvatars.map { $0.artifactsRated() }
    }
}

// MARK: - Summerizer APIs for Star Rail.

extension EKQueriedProfileProtocol {
    public func summarizeAllAvatars(theDB: DBType) -> [Enka.AvatarSummarized] {
        avatarDetailList.compactMap {
            $0.summarize(theDB: theDB)
        }
    }

    public func summarize(theDB: DBType) -> Enka.ProfileSummarized<Self> {
        .init(db: theDB, rawInfo: self)
    }
}
