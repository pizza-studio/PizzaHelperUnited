// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

// MARK: - EKQueryResultProtocol

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol EKQueryResultProtocol: Codable, Hashable, Sendable, Equatable, Sendable {
    associatedtype DBType: EnkaDBProtocol where DBType.QueriedResult == Self
    typealias QueriedProfileType = DBType.QueriedProfile
    var detailInfo: DBType.QueriedProfile? { get set }
    var uid: String? { get set }
    var message: String? { get }
    static var game: Enka.GameType { get }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension EKQueryResultProtocol {
    public static func queryRAW(
        uid: String,
        dateWhenNextRefreshable nextAvailableDate: Date? = nil
    ) async throws
        -> Self {
        try await Enka.Sputnik.fetchEnkaQueryResultRAW(
            uid,
            type: Self.self,
            dateWhenNextRefreshable: nextAvailableDate
        ).result
    }

    public static func queryProfile(
        uid: String,
        dateWhenNextRefreshable nextAvailableDate: Date? = nil
    ) async throws
        -> Self.QueriedProfileType {
        try await Enka.Sputnik.fetchEnkaQueryResultRAW(
            uid,
            type: Self.self,
            dateWhenNextRefreshable: nextAvailableDate
        ).profile
    }
}

// MARK: - EKQueriedProfileProtocol

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol EKQueriedProfileProtocol: Codable, Hashable, Sendable, Equatable, Sendable {
    associatedtype DBType: EnkaDBProtocol where DBType.QueriedProfile == Self
    associatedtype QueriedAvatar: EKQueriedRawAvatarProtocol where QueriedAvatar.DBType == DBType
    var avatarDetailList: [QueriedAvatar] { get set }
    var uid: String { get set }
    var nickname: String { get }
    var signature: String { get }
    var level: Int { get }
    var worldLevel: Int { get }
    var headIcon: Int { get }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension EKQueriedProfileProtocol {
    /// 仅制作这个新 API 将旧资料融入新资料，因为反向融合没有任何意义。
    public func inheritAvatars(from oldInfo: Self?) -> Self {
        var newResult = self
        oldInfo?.avatarDetailList.forEach { oldAvatar in
            let ids = avatarDetailList.map(\.avatarId)
            guard !ids.contains(oldAvatar.avatarId) else { return }
            newResult.avatarDetailList.append(oldAvatar)
        }
        return newResult
    }

    public var onlineAssetURLStr: String {
        switch DBType.game {
        case .genshinImpact:
            let matched = Enka.Sputnik.shared.db4GI.profilePictures[headIcon.description]?.iconPath
            return "https://enka.network/ui/\(matched ?? "YJSNPI").png"
        case .starRail:
            let str = Enka.Sputnik.shared.db4HSR.profileAvatars[headIcon.description]?
                .icon.split(separator: "/").suffix(2).joined(separator: "/").description ?? "Anonymous.png"
            return "https://enka.network/ui/hsr/SpriteOutput/AvatarRoundIcon/\(str)"
        case .zenlessZone: return "114514" // 临时设定。
        }
    }

    public var iconAssetName: String {
        var headIconID = headIcon.description
        switch DBType.game {
        case .genshinImpact: break
        case .starRail:
            let str = Enka.Sputnik.shared.db4HSR.profileAvatars[headIcon.description]?
                .icon.split(separator: "/").last?.description ?? "Anonymous.png"
            headIconID = str.replacingOccurrences(of: ".png", with: "")
        case .zenlessZone: break // 临时设定。
        }
        return "\(DBType.game.localAssetNamePrefix)avatar_\(headIconID)"
    }

    public static var nullPhotoAssetName: String {
        AnonymousIconView.nullPhotoAssetName
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension EKQueriedProfileProtocol {
    public func saveToCache() {
        let encodedData = try? JSONEncoder().encode(self)
        guard let encodedData else { return }
        do {
            try encodedData.write(
                to: Self.getURL4LocallyCachedQueryProfile(uid: uid),
                options: .atomic
            )
            Task { @MainActor in
                Broadcaster.shared.localEnkaAvatarCacheDidUpdate(
                    uidWithGame: Self.getUIDWithGame(uid: uid)
                )
            }
        } catch {
            return
        }
    }

    public static func getCachedProfile(uid: String) -> Self? {
        let cachedRawData = try? Data(contentsOf: getURL4LocallyCachedQueryProfile(uid: uid))
        guard let cachedRawData else { return nil }
        return try? cachedRawData.parseAs(Self.self)
    }

    public static func removeCachedProfile(uid: String, broadcastChanges: Bool = true) {
        let fileURL = getURL4LocallyCachedQueryProfile(uid: uid)
        do {
            try FileManager.default.removeItem(at: fileURL)
            if broadcastChanges {
                Task { @MainActor in
                    Broadcaster.shared.localEnkaAvatarCacheDidUpdate(
                        uidWithGame: Self.getUIDWithGame(uid: uid)
                    )
                }
            }
        } catch {
            print(error)
            print("[FAILURE] Unable to remove cached Enka profile at: \(fileURL)")
        }
    }

    public static func getAllCachedProfiles() -> [String: Self] {
        var result = [String: Self]()
        let resourceKeys = [URLResourceKey]([.nameKey, .isRegularFileKey])
        let directoryEnumerator = FileManager.default.enumerator(
            at: localAvatarCacheFolderURL,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants]
        )
        guard let directoryEnumerator else { return result }
        for case let fileURL as URL in directoryEnumerator {
            let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys))
            guard let isFile = resourceValues?.isRegularFile, isFile else { continue }
            guard let fileName = resourceValues?.name else { continue }
            // Parse filename (Game).
            let maybeMatchedGame = Pizza.SupportedGame(
                uidPrefix: fileName.prefix(2).description
            )
            guard maybeMatchedGame == DBType.game else { continue }
            // Parse filename (UID).
            let fileNameStem = fileName.split(separator: ".").prefix(1).joined()
            let uidStr = fileNameStem.split(separator: "-").dropFirst(1).prefix(1).joined()
            guard !uidStr.isEmpty, Int(uidStr) != nil else { continue }
            // Read file into the map.
            guard let profile = getCachedProfile(uid: uidStr) else { continue }
            result[uidStr] = profile
        }
        return result
    }

    /// We assume that this API never fails.
    private static var localAvatarCacheFolderURL: URL {
        let backgroundFolderUrl = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
            .appendingPathComponent("CachedAvatars", isDirectory: true)
            .appendingPathComponent("FromEnkaNetworks", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: backgroundFolderUrl,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderUrl
    }

    private static func getUIDWithGame(uid: String) -> String {
        "\(DBType.game.uidPrefix)-\(uid)"
    }

    private static func getFileNameStem4LocallyCachedQueryProfile(uid: String) -> String {
        "\(getUIDWithGame(uid: uid))-EnkaQueryProfile"
    }

    private static func getURL4LocallyCachedQueryProfile(uid: String) -> URL {
        localAvatarCacheFolderURL.appendingPathComponent(
            getFileNameStem4LocallyCachedQueryProfile(uid: uid) + ".json", isDirectory: false
        )
    }
}

// MARK: - EKQueriedRawAvatarProtocol

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol EKQueriedRawAvatarProtocol: Identifiable, Hashable, Equatable, Sendable {
    associatedtype DBType: EnkaDBProtocol where DBType.QueriedProfile.QueriedAvatar == Self
    var avatarId: Int { get }
    var id: String { get }
    @MainActor
    func summarize(theDB: DBType) -> Enka.AvatarSummarized?
}
