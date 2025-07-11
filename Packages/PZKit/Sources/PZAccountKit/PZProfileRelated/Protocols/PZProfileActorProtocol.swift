// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import PZCoreDataKit4LocalAccounts

// MARK: - PZProfileActorProtocol

public protocol PZProfileActorProtocol: Actor {
    func getSendableProfiles() -> [PZProfileSendable]
    func addOrUpdateProfiles(_ profileSendableSet: Set<PZProfileSendable>) throws
    func addOrUpdateProfile(_ profileSendable: PZProfileSendable) throws
    func replaceAllProfiles(with profileSendableSet: Set<PZProfileSendable>) throws
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
    @discardableResult
    public func syncAllDataToUserDefaults() -> [PZProfileSendable] {
        var existingKeys = Set<String>(Defaults[.pzProfiles].keys)
        let profiles = getSendableProfiles()
        profiles.forEach {
            Defaults[.pzProfiles][$0.uuid.uuidString] = $0
            existingKeys.remove($0.uuid.uuidString)
        }
        existingKeys.forEach { Defaults[.pzProfiles].removeValue(forKey: $0) }
        UserDefaults.profileSuite.synchronize()
        return profiles
    }

    public func migrateOldAccountsIntoProfiles(
        resetNotifications: Bool = true,
        isUnattended: Bool = false
    ) async throws {
        do {
            let oldData = try await CDAccountMOActor.shared.getAllAccountDataAsPZProfileSendable()
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
}
