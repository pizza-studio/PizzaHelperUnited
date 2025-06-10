// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Foundation
import PZBaseKit
@preconcurrency import Sworm

// MARK: - ProfileBasicProtocol

/// AccountMO 不是统一披萨助手引擎用来主要处理的格式，
/// 而是专门为了从 CloudKit 读取既有资料而实作的资料交换格式。
/// 这也是为了方便直接继承旧版原披助手与穹披助手的云端资料。
/// AccountMO 不曝露给前端使用，不直接用于 SwiftUI。

public protocol ProfileBasicProtocol: Codable {
    var allowNotification: Bool { get }
    var cookie: String { get }
    var deviceFingerPrint: String { get }
    var name: String { get }
    var priority: Int { get }
    var serverRawValue: String { get }
    var sTokenV2: String? { get }
    var uid: String { get }
    var uuid: UUID { get }
}

// MARK: - ProfileMOBasicProtocol

public protocol ProfileMOBasicProtocol: Codable, ProfileBasicProtocol {
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

extension ProfileBasicProtocol {
    public var isValid: Bool {
        true
            && isUIDValid
            && !name.isEmpty
    }

    public var isOfflineProfile: Bool {
        cookie.isEmpty
    }

    public var isInvalid: Bool { !isValid }

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(uid) else { return false }
        /// 绝区零的国服 UID 是八位。
        #if os(watchOS)
        return (100_000_00 ... Int(Int32.max)).contains(givenUIDInt)
        #else
        return (100_000_00 ... 9_999_999_999).contains(givenUIDInt)
        #endif
    }
}

// MARK: - ProfileMOProtocol

public protocol ProfileMOProtocol: ProfileProtocol, ProfileMOBasicProtocol {
    var game: Pizza.SupportedGame { get set }
    var deviceID: String { get set }
    var server: HoYo.Server { get set }
}

// MARK: - ProfileProtocol

public protocol ProfileProtocol: ProfileBasicProtocol, Identifiable {
    var game: Pizza.SupportedGame { get }
    var deviceID: String { get }
    var server: HoYo.Server { get }
}

extension ProfileProtocol {
    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}

extension ProfileMOProtocol {
    public mutating func inherit(from target: some ProfileMOProtocol) {
        uid = target.uid
        uuid = target.uuid
        allowNotification = target.allowNotification
        cookie = target.cookie
        deviceFingerPrint = target.deviceFingerPrint
        name = target.name
        priority = target.priority
        serverRawValue = target.serverRawValue
        sTokenV2 = target.sTokenV2
        deviceID = target.deviceID
        game = target.game
        server = target.server
    }
}

// MARK: - AccountMOProtocol

public protocol AccountMOProtocol: Codable, ProfileMOBasicProtocol {
    static var entityName: String { get }
    static var modelName: String { get }
    static var containerName: String { get }
    static var cloudContainerID: String { get }
    static var game: Pizza.SupportedGame { get }
    static var alternativeSQLiteDBURL: URL? { get }
}

extension AccountMOProtocol {
    public var entityName: String { Self.entityName }
    public var modelName: String { Self.modelName }
    public var containerName: String { Self.containerName }
    public var game: Pizza.SupportedGame { Self.game }
    public var cloudContainerID: String { Self.cloudContainerID }

    public static var primarySQLiteDBURL: URL? {
        let containerURL = Pizza.isAppStoreRelease
            ? groupContainerURL
            : FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        guard let containerURL else { return nil }
        let prefix = Pizza.isAppStoreRelease ? "" : "\(sharedBundleIDHeader)/"
        return containerURL.appendingPathComponent("\(prefix + modelName).sqlite")
    }

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
        checkIfNotInRAM: if persistence != .inMemory {
            let storeURL = alternativeSQLiteDBURL ?? primarySQLiteDBURL
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

// MARK: - AccountMO4GI

/// 原披助手专用。
struct AccountMO4GI: ManagedObjectConvertible, AccountMOProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public struct Relations {}

    public static let cloudContainerID: String = "iCloud.com.Canglong.GenshinPizzaHepler" // 没机会纠正了。
    public static let containerName: String = "AccountConfiguration"
    public static let entityName: String = "AccountConfiguration"
    public static let modelName: String = "AccountMO4GI"
    public static let relations = Relations()
    public static let attributes: Set<Attribute<AccountMO4GI>> = [
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
    public static let alternativeSQLiteDBURL: URL? = {
        // 下述命令等价于判断「appGroupID == "group.GenshinPizzaHelper"」。
        guard Pizza.isAppStoreRelease else { return URL?.none }
        guard let containerURL = groupContainerURL else { return URL?.none }
        let storeURL = containerURL.appendingPathComponent("AccountConfiguration.splite")
        let exists = FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: false))
        return exists ? storeURL : URL?.none
    }()

    public var name: String = ""
    public var priority: Int = 0
    public var serverRawValue: String = ""
    public var sTokenV2: String? = ""
    public var uid: String = "YJSNPI"
    public var uuid: UUID = .init()
    public var cookie: String = ""
    public var deviceFingerPrint: String = ""

    public var allowNotification: Bool { get { false } set { _ = newValue } }
}

// MARK: - AccountMO4HSR

/// 穹披助手专用，不曝露。
struct AccountMO4HSR: ManagedObjectConvertible, AccountMOProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public struct Relations {}

    public static let cloudContainerID: String = "iCloud.com.Canglong.HSRPizzaHelper"
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

    /// 安全起见，穹披助手的资料只能云继承，因为穹披助手将两个 CoreDataMO 写到一个 Container 里面了。这样处理起来非常棘手。
    /// 新披萨助手只是原神披萨助手的原位升级、与穹披助手仍旧彼此独立，这里弄本地继承的话反而可能会破坏穹披助手的本地资料。
    public static let alternativeSQLiteDBURL: URL? = nil

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
