// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import GachaKit
import PZCoreDataKit4GachaEntries
import PZCoreDataKit4LocalAccounts
import PZCoreDataKitShared
import SwiftUI

// MARK: - RefugeeVM4iOS14

@MainActor
public final class RefugeeVM4iOS14: TaskManagedVM4OS21 {
    // MARK: Lifecycle

    override private init() {
        super.init()
        configurePublisherObservations()
        startCountingDataEntriesTask(forced: true)
    }

    // MARK: Public

    public static let shared = RefugeeVM4iOS14()

    @Published public var currentExportableDocument: RefugeeDocument?
    @Published public var gachaEntriesCount: Int = 0
    @Published public var localProfileEntriesCount: Int = 0

    // MARK: Internal

    var isExportDialogVisible: Binding<Bool> {
        .init(get: {
            self.currentExportableDocument != nil
        }, set: { newValue in
            if !newValue {
                self.currentExportableDocument = nil
            }
        })
    }

    // MARK: Private

    private var subscribed: Bool = false

    private func configurePublisherObservations() {
        guard !subscribed else { return }
        defer { subscribed = true }
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSaveObjectIDs,
            object: nil,
            queue: nil // 不指定队列，依赖 actor 隔离
        ) { notification in // Singleton 不需要 weak self。
            let changedEntityNames = NSManagedObjectID.parseObjectNames(
                notificationResult: notification.userInfo
            )
            guard !changedEntityNames.isEmpty else { return }
            let hasAccountMO4GI = changedEntityNames.contains("AccountConfiguration")
            let hasOldGachaLog4GI = changedEntityNames.contains("GachaItemMO")
            guard hasAccountMO4GI || hasOldGachaLog4GI else { return }
            Task { @MainActor in
                self.startCountingDataEntriesTask(forced: false)
            }
        }
    }
}

extension RefugeeVM4iOS14 {
    public func startDocumentationPreparationTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: {
                var result = RefugeeFile()
                result.oldGachaEntries4GI = try await CDGachaMOActor.shared.getAllGenshinDataEntriesVanilla()
                result.oldProfiles4GI = try await CDAccountMOActor.shared.allAccountDataForGenshin()
                return result
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                withAnimation {
                    this.currentExportableDocument = .init(file: newResult)
                }
            }
        )
    }

    public func startCountingDataEntriesTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: {
                var (intGacha, intProfile) = (0, 0)
                intGacha = try await CDGachaMOActor.shared.countAllDataEntries(for: .genshinImpact)
                intProfile = try await CDAccountMOActor.shared.countAllAccountData(for: .genshinImpact)
                return (intGacha, intProfile)
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                let (intGacha, intProfile) = newResult
                withAnimation {
                    this.gachaEntriesCount = intGacha
                    this.localProfileEntriesCount = intProfile
                }
            }
        )
    }
}
