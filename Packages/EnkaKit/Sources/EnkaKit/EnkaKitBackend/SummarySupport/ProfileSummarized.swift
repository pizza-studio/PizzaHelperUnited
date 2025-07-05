// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

// MARK: - Enka.ProfileSummarized

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka {
    public struct ProfileSummarized<DBType: EnkaDBProtocol>: Sendable {
        // MARK: Lifecycle

        @MainActor
        public init(
            db theDB: DBType.QueriedProfile.DBType,
            rawInfo: DBType.QueriedProfile,
            appendHoYoLABResults: Bool = false
        ) {
            self.game = theDB.game
            self.theDB = theDB
            self.rawInfo = rawInfo
            self.summarizedAvatars = rawInfo.summarizeAllAvatars(
                theDB: theDB,
                appendHoYoLABResults: appendHoYoLABResults
            ) // 肯定是一致的，不用怀疑了。
            self.appendHoYoLABResults = appendHoYoLABResults
        }

        // MARK: Public

        public let game: Enka.GameType
        public let appendHoYoLABResults: Bool
        public private(set) var theDB: DBType.QueriedProfile.DBType
        public private(set) var rawInfo: DBType.QueriedProfile
        public private(set) var summarizedAvatars: [Enka.AvatarSummarized]

        public var nickName: String { rawInfo.nickname }
        public var uid: String { rawInfo.uid }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.ProfileSummarized {
    @MainActor
    public mutating func update(
        newRawInfo: DBType.QueriedProfile,
        dropExistingData: Bool = false
    ) {
        rawInfo = (dropExistingData || appendHoYoLABResults)
            ? newRawInfo
            : newRawInfo.inheritAvatars(from: rawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(
            theDB: theDB,
            appendHoYoLABResults: appendHoYoLABResults
        )
    }

    @MainActor
    public mutating func evaluateArtifactRatings() {
        summarizedAvatars = summarizedAvatars.map { $0.artifactsRated() }
    }
}

// MARK: - Enka.ProfileSummarized + Hashable, Identifiable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.ProfileSummarized: Hashable, Identifiable {
    public var id: Int {
        hashValue // 这里不能直接用 UID 了，因为需要处理单个 profile 被更新的情况。
    }

    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawInfo)
        hasher.combine(summarizedAvatars)
    }
}

// MARK: - Enka.ProfileSummarized + Equatable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.ProfileSummarized: Equatable {
    public static func == (lhs: Enka.ProfileSummarized<DBType>, rhs: Enka.ProfileSummarized<DBType>) -> Bool {
        lhs.rawInfo == rhs.rawInfo && lhs.summarizedAvatars == rhs.summarizedAvatars
    }
}

// MARK: - Summerizer APIs.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension EKQueriedProfileProtocol {
    @MainActor
    public func summarizeAllAvatars(
        theDB: DBType.QueriedProfile.DBType,
        appendHoYoLABResults: Bool = false
    )
        -> [Enka.AvatarSummarized] {
        var finalResult = avatarDetailList.compactMap {
            $0.summarize(theDB: theDB)
        }
        guard appendHoYoLABResults else { return finalResult }
        let existingCharIDs = avatarDetailList.map(\.avatarId.description)
        let restAvatars = Self.DBType.HYLAvatarDetailType.getLocalHoYoAvatars(theDB: theDB, uid: uid)
        restAvatars.forEach { currentAvatar in
            guard !existingCharIDs.contains(currentAvatar.id) else { return }
            finalResult.append(currentAvatar)
        }
        return finalResult
    }

    @MainActor
    public func summarize(
        theDB: DBType,
        appendHoYoLABResults: Bool = false
    )
        -> Enka.ProfileSummarized<Self.DBType> {
        .init(db: theDB, rawInfo: self, appendHoYoLABResults: appendHoYoLABResults)
    }
}
