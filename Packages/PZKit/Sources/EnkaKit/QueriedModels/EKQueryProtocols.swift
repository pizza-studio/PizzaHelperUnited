// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - EKQueryResultProtocol

public protocol EKQueryResultProtocol {
    associatedtype QueriedProfileType = EKQueriedProfileProtocol
    var detailInfo: QueriedProfileType? { get set }
    var uid: String? { get }
    var message: String? { get }
    static var game: Enka.GameType { get }
}

// MARK: - EKQueriedProfileProtocol

public protocol EKQueriedProfileProtocol {
    associatedtype QueriedAvatar = EKQueriedRawAvatarProtocol
    var avatarDetailList: [QueriedAvatar] { get set }
    var uid: Int { get }
}

extension EKQueriedProfileProtocol where QueriedAvatar == any EKQueriedRawAvatarProtocol {
    /// 仅制作这个新 API 将旧资料融入新资料，因为反向融合没有任何意义。
    public mutating func merge(old: Self?) -> Self {
        var newResult = self
        old?.avatarDetailList.forEach { oldAvatar in
            guard !avatarDetailList.map(\.avatarId).contains(oldAvatar.avatarId) else { return }
            newResult.avatarDetailList.append(oldAvatar)
        }
        return newResult
    }
}

// MARK: - EKQueriedRawAvatarProtocol

public protocol EKQueriedRawAvatarProtocol: Identifiable {
    var avatarId: Int { get }
    var id: Int { get }
}
