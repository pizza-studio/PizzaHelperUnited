// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts

// MARK: - PZProfileActorProtocol

public protocol PZProfileActorProtocol: Actor {
    func getSendableProfiles() -> [PZProfileSendable]
    func addOrUpdateProfilesWithDeletion(_ profileSendableSet: Set<PZProfileSendable>, uuidsToDelete: Set<UUID>) throws
    func addOrUpdateProfile(_ profileSendable: PZProfileSendable) throws
    func deleteProfile(uuid: UUID) throws
    @discardableResult
    func deleteProfiles(uuids: Set<UUID>) throws -> Set<PZProfileSendable>
    @discardableResult
    func bleachInvalidProfiles() throws -> Set<PZProfileSendable>
    @discardableResult
    func deduplicate() throws -> (
        removed: Set<PZProfileSendable>,
        left: Set<PZProfileSendable>
    )
    func propagateDeviceFingerprint(_ fingerprint: String) throws

    /// 以 UserDefaults 内的副本与各资料最近接受本地修改的时间戳为据，
    /// 裁决并丢弃过期的资料变动（例如 CloudKit 导入造成的回滚）。
    func arbitrateProfilesAgainstUserDefaults() async

    func acceptMigratedOldAccountProfiles(
        oldData: [PZProfileSendable],
        resetNotifications: Bool,
        isUnattended: Bool
    ) async throws
    #if os(watchOS)
    func watchSessionHandleIncomingPushedProfiles(_ receivedProfileMap: [String: PZProfileSendable])
    #endif
}

extension PZProfileActorProtocol {
    /// 预设无操作；目前仅 SwiftData 栈（PZProfileActor）实作。
    public func arbitrateProfilesAgainstUserDefaults() async {}

    public func replaceProfilesMatchingUUID(
        with profileSendableSet: Set<PZProfileSendable>
    ) throws {
        try addOrUpdateProfilesWithDeletion(
            profileSendableSet,
            uuidsToDelete: Set(profileSendableSet.map(\.uuid))
        )
    }

    public func addOrUpdateProfiles(_ profileSendableSet: Set<PZProfileSendable>) throws {
        try addOrUpdateProfilesWithDeletion(profileSendableSet, uuidsToDelete: [])
    }

    @discardableResult
    public func syncAllDataToUserDefaults() -> [PZProfileSendable] {
        let profiles = getSendableProfiles()
        var newMap = Defaults[.pzProfiles]
        let profileUUIDs = Set(profiles.map(\.uuid.uuidString))
        // Remove obsolete keys no longer in the fetched profiles.
        newMap.keys.forEach { key in
            if !profileUUIDs.contains(key) {
                newMap.removeValue(forKey: key)
            }
        }
        // Batch-update all profiles.
        profiles.forEach {
            newMap[$0.uuid.uuidString] = $0
        }
        // Single atomic write: Defaults.updates observer fires once with complete data.
        Defaults[.pzProfiles] = newMap
        UserDefaults.profileSuite.synchronize()
        return profiles
    }

    public func migrateOldAccountsIntoProfiles(
        resetNotifications: Bool = true,
        isUnattended: Bool = false
    ) async throws {
        do {
            let oldData = try await CDAccountMOActor.shared?.getAllAccountDataAsPZProfileSendable() ?? []
            guard !oldData.isEmpty else { return }
            try await acceptMigratedOldAccountProfiles(
                oldData: oldData,
                resetNotifications: resetNotifications,
                isUnattended: isUnattended
            )
        } catch {
            return
        }
    }

    /// An OOBE task attempts inheriting old AccountMOs from the previous Pizza Apps using obsolete engines.
    /// - Parameter resetNotifications: Recheck permissions for notifications && reload all timelines across widgets.
    public func tryAutoInheritOldLocalAccounts(resetNotifications: Bool = true) async {
        guard !Pizza.isAppStoreReleaseAsLatteHelper else { return }
        guard Pizza.isAppStoreRelease, !Defaults[.oldAccountMOAlreadyAutoInherited] else { return }
        do {
            try await migrateOldAccountsIntoProfiles(
                resetNotifications: resetNotifications,
                isUnattended: true
            )
        } catch {
            return
        }
        Defaults[.oldAccountMOAlreadyAutoInherited] = true
    }

    public func fixPriorityForExistingProfiles() async throws {
        var existingProfiles = getSendableProfiles()
        existingProfiles.fixPrioritySettings(respectExistingPriority: true)
        try addOrUpdateProfiles(Set(existingProfiles))
    }
}
