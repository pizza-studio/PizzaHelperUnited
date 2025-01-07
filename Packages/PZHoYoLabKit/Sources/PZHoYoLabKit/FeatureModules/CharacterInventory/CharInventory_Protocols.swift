// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - CharacterInventory

public protocol CharacterInventory: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
    associatedtype AvatarType: HYAvatar
    var avatars: [AvatarType] { get }
}

// MARK: - HYAvatar

public protocol HYAvatar: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: Int { get }
    var rarity: Int { get }
    var icon: String { get }
}

extension HYAvatar {
    public var firstCostumeID: Int? {
        guard let this = self as? HoYo.CharInventory4GI.HYAvatar4GI else { return nil }
        return this.costumeIDs?.first
    }
}
