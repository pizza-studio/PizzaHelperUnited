// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation

// MARK: - Enka.ProfileSummarized

extension Enka {
    public struct ProfileSummarized<DBType: EnkaDBProtocol> {
        // MARK: Lifecycle

        public init(db theDB: DBType.QueriedProfile.DBType, rawInfo: DBType.QueriedProfile) {
            self.game = theDB.game
            self.theDB = theDB
            self.rawInfo = rawInfo
            self.summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB) // 肯定是一致的，不用怀疑了。
        }

        // MARK: Public

        public let game: Enka.GameType
        public private(set) var theDB: DBType.QueriedProfile.DBType
        public private(set) var rawInfo: DBType.QueriedProfile
        public private(set) var summarizedAvatars: [Enka.AvatarSummarized]

        public var nickName: String { rawInfo.nickname }
        public var uid: String { rawInfo.uid }
    }
}

extension Enka.ProfileSummarized {
    public mutating func update(newRawInfo: DBType.QueriedProfile, dropExistingData: Bool = false) {
        rawInfo = dropExistingData ? newRawInfo : newRawInfo.inheritAvatars(from: rawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
    }

    public mutating func evaluateArtifactRatings() {
        summarizedAvatars = summarizedAvatars.map { $0.artifactsRated() }
    }
}

// MARK: - Enka.ProfileSummarized + Hashable, Identifiable

extension Enka.ProfileSummarized: Hashable, Identifiable {
    public var id: Int {
        hashValue // 这里不能直接用 UID 了，因为需要处理单个 profile 被更新的情况。
    }

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
