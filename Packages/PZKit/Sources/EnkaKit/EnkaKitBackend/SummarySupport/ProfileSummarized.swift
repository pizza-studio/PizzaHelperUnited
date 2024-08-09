// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation

// MARK: - Enka.ProfileSummarized

extension Enka {
    @Observable
    public class ProfileSummarized {
        // MARK: Lifecycle

        public init(hsrDB: EnkaDB4HSR, rawInfo: QueriedProfileHSR) {
            self.game = .starRail
            self.hsrDB = hsrDB
            self.rawInfo = rawInfo
            self.summarizedAvatars = rawInfo.summarizeAllAvatars(hsrDB: hsrDB)
        }

        // MARK: Public

        public let game: Enka.GameType
        public private(set) var hsrDB: EnkaDB4HSR
        public private(set) var rawInfo: QueriedProfileHSR
        public private(set) var summarizedAvatars: [Enka.AvatarSummarized]
    }
}

extension Enka.ProfileSummarized {
    @MainActor
    public func update(
        newRawInfo: Enka.QueriedProfileHSR, dropExistingData: Bool = false
    ) {
        var newInfoMutable = newRawInfo
        rawInfo = dropExistingData ? newRawInfo : newInfoMutable.merge(old: rawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(hsrDB: hsrDB)
    }
}

// MARK: - Summerizer APIs for Star Rail.

extension Enka.QueriedProfileHSR {
    public func summarizeAllAvatars(hsrDB: Enka.EnkaDB4HSR) -> [Enka.AvatarSummarized] {
        avatarDetailList.compactMap { $0.summarize(hsrDB: hsrDB) }
    }

    public func summarize(hsrDB: Enka.EnkaDB4HSR) -> Enka.ProfileSummarized {
        .init(hsrDB: hsrDB, rawInfo: self)
    }

    public func accountPhotoFileNameStem(hsrDB: Enka.EnkaDB4HSR) -> String {
        let str = hsrDB.profileAvatars[headIcon.description]?
            .icon.split(separator: "/").last?.description ?? "114514.png"
        return "avatar_\(str)".replacingOccurrences(of: ".png", with: "")
    }

    public static var nullPhotoAssetName: String {
        "avatar_Anonymous"
    }
}
