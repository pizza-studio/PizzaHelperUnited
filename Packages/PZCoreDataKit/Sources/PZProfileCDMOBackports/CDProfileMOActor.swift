// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import Defaults
import PZCoreDataKitShared
@preconcurrency import Sworm

// MARK: - ProfileMOSputnik

/// 警告：请务必不要直接初始化这个 class。请使用 .shared。
public actor CDProfileMOActor {
    // MARK: Lifecycle

    /// ProfileMOActor 的 CoreData 版本。
    /// - Parameters:
    ///   - persistence: 持久化方法。
    ///   - backgroundContext: 请仅填写 true，除非你知道填写了会发生什么。
    ///   只有在 MainActor 上才可以填写 false，但自己弄的 ModelActor 必定不会越俎代 MainActor 的庖。
    public init(
        persistence: DBPersistenceMethod,
        backgroundContext: Bool,
        useGroupContainer: Bool
    ) throws {
        let containerURL = PZProfileCDMO.primarySQLiteDBURL(useGroupContainer: useGroupContainer)
        guard let containerURL else {
            throw NSError(
                domain: "CDProfileMOActor.init",
                code: 889464,
                userInfo: [NSLocalizedDescriptionKey: "Container URL is null."]
            )
        }
        let loadedPC = try PZProfileCDMO.getLoadedPersistentContainer(
            persistence: persistence, useGroupContainer: useGroupContainer
        )
        if backgroundContext {
            self.container = .init(managedObjectContext: loadedPC.newBackgroundContext)
        } else {
            self.container = .init { loadedPC.viewContext }
        }
        self.databaseFileURL = containerURL
        self.isInGroupContainer = useGroupContainer
    }

    // MARK: Public

    public private(set) var container: PersistentContainer
    public let databaseFileURL: URL
    public let isInGroupContainer: Bool
}
