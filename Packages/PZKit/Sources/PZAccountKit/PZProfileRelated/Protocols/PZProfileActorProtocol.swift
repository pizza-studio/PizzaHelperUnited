// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

public protocol PZProfileActorProtocol: Actor {
    static var shared: Self { get }

    func getSendableProfiles() -> [PZProfileSendable]
    func addProfiles(_ profileSendableSet: Set<PZProfileSendable>) throws
    func updateProfile(_ profileSendable: PZProfileSendable) throws
    func replaceAllProfiles(with profileSendableSet: Set<PZProfileSendable>) throws
    func deleteProfile(uuid: UUID) throws
    func deleteProfiles(uuids: Set<UUID>) throws -> Set<PZProfileSendable>
    func bleachInvalidProfiles() throws -> Set<PZProfileSendable>
    func syncAllDataToUserDefaults() -> [PZProfileSendable]
    func deduplicate() throws -> (
        removed: Set<PZProfileSendable>,
        left: Set<PZProfileSendable>
    )
    func propagateDeviceFingerprint(_ fingerprint: String) throws
    func migrateOldAccountsIntoProfiles(
        resetNotifications: Bool,
        isUnattended: Bool
    ) async throws
    func tryAutoInheritOldLocalAccounts(
        resetNotifications: Bool
    ) async
}
