// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import GachaKit
import PZAccountKit
import PZBaseKit
import PZCoreDataKit4GachaEntries
import PZCoreDataKit4LocalAccounts
import SwiftData
import SwiftUI

// MARK: - RefugeeVM4iOS14

@MainActor
public final class RefugeeVM4iOS14: TaskManagedVMBackported {
    // MARK: Lifecycle

    override private init() {
        super.init()
        configurePublisherObservations()
        startCountingDataEntriesTask(forced: true)
    }

    // MARK: Public

    public static let shared = RefugeeVM4iOS14()

    @Published public var currentExportableDocument: PZRefugeeDocument?
    @Published public var gachaEntriesCount: Int = 0
    @Published public var gachaEntriesCountModern: Int = 0
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

    private static var isOS23OrNewer: Bool {
        if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) { return true }
        return false
    }

    private let debouncer: Debouncer = .init(delay: 0.5)

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
            let hasPZProfileMO = changedEntityNames.contains("PZProfileMO")
            guard hasAccountMO4GI || hasOldGachaLog4GI || hasPZProfileMO else { return }
            Task { @MainActor in
                await self.debouncer.debounce {
                    await MainActor.run {
                        self.startCountingDataEntriesTask(forced: false)
                    }
                }
            }
        }
    }
}

extension RefugeeVM4iOS14 {
    public func startDocumentationPreparationTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: {
                var result = PZRefugeeFile()
                result.oldGachaEntries4GI = try await CDGachaMOActor.shared?.getAllGenshinDataEntriesVanilla() ?? []
                if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) {
                    result.newProfiles = ProfileManagerVM.shared.profiles
                } else {
                    result.oldProfiles4GI = try await CDAccountMOActor.shared?.allAccountDataForGenshin() ?? []
                }
                if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                    result.newGachaEntries = try await GachaActor.shared.fetchSendableEntries(
                        .init()
                    )
                }
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
                var (intGacha, intGachaModern, intProfile) = (0, 0, 0)
                intGacha = try await CDGachaMOActor.shared?.countAllDataEntries(for: .genshinImpact) ?? 0
                if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) {
                    intProfile = ProfileManagerVM.shared.profiles.count
                } else {
                    intProfile = try await CDAccountMOActor.shared?.countAllAccountData(for: .genshinImpact) ?? 0
                }
                if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                    intGachaModern = try await GachaActor.shared.countAllDataEntries(.init())
                }
                return (intGacha, intGachaModern, intProfile)
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                let (intGacha, intGachaModern, intProfile) = newResult
                withAnimation {
                    this.gachaEntriesCount = intGacha
                    this.gachaEntriesCountModern = intGachaModern
                    this.localProfileEntriesCount = intProfile
                }
            }
        )
    }
}
