// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import PZBaseKit
import PZCoreDataKit4LocalAccounts
@preconcurrency import Sworm

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(iOSApplicationExtension, unavailable)
public typealias PZAccountMODebugView = AccountMODebugView
#endif

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension AccountMOSputnik {
    public func getAllAccountDataAsPZProfileSendable() throws -> [PZProfileSendable] {
        // Genshin.
        let genshinData: [PZProfileRef]? = try allAccountData(for: .genshinImpact).compactMap { oldMO in
            let result = PZProfileRef.makeInheritedInstance(
                game: .genshinImpact, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        // StarRail.
        let hsrData: [PZProfileRef]? = try allAccountData(for: .starRail).compactMap { oldMO in
            let result = PZProfileRef.makeInheritedInstance(
                game: .starRail, uid: oldMO.uid, configuration: oldMO
            )
            result?.deviceID = oldMO.uuid.uuidString
            return result
        }
        let dataSet: [PZProfileRef] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet.map(\.asSendable)
    }
}
