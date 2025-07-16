// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import Observation
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, *)
extension CaseProfileVM where CoordinatedDB == Enka.EnkaDB4GI {
    static var singletonForPublicQuery: CaseProfileVM<CoordinatedDB> = .init()
    static var singletonForPersonalProfile: [String: CaseProfileVM<CoordinatedDB>] = .init()
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension CaseProfileVM where CoordinatedDB == Enka.EnkaDB4HSR {
    static var singletonForPublicQuery: CaseProfileVM<CoordinatedDB> = .init()
    static var singletonForPersonalProfile: [String: CaseProfileVM<CoordinatedDB>] = .init()
}

// MARK: - CaseProfileVM

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
final class CaseProfileVM<CoordinatedDB: EnkaDBProtocol>: TaskManagedVM {
    // MARK: Lifecycle

    /// 展柜 ViewModel 的建构子。
    ///
    /// - Remark: 注意：
    /// 该 ViewModel 会在 App Tab / NavigationSplitView Root Page 切换时立刻被析构，
    /// 所以严禁任何放在 MainActor 之外的间接脱手操作（哪怕间接也不行）。
    /// （手动制作 singleton 的情况除外，仍需谨慎操作。）
    /// - Parameters:
    ///   - uid: UID
    ///   - theDB: EnkaDB（注意直接决定了游戏类型）。
    public init(uid: String, theDB: CoordinatedDB) {
        self.uid = uid
        self.currentInfo = theDB.getCachedProfileRAW(uid: uid)
        super.init()
        update()
    }

    public override init() {
        // 特殊值，方便前端据此判定是否是首次使用以这个建构子建构的这个副本。
        // 前端应该及时地将这个值清空、或换成其他有效值，免得之后误判这个副本是否符合上述判定目的。
        self.uid = "YJSNPI"
        super.init()
    }

    // MARK: Internal

    var currentInfo: CoordinatedDB.QueriedProfile?

    var uid: String {
        didSet {
            guard oldValue != uid else { return }
            formatText()
        }
    }

    func update(givenUID: Int? = nil, immediately: Bool = true) {
        guard let givenUID = givenUID ?? Int(uid) else { return }
        fireTask(
            preparationTask: nil,
            cancelPreviousTask: immediately,
            givenTask: {
                let enkaDB = CoordinatedDB.shared
                try await enkaDB.reinitIfLocMismatches()
                let profile = try await enkaDB.query(for: givenUID.description)
                // 检查本地 EnkaDB 是否过期，过期了的话就尝试更新。
                if enkaDB.checkIfExpired(against: profile) {
                    let factoryDB = try CoordinatedDB(locTag: Enka.currentLangTag)
                    if !factoryDB.checkIfExpired(against: profile) {
                        enkaDB.update(new: factoryDB)
                    } else {
                        try await enkaDB.onlineUpdate()
                    }
                }
                // 检查本地圣遗物评分模型是否过期，过期了的话就尝试更新。
                if ArtifactRating.sharedDB.isExpired(against: profile) {
                    ArtifactRating.ARSputnik.shared.resetFactoryScoreModel()
                    if ArtifactRating.sharedDB.isExpired(against: profile) {
                        // 圣遗物评分非刚需体验。
                        // 如果在这个过程内出错的话，顶多就是该当角色没有圣遗物评分可用。
                        try? await ArtifactRating.ARSputnik.shared.onlineUpdate()
                    }
                }
                return profile
            },
            completionHandler: { self.currentInfo = $0 },
            errorHandler: { error in
                if error is CancellationError { return }
                super.handleError(error)
            }
        )
    }

    // MARK: Private

    private func formatText() {
        let maxCharInputLimit = 10
        let pattern = "[^0-9]+"
        var toHandle = uid.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        if toHandle.count > maxCharInputLimit {
            toHandle = toHandle.prefix(maxCharInputLimit).description
        }
        // 仅当结果相异时，才会写入。
        if uid != toHandle { uid = toHandle }
    }
}
