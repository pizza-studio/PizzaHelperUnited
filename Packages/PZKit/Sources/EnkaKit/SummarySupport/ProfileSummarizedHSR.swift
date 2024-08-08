// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation

// MARK: - Enka.ProfileSummarizedHSR

extension Enka {
    @Observable
    public class ProfileSummarizedHSR {
        // MARK: Lifecycle

        public init(theDB: EnkaDB4HSR, rawInfo: QueriedProfileHSR) {
            self.theDB = theDB
            self.rawInfo = rawInfo
            self.summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
        }

        // MARK: Public

        public private(set) var theDB: EnkaDB4HSR
        public private(set) var rawInfo: QueriedProfileHSR
        public private(set) var summarizedAvatars: [Enka.AvatarSummarizedHSR]
    }
}

extension Enka.ProfileSummarizedHSR {
    @MainActor
    public func update(
        newRawInfo: Enka.QueriedProfileHSR, dropExistingData: Bool = false
    ) {
        var newInfoMutable = newRawInfo
        rawInfo = dropExistingData ? newRawInfo : newInfoMutable.merge(old: rawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
    }
}

extension Enka.QueriedProfileHSR {
    public func summarizeAllAvatars(theDB: Enka.EnkaDB4HSR) -> [Enka.AvatarSummarizedHSR] {
        avatarDetailList.compactMap { $0.summarize(theDB: theDB) }
    }

    public func summarize(theDB: Enka.EnkaDB4HSR) -> Enka.ProfileSummarizedHSR {
        .init(theDB: theDB, rawInfo: self)
    }

    public func accountPhotoFileNameStem(theDB: Enka.EnkaDB4HSR) -> String {
        let str = theDB.profileAvatars[headIcon.description]?
            .icon.split(separator: "/").last?.description ?? "114514.png"
        return "avatar_\(str)".replacingOccurrences(of: ".png", with: "")
    }

    public static var nullPhotoAssetName: String {
        "avatar_Anonymous"
    }
}
