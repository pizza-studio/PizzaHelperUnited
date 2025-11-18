// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import CoreData
import Foundation
import SwiftData

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PersistentIdentifier {
    /// Handle notification userinfo table brought by `ModelContext.didSave`.
    public static func parseObjectNames(notificationResult maybeUserInfo: [AnyHashable: Any]?) -> Set<String> {
        guard let userInfo = maybeUserInfo else { return [] }
        let allowedKeys: Set<String> = ["inserted", "updated", "deleted"]
        let entityNames = userInfo.reduce(into: Set<String>()) { result, element in
            let (key, value) = element
            let keyName: String
            if let stringKey = key as? String {
                keyName = stringKey
            } else {
                keyName = key.description
            }
            guard allowedKeys.contains(keyName) else { return }
            result.formUnion(getEntityNames(from: value))
        }
        #if DEBUG
        if let firstEntityName = entityNames.first, !(firstEntityName.hasPrefix("NSCK")) {
            print("Parsed SwiftData entity names: \(entityNames), from userInfo: \(userInfo)")
        }
        #endif
        return entityNames
    }

    private static func getEntityNames(from payload: Any?) -> Set<String> {
        if let identifiers = payload as? Set<PersistentIdentifier> {
            return Set(identifiers.map(\.entityName))
        }
        if let identifiers = payload as? [PersistentIdentifier] {
            return Set(identifiers.map(\.entityName))
        }
        return []
    }
}

extension NSManagedObjectID {
    /// Handle notification userinfo table brought by `NSManagedObjectContextDidSaveObjectIDs`.
    public static func parseObjectNames(notificationResult maybeUserInfo: [AnyHashable: Any]?) -> Set<String> {
        guard let userInfo = maybeUserInfo else { return [] }
        let entitiesNested: [Set<NSManagedObjectID>?] = [
            userInfo[NSInsertedObjectIDsKey] as? Set<NSManagedObjectID>,
            userInfo[NSUpdatedObjectIDsKey] as? Set<NSManagedObjectID>,
            userInfo[NSDeletedObjectIDsKey] as? Set<NSManagedObjectID>,
        ]
        let entityNames: Set<String> = entitiesNested.reduce(Set<String>()) { lhs, rhs in
            guard let rhs else { return lhs }
            return lhs.union(rhs.compactMap(\.entity.name))
        }
        #if DEBUG
        if let firstEntityName = entityNames.first, !(firstEntityName.hasPrefix("NSCK")) {
            print("Parsed CoreData entity names: \(entityNames), from userInfo: \(userInfo)")
        }
        #endif
        return entityNames
    }
}
