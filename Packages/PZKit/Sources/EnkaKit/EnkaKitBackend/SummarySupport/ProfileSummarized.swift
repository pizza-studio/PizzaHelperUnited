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
    public final class ProfileSummarized<DBType: EnkaDBProtocol> {
        // MARK: Lifecycle

        public init(db theDB: DBType.QueriedProfile.DBType, rawInfo: DBType.QueriedProfile) {
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

        public let game: Enka.GameType
        public private(set) var theDB: DBType.QueriedProfile.DBType
        public private(set) var rawInfo: DBType.QueriedProfile
        public private(set) var summarizedAvatars: [Enka.AvatarSummarized]

        public var nickName: String { rawInfo.nickname }
        public var uid: String { rawInfo.uid }

        // MARK: Private

        private var cancellables: [AnyCancellable] = []
    }
}

extension Enka.ProfileSummarized {
    @MainActor
    public func update(newRawInfo: DBType.QueriedProfile, dropExistingData: Bool = false) {
        rawInfo = dropExistingData ? newRawInfo : newRawInfo.inheritAvatars(from: rawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
    }

    @MainActor
    public func evaluateArtifactRatings() {
        summarizedAvatars = summarizedAvatars.map { $0.artifactsRated() }
    }
}

// MARK: - Enka.ProfileSummarized + Hashable

extension Enka.ProfileSummarized: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawInfo)
        hasher.combine(summarizedAvatars)
    }
}

// MARK: - Enka.ProfileSummarized + Equatable

extension Enka.ProfileSummarized: Equatable {
    public static func == (lhs: Enka.ProfileSummarized<DBType>, rhs: Enka.ProfileSummarized<DBType>) -> Bool {
        lhs.rawInfo == rhs.rawInfo && lhs.summarizedAvatars == rhs.summarizedAvatars
    }
}

// MARK: - Summerizer APIs for Star Rail.

extension EKQueriedProfileProtocol {
    public func summarizeAllAvatars(theDB: DBType.QueriedProfile.DBType) -> [Enka.AvatarSummarized] {
        avatarDetailList.compactMap {
            $0.summarize(theDB: theDB)
        }
    }

    public func summarize(theDB: DBType) -> Enka.ProfileSummarized<Self.DBType> {
        .init(db: theDB, rawInfo: self)
    }
}
