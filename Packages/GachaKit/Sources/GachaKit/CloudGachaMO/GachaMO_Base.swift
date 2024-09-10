// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Foundation
import PZBaseKit
@preconcurrency import Sworm

// MARK: - GachaMOProtocol

/// GachaMO 不是统一披萨助手引擎用来主要处理的格式，而是专门针对 CloudKit 做的资料交换格式。
/// 这也是为了方便直接继承旧版原披助手与穹披助手的云端资料。
/// GachaMO 不曝露给前端使用，不直接用于 SwiftUI。

public protocol GachaMOProtocol {
    var id: String { get set }
    var uid: String { get set }
    var name: String { get set }
    var time: Date { get set }
    static var entityName: String { get }
    static var modelName: String { get }
    static var containerName: String { get }
    static var cloudContainerID: String { get }
    static var game: Pizza.SupportedGame { get }
}

extension GachaMOProtocol {
    public var enumID: Int { [id, uid, name, "\(time.timeIntervalSince1970)"].hashValue }
    public var entityName: String { Self.entityName }
    public var modelName: String { Self.modelName }
    public var containerName: String { Self.containerName }
    public var game: Pizza.SupportedGame { Self.game }
    public var cloudContainerID: String { Self.cloudContainerID }

    public static func getManagedObjModel() -> NSManagedObjectModel {
        .init(
            contentsOf: Bundle.module.url(forResource: Self.modelName, withExtension: "momd")!
        )!
    }

    public static func getLoadedPersistentContainer(persistence: DBPersistenceMethod) throws -> NSPersistentContainer {
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
        if let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
           persistence != .inMemory {
            let storeURL = containerURL.appendingPathComponent("\(sharedBundleIDHeader)/\(modelName).sqlite")
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

// MARK: - GachaMO4GI

/// 原披助手专用，不曝露。
struct GachaMO4GI: ManagedObjectConvertible, GachaMOProtocol {
    public struct Relations {}

    public static let cloudContainerID: String = "iCloud.com.Canglong.PizzaGachaLog" // 没机会纠正了。
    public static let containerName: String = "PizzaGachaLog"
    public static let entityName: String = "GachaItemMO"
    public static let modelName: String = "GachaMO4GI"
    public static let relations = Relations()
    public static let attributes: Set<Attribute<GachaMO4GI>> = [
        .init(\.count, "count"),
        .init(\.gachaType, "gachaType"),
        .init(\.id, "id"),
        .init(\.itemId, "itemId"),
        .init(\.itemType, "itemType"),
        .init(\.lang, "lang"),
        .init(\.name, "name"),
        .init(\.rankType, "rankType"),
        .init(\.time, "time"),
        .init(\.uid, "uid"),
    ]

    public static let game: Pizza.SupportedGame = .genshinImpact

    public var count: Int = 1
    public var gachaType: Int = 301
    public var id: String = UUID().uuidString
    public var itemId: String = ""
    public var itemType: String = ""
    public var lang: String = ""
    public var name: String = ""
    public var rankType: Int = 3
    public var time: Date = .init(timeIntervalSince1970: 1)
    public var uid = "YJSNPI"
}

// MARK: - GachaMO4HSR

/// 穹披助手专用，不曝露。
struct GachaMO4HSR: ManagedObjectConvertible, GachaMOProtocol {
    public struct Relations {}

    public static let cloudContainerID: String = "iCloud.com.Canglong.HSRPizzaHelper"
    public static let containerName: String = "HSRPizzaHelper"
    public static let entityName: String = "GachaItemMO"
    public static let modelName: String = "GachaMO4HSR"
    public static let relations = Relations()
    public static let attributes: Set<Attribute<GachaMO4HSR>> = [
        .init(\.count, "count"),
        .init(\.gachaID, "gachaID"),
        .init(\.gachaTypeRawValue, "gachaTypeRawValue"),
        .init(\.id, "id"),
        .init(\.itemID, "itemID"),
        .init(\.itemTypeRawValue, "itemTypeRawValue"),
        .init(\.langRawValue, "langRawValue"),
        .init(\.name, "name"),
        .init(\.rankRawValue, "rankRawValue"),
        .init(\.time, "time"),
        .init(\.timeRawValue, "timeRawValue"),
        .init(\.uid, "uid"),
    ]

    public static let game: Pizza.SupportedGame = .starRail

    public var count: Int = 1
    public var gachaID: String = ""
    public var gachaTypeRawValue: String = ""
    public var id: String = UUID().uuidString
    public var itemID: String = ""
    public var itemTypeRawValue: String = ""
    public var langRawValue: String = ""
    public var name: String = ""
    public var rankRawValue: String = "3"
    public var time: Date = .init(timeIntervalSince1970: 1)
    public var timeRawValue: String? = "1"
    public var uid = "YJSNPI"
}
