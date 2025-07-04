// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import PZBaseKit
import PZCoreDataKit4LocalAccounts
@preconcurrency import Sworm

public typealias PZAccountMODebugView = AccountMODebugView

extension AccountMOSputnik {
    public func getAllAccountDataAsPZProfileSendable() throws -> [PZProfileSendable] {
        // Genshin.
        let genshinData: [PZProfileMO]? = try allAccountData(for: .genshinImpact).compactMap { oldMO in
            let result = PZProfileMO.makeInheritedInstance(
                game: .genshinImpact, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        // StarRail.
        let hsrData: [PZProfileMO]? = try allAccountData(for: .starRail).compactMap { oldMO in
            let result = PZProfileMO.makeInheritedInstance(
                game: .starRail, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        let dataSet: [PZProfileMO] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet.map(\.asSendable)
    }
}
