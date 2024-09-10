// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults

// MARK: - EKQueryResultProtocol

public protocol EKQueryResultProtocol: Decodable, Hashable, Equatable {
    associatedtype DBType: EnkaDBProtocol where DBType.QueriedResult == Self
    var detailInfo: DBType.QueriedProfile? { get set }
    var uid: String? { get set }
    var message: String? { get }
    static var game: Enka.GameType { get }
}

extension EKQueryResultProtocol {
    public static func queryRAW(uid: String) async throws -> Self {
        try await Enka.Sputnik.fetchEnkaQueryResultRAW(uid, type: Self.self)
    }
}

// MARK: - EKQueriedProfileProtocol

public protocol EKQueriedProfileProtocol: Decodable, Hashable, Equatable {
    associatedtype DBType: EnkaDBProtocol where DBType.QueriedProfile == Self
    associatedtype QueriedAvatar: EKQueriedRawAvatarProtocol where QueriedAvatar.DBType == DBType
    var avatarDetailList: [QueriedAvatar] { get set }
    var uid: String { get set }
    var nickname: String { get }
    var signature: String { get }
    var level: Int { get }
    var worldLevel: Int { get }
    static var locallyCachedData: [String: Self] { get set }
    var headIcon: Int { get }
}

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

    public func saveToCache() {
        Task.detached { @MainActor in
            Self.locallyCachedData[uid] = self
        }
    }

    public static func getCachedProfile(uid: String) -> Self? {
        Self.locallyCachedData[uid]
    }

    public var onlineAssetURLStr: String {
        switch DBType.game {
        case .genshinImpact:
            let matched = Enka.Sputnik.shared.db4GI.profilePictures[headIcon.description]?.iconPath
            return "https://enka.network/ui/\(matched ?? "YJSNPI").png"
        case .starRail:
            let str = Enka.Sputnik.shared.db4HSR.profileAvatars[headIcon.description]?
                .icon.split(separator: "/").last?.description ?? "Anonymous.png"
            return "https://enka.network/ui/hsr/SpriteOutput/AvatarRoundIcon/Avatar/\(str)"
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

// MARK: - EKQueriedRawAvatarProtocol

public protocol EKQueriedRawAvatarProtocol: Identifiable, Hashable, Equatable {
    associatedtype DBType: EnkaDBProtocol where DBType.QueriedProfile.QueriedAvatar == Self
    var avatarId: Int { get }
    var id: String { get }
    func summarize(theDB: DBType) -> Enka.AvatarSummarized?
}
