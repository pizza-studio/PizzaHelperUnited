// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import CoreData
import Defaults
import Foundation
import PZBaseKit
import SwiftData

@Observable
public final class ProfileManagerVM: TaskManagedVM {
    // MARK: Lifecycle

    public override init() {
        let defaultsMap = Defaults[.pzProfiles]
        var profiles = defaultsMap.values.sorted { $0.priority < $1.priority }
        profiles.fixPrioritySettings()
        self.profiles = profiles
        var newMOMap = [String: PZProfileMO]()
        profiles.forEach { profileSendable in
            newMOMap[profileSendable.uuid.uuidString] = profileSendable.asMO
        }
        self.profileMOs = newMOMap
        super.init()
        configurePublisherObservations()
        Task { @MainActor in
            let count = try? AccountMOSputnik.shared.countAllAccountDataAsPZProfileMO()
            self.hasOldAccountDataDetected = (count ?? 0) > 0
        }
        Task {
            for await newProfileMap in Defaults.updates(.pzProfiles) {
                self.profiles = newProfileMap.values.sorted {
                    $0.priority < $1.priority
                }
            }
        }
    }

    // MARK: Public

    public enum SheetType: Identifiable, Hashable {
        case createNewProfile(PZProfileMO)
        case editExistingProfile(PZProfileMO)

        // MARK: Public

        public var id: UUID {
            switch self {
            case let .createNewProfile(profile): profile.uuid
            case let .editExistingProfile(profile): profile.uuid
            }
        }
    }

    public static let shared = ProfileManagerVM()

    public internal(set) var hasOldAccountDataDetected: Bool = false

    /// 此处沿用 PZProfileMO 作为指针格式，但不用于对 SwiftData 的写入。
    public internal(set) var profileMOs: [String: PZProfileMO]

    public var sheetType: SheetType?

    // 当前的所有 Profile 列表
    public internal(set) var profiles: [PZProfileSendable] {
        didSet {
            discardUncommittedChanges()
        }
    }

    public var hasUncommittedChanges: Bool {
        Set(profileMOs.map(\.value.asSendable)).hashValue != Set(profiles).hashValue
    }

    public func discardUncommittedChanges() {
        // 这里的实作可能有些机车，但这是为了确保所有被还原的对象的指针一致。
        guard hasUncommittedChanges else { return }
        var newResult = [String: PZProfileMO]()
        Defaults[.pzProfiles].forEach { uuidStr, profileSendable in
            newResult[uuidStr] = profileSendable.asMO
        }
        profileMOs = newResult
    }

    public func moveItems(
        from source: IndexSet,
        to destination: Int,
        errorHandler: ((any Error) -> Void)? = nil
    ) {
        var newProfiles = profiles
        newProfiles.move(fromOffsets: source, toOffset: destination)
        newProfiles.fixPrioritySettings()
        newProfiles.forEach {
            let uuidStr = $0.uuid.uuidString
            if let mo = profileMOs[uuidStr] {
                mo.priority = $0.priority
            }
        }
        fireTask(
            animatedPreparationTask: {
                self.profiles = newProfiles
            },
            cancelPreviousTask: false,
            givenTask: {
                try await PZProfileActor.shared.replaceAllProfiles(with: Set(newProfiles))
            },
            errorHandler: errorHandler
        )
    }

    public func updateProfile(
        _ profile: PZProfileSendable,
        trailingTasks: (() -> Void)? = nil,
        errorHandler: ((any Error) -> Void)? = nil
    ) {
        profileMOs.values.filter { $0.uuid == profile.uuid }.forEach {
            $0.inherit(from: profile)
        }
        profiles.indices.forEach { index in
            if profiles[index].uuid == profile.uuid {
                profiles[index].inherit(from: profile)
            }
        }
        fireTask(
            cancelPreviousTask: false,
            givenTask: {
                try await PZProfileActor.shared.updateProfile(profile)
            },
            completionHandler: { _ in
                trailingTasks?()
            },
            errorHandler: errorHandler
        )
    }

    public func deleteProfiles(
        uuids uuidsToDrop: Set<UUID>,
        completionHandler: ((Set<PZProfileSendable>?) -> Void)? = nil,
        errorHandler: ((any Error) -> Void)? = nil
    ) {
        guard !profiles.isEmpty, !profileMOs.isEmpty else { return }
        // 这里提前先修改 VM 内部的参数。
        // 虽然最后会被自动再重复落实一次，但不事先落实 VM 的修改的话就会造成前台 SwiftUI 视觉效果割裂。
        var profileMOsModified = profileMOs
        let profilesModified = profiles.filter {
            profileMOsModified.removeValue(forKey: $0.uuid.uuidString)
            return !uuidsToDrop.contains($0.uuid)
        }
        fireTask(
            animatedPreparationTask: {
                self.profileMOs = profileMOsModified
                self.profiles = profilesModified
            },
            cancelPreviousTask: false,
            givenTask: {
                try await PZProfileActor.shared.deleteProfiles(uuids: uuidsToDrop)
            },
            completionHandler: { fetched in
                completionHandler?(fetched)
            },
            errorHandler: errorHandler
        )
    }

    public func replaceAllProfiles(
        with profileSendableSet: Set<PZProfileSendable>? = nil,
        trailingTasks: (() -> Void)? = nil,
        errorHandler: ((any Error) -> Void)? = nil
    ) {
        fireTask(
            cancelPreviousTask: false,
            givenTask: {
                let profileSendableSet = profileSendableSet ?? Set(self.profiles)
                try await PZProfileActor.shared.replaceAllProfiles(with: profileSendableSet)
                return await PZProfileActor.shared.getSendableProfiles()
            },
            completionHandler: { _ in
                trailingTasks?()
            },
            errorHandler: errorHandler
        )
    }

    // MARK: Private

    @ObservationIgnored private var cancellables: [AnyCancellable] = []

    private func configurePublisherObservations() {
        switch OS.isOS25OrAbove {
        case false:
            // OS24 (iOS 17, macOS 14) 无法时刻抓到 ModelContext.didSave，
            // 所以只能抓 NSManagedObjectContextDidSaveObjectIDs。但这样又会有紫色警告。
            // 算了不管了，忍到 2026 年夏天放弃 iOS 17。
            NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
                .sink(receiveValue: { _ in
                    self.didObserveChangesFromSwiftData()
                })
                .store(in: &cancellables)
        case true:
            NotificationCenter.default.publisher(for: ModelContext.didSave)
                .sink(receiveValue: { notification in
                    let changedEntityNames = PersistentIdentifier.parseObjectNames(
                        notificationResult: notification.userInfo
                    )
                    guard !changedEntityNames.isEmpty else { return }
                    guard changedEntityNames.contains("PZProfileMO") else { return }
                    self.didObserveChangesFromSwiftData()
                })
                .store(in: &cancellables)
        }
    }

    nonisolated private func didObserveChangesFromSwiftData() {
        Task { @MainActor in
            if Defaults[.automaticallyDeduplicatePZProfiles] {
                try await PZProfileActor.shared.deduplicate()
            }
            await PZProfileActor.shared.syncAllDataToUserDefaults()
            ProfileManagerVM.shared.profiles = Defaults[.pzProfiles].values.sorted {
                $0.priority < $1.priority
            }
            Broadcaster.shared.refreshTodayTab()
            Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
            Broadcaster.shared.requireOSNotificationCenterAuthorization()
        }
    }
}
