// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKitShared
import PZProfileCDMOBackports
import SwiftData

extension PZProfileCDMO: ProfileProtocol {
    public var game: Pizza.SupportedGame {
        get {
            let matchedRaw = try? SDStringEnumCodec.decodeRawValue(from: gameBlob)
            guard let matchedRaw else { return .genshinImpact }
            return Pizza.SupportedGame(rawValue: matchedRaw) ?? .genshinImpact
        }
        set {
            do {
                gameBlob = try SDStringEnumCodec.encodeRawValue(newValue.rawValue, forKey: "game")
            } catch {
                // Do not handle. This shouldn't happen.
                return
            }
        }
    }

    public var server: HoYo.Server {
        get {
            let matchedRaw = try? SDStringEnumCodec.decodeRawValue(from: serverBlob)
            guard let matchedRaw else { return .celestia(game) }
            return .init(rawValue: matchedRaw)?.withGame(game) ?? .celestia(game)
        }
        set {
            do {
                serverBlob = try SDStringEnumCodec.encodeRawValue(newValue.rawValue, forKey: "server")
            } catch {
                // Do not handle. This shouldn't happen.
                return
            }
        }
    }
}
