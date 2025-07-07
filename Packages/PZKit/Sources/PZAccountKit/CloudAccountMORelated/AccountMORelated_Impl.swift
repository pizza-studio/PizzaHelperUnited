// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import PZCoreDataKit4LocalAccounts

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, *)
@available(iOSApplicationExtension, unavailable)
public typealias PZAccountMODebugView = AccountMODebugView
#endif

extension CDAccountMOActor {
    public func getAllAccountDataAsPZProfileSendable() throws -> [PZProfileSendable] {
        // Genshin.
        let genshinData: [PZProfileSendable]? = try allAccountData(for: .genshinImpact).compactMap { oldMO in
            var result = PZProfileSendable.makeInheritedInstanceWithRandomDeviceID(
                game: .genshinImpact, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        // StarRail.
        let hsrData: [PZProfileSendable]? = try allAccountData(for: .starRail).compactMap { oldMO in
            var result = PZProfileSendable.makeInheritedInstanceWithRandomDeviceID(
                game: .starRail, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        let dataSet: [PZProfileSendable] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet
    }
}
