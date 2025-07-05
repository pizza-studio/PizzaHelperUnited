// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HYQueriedModels

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public enum HYQueriedModels {}

// MARK: - DecodableHYLAvatarListProtocol

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public protocol DecodableHYLAvatarListProtocol: AbleToCodeSendHash & DecodableFromMiHoYoAPIJSONResult {
    associatedtype Content = HYQueriedAvatarProtocol
    var avatarList: [Content] { get }
}

// MARK: - HYQueriedAvatarProtocol

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public protocol HYQueriedAvatarProtocol: Identifiable, Equatable, AbleToCodeSendHash {
    associatedtype DBType: EnkaDBProtocol where DBType.HYLAvatarDetailType == Self
    associatedtype DecodableList: DecodableHYLAvatarListProtocol where DecodableList.Content == Self
    typealias List = [Self]
    var avatarIdStr: String { get }
    var id: Int { get }
    @MainActor
    func summarize(theDB: DBType) -> Enka.AvatarSummarized?
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HYQueriedAvatarProtocol {
    public static func cacheLocalHoYoAvatars(uid: String, data: Data) {
        let decoded = try? Self.DecodableList.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "HYQueriedModels.cacheLocalHoYoAvatars()"
        )
        guard decoded != nil else { return }
        do {
            try data.write(to: getURL4LocallyCachedAvatars(uid: uid), options: .atomic)
            Task { @MainActor in
                Broadcaster.shared.localHoYoLABAvatarCacheDidUpdate()
            }
        } catch {
            return
        }
    }

    public static func getLocalAvatarRaws(uid: String) -> List {
        let cachedRawData = try? Data(contentsOf: getURL4LocallyCachedAvatars(uid: uid))
        guard let cachedRawData else { return [] }
        let decoded = try? Self.DecodableList.decodeFromMiHoYoAPIJSONResult(
            data: cachedRawData,
            debugTag: "HYQueriedModels.getLocalAvatarRaws()"
        )
        guard let decoded else { return [] }
        return decoded.avatarList
    }

    @MainActor
    public static func getLocalHoYoAvatars(theDB: DBType, uid: String) -> [Enka.AvatarSummarized] {
        let raw = getLocalAvatarRaws(uid: uid)
        return raw.compactMap { $0.summarize(theDB: theDB) }
    }

    /// We assume that this API never fails.
    private static var localAvatarCacheFolderURL: URL {
        let backgroundFolderUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
            .appendingPathComponent("CachedAvatars", isDirectory: true)
            .appendingPathComponent("FromHoYoLAB", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: backgroundFolderUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderUrl
    }

    private static func getFileNameStem4LocallyCachedAvatars(uid: String) -> String {
        "\(DBType.game.uidPrefix)-\(uid)-HoYoLABQueryResult"
    }

    private static func getURL4LocallyCachedAvatars(uid: String) -> URL {
        localAvatarCacheFolderURL.appendingPathComponent(
            getFileNameStem4LocallyCachedAvatars(uid: uid) + ".json", isDirectory: false
        )
    }
}
