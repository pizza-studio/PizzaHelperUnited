// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HYQueriedModels

public enum HYQueriedModels {}

// MARK: - HYQueriedAvatarProtocol

public protocol HYQueriedAvatarProtocol: Identifiable, Equatable, AbleToCodeSendHash {
    associatedtype DBType: EnkaDBProtocol where DBType.HYLAvatarDetailType == Self
    typealias List = [Self]
    var avatarIdStr: String { get }
    var id: Int { get }
    @MainActor
    func summarize(theDB: DBType) -> Enka.AvatarSummarized?
    @MainActor
    static func getLocalHoYoAvatars(theDB: DBType, uid: String) -> [Enka.AvatarSummarized]
    static func cacheLocalHoYoAvatars(uid: String, data: Data)
}
