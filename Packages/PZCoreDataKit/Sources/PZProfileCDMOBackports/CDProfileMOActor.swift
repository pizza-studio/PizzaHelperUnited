// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import PZCoreDataKitShared
@preconcurrency import Sworm

// MARK: - ProfileMOSputnik

/// 警告：请务必不要直接初始化这个 class。请使用 .shared。
public actor CDProfileMOActor {
    // MARK: Lifecycle

    public init(persistence: DBPersistenceMethod, backgroundContext: Bool) throws {
        let loadedPC = try PZProfileCDMO.getLoadedPersistentContainer(persistence: persistence)
        if backgroundContext {
            self.container = .init(managedObjectContext: loadedPC.newBackgroundContext)
        } else {
            self.container = .init { loadedPC.viewContext }
        }
    }

    // MARK: Public

    // swiftlint:disable:next force_try
    public static let shared = try! CDProfileMOActor(persistence: .cloud, backgroundContext: true)

    public private(set) var container: PersistentContainer
}
