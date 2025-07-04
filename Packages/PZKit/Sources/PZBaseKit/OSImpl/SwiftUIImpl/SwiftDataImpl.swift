// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftData

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension ModelActor {
    public func asyncInsert<T: PersistentModel>(_ model: T) throws {
        modelContext.insert(model)
    }

    public func asyncDelete<T: PersistentModel>(_ model: T) throws {
        modelContext.delete(model)
    }

    public func asyncSave() throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    public func asyncRollback() {
        if modelContext.hasChanges {
            modelContext.rollback()
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PersistentIdentifier {
    public static func parseObjectNames(notificationResult maybeUserInfo: [AnyHashable: Any]?) -> Set<String> {
        guard let userInfo = maybeUserInfo else { return [] }
        let entitiesNested: [[PersistentIdentifier]?] = [
            (userInfo["inserted"] as? [PersistentIdentifier]),
            userInfo["updated"] as? [PersistentIdentifier],
            userInfo["deleted"] as? [PersistentIdentifier],
        ]
        let entitiyNames: Set<String> = entitiesNested.reduce(Set<String>()) { lhs, rhs in
            guard let rhs else { return lhs }
            return lhs.union(rhs.map(\.entityName))
        }
        #if DEBUG
        if !entitiyNames.isEmpty {
            print(userInfo)
        }
        #endif
        return entitiyNames
    }
}
