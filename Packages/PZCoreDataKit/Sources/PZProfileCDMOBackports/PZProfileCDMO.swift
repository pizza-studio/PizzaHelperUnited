// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Foundation
import PZCoreDataKitShared
@preconcurrency import Sworm

// MARK: - PZProfileCDMO

/// PZProfileMO Backported for CoreData only.
public struct PZProfileCDMO: Hashable, Sendable, Identifiable, Codable {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var uid: String = "114514810"
    public var uuidRawValue: String = UUID().uuidString
    public var allowNotification: Bool = true
    public var cookie: String = ""
    public var deviceFingerPrint: String = ""
    public var name: String = ""
    public var priority: Int = 0
    public var serverRawValue: String = ""
    public var sTokenV2: String? = ""
    public var deviceID: String = UUID().uuidString
    public var serverBlob: Data = .init([]) // 暂时交给 Swift 自动处理 JSON Codec。
    public var gameBlob: Data = .init([]) // 暂时交给 Swift 自动处理 JSON Codec。
}

extension PZProfileCDMO {
    public var uuid: UUID {
        get {
            .init(uuidString: uuidRawValue) ?? .init()
        }
        set {
            uuidRawValue = newValue.uuidString
        }
    }

    public var id: UUID {
        uuid
    }
}

// MARK: ManagedObjectConvertible

extension PZProfileCDMO: ManagedObjectConvertible {
    public struct Relations: Sendable {}
    public static let relations: Relations = .init()
    public static let containerName: String = "PZProfileMO"
    public static let entityName: String = "PZProfileMO"
    public static let modelName: String = "PZProfileCDMO"
    public static let attributes: Set<Attribute<PZProfileCDMO>> = [
        .init(\.uid, "uid"),
        .init(\.uuidRawValue, "uuid"),
        .init(\.allowNotification, "allowNotification"),
        .init(\.cookie, "cookie"),
        .init(\.deviceFingerPrint, "deviceFingerPrint"),
        .init(\.name, "name"),
        .init(\.priority, "priority"),
        .init(\.serverRawValue, "serverRawValue"),
        .init(\.sTokenV2, "sTokenV2"),
        .init(\.deviceID, "deviceID"),
        .init(\.serverBlob, "server"),
        .init(\.gameBlob, "game"),
    ]
}

extension PZProfileCDMO {
    public static var cloudContainerID: String { PZCoreDataKit.iCloudContainerName }

    public static func primarySQLiteDBURL(useGroupContainer: Bool) -> URL? {
        let containerURL: URL? = useGroupContainer
            ? PZCoreDataKit.groupContainerURL
            : FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let containerURL else { return nil }
        return containerURL.appendingPathComponent("BackportedPZProfileMO4CoreData.sqlite")
    }

    public static func getManagedObjModel() -> NSManagedObjectModel {
        .init(
            contentsOf: Bundle.module.url(forResource: Self.modelName, withExtension: "momd")!
        )!
    }

    public static func getLoadedPersistentContainer(
        persistence: DBPersistenceMethod,
        useGroupContainer: Bool
    ) throws
        -> NSPersistentContainer {
        let container: NSPersistentContainer
        switch persistence {
        case .inMemory:
            container = NSPersistentContainer(name: Self.containerName, managedObjectModel: getManagedObjModel())
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        case .local:
            container = NSPersistentContainer(name: Self.containerName, managedObjectModel: getManagedObjModel())
        case .cloud:
            container = NSPersistentCloudKitContainer(
                name: Self.containerName,
                managedObjectModel: getManagedObjModel()
            )
            container.persistentStoreDescriptions.first?
                .cloudKitContainerOptions = .init(containerIdentifier: Self.cloudContainerID)
            container.persistentStoreDescriptions.first?.setOption(
                true as NSNumber,
                forKey: "NSPersistentStoreRemoteChangeNotificationOptionKey"
            )
        }
        checkIfNotInRAM: if persistence != .inMemory {
            let storeURL = primarySQLiteDBURL(useGroupContainer: useGroupContainer)
            guard let storeURL else { break checkIfNotInRAM }
            container.persistentStoreDescriptions.first?.url = storeURL
        }

        // Start initializing data.
        var error = Error?.none
        container.loadPersistentStores { _, catchedError in
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            error = catchedError
        }
        if let error = error { throw error }
        if persistence == .cloud {
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
            container.viewContext.refreshAllObjects()
        }

        return container
    }
}
