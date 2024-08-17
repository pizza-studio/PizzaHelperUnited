// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import Foundation
import PZBaseKit
import Sworm

// MARK: - ProfileMOProtocol

/// AccountMO 不是统一披萨助手引擎用来主要处理的格式，而是专门针对 CloudKit 做的资料交换格式。
/// 这也是为了方便直接继承旧版原披助手与穹披助手的云端资料。
/// AccountMO 不曝露给前端使用，不直接用于 SwiftUI。

public protocol ProfileMOProtocol: Codable {
    var allowNotification: Bool { get set }
    var cookie: String { get set }
    var deviceFingerPrint: String { get set }
    var name: String { get set }
    var priority: Int { get set }
    var serverRawValue: String { get set }
    var sTokenV2: String? { get set }
    var uid: String { get set }
    var uuid: UUID { get set }
}

extension ProfileMOProtocol {
    public var isValid: Bool {
        true
            && Int(uid) != nil
            && [8, 9].contains(uid.count)
            && !name.isEmpty
    }

    public var isOfflineProfile: Bool {
        cookie.isEmpty
    }

    public var isInvalid: Bool { !isValid }
}

// MARK: - AccountMOProtocol

public protocol AccountMOProtocol: Codable, ProfileMOProtocol {
    static var entityName: String { get }
    static var modelName: String { get }
    static var containerName: String { get }
    static var cloudContainerID: String { get }
    static var game: Pizza.SupportedGame { get }
}

extension AccountMOProtocol {
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

// MARK: - AccountMO4GI

/// 原披助手专用。
struct AccountMO4GI: ManagedObjectConvertible, AccountMOProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public struct Relations {}

    public static var cloudContainerID: String = "iCloud.com.Canglong.GenshinPizzaHepler" // 没机会纠正了。
    public static let containerName: String = "AccountConfiguration"
    public static let entityName: String = "AccountConfiguration"
    public static let modelName: String = "AccountMO4GI"
    public static let relations = Relations()
    public static let attributes: Set<Attribute<AccountMO4GI>> = [
        .init(\.allowNotification, "allowNotification"),
        .init(\.cookie, "cookie"),
        .init(\.deviceFingerPrint, "deviceFingerPrint"),
        .init(\.name, "name"),
        .init(\.priority, "priority"),
        .init(\.serverRawValue, "serverRawValue"),
        .init(\.sTokenV2, "sTokenV2"),
        .init(\.uid, "uid"),
        .init(\.uuid, "uuid"),
    ]

    public static let game: Pizza.SupportedGame = .genshinImpact

    public var name: String = ""
    public var priority: Int = 0
    public var serverRawValue: String = ""
    public var sTokenV2: String? = ""
    public var uid: String = "YJSNPI"
    public var uuid: UUID = .init()
    public var allowNotification: Bool = false
    public var cookie: String = ""
    public var deviceFingerPrint: String = ""
}

// MARK: - AccountMO4HSR

/// 穹披助手专用，不曝露。
struct AccountMO4HSR: ManagedObjectConvertible, AccountMOProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public struct Relations {}

    public static var cloudContainerID: String = "iCloud.com.Canglong.HSRPizzaHelper"
    public static let containerName: String = "HSRPizzaHelper"
    public static let entityName: String = "Account"
    public static let modelName: String = "AccountMO4HSR"
    public static let relations = Relations()
    public static let attributes: Set<Attribute<AccountMO4HSR>> = [
        .init(\.allowNotification, "allowNotification"),
        .init(\.cookie, "cookie"),
        .init(\.deviceFingerPrintInner, "deviceFingerPrintInner"),
        .init(\.name, "name"),
        .init(\.priority, "priority"),
        .init(\.serverRawValue, "serverRawValue"),
        .init(\.sTokenV2, "sTokenV2"),
        .init(\.uid, "uid"),
        .init(\.uuid, "uuid"),
    ]

    public static let game: Pizza.SupportedGame = .starRail

    public var name: String = ""
    public var priority: Int = 0
    public var serverRawValue: String = ""
    public var sTokenV2: String? = ""
    public var uid: String = "YJSNPI"
    public var uuid: UUID = .init()
    public var allowNotification: Bool = false
    public var cookie: String = ""

    public var deviceFingerPrint: String {
        get { deviceFingerPrintInner ?? "" }
        set { deviceFingerPrintInner = newValue }
    }

    // MARK: Private

    private var deviceFingerPrintInner: String? = ""
}
