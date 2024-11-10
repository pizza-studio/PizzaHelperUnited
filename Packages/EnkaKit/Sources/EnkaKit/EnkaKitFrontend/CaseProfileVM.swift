// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import Observation
import PZBaseKit

@Observable
final class CaseProfileVM<CoordinatedDB: EnkaDBProtocol>: TaskManagedVM {
    // MARK: Lifecycle

    /// 展柜 ViewModel 的建构子。
    ///
    /// - Remark: 注意：该 ViewModel 会在 App Tab 切换时立刻被析构，
    /// 所以严禁任何放在 MainActor 之外的间接脱手操作（哪怕间接也不行）。
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
        self.uid = "YJSNPI"
        super.init()
    }

    // MARK: Internal

    var currentInfo: CoordinatedDB.QueriedProfile?
    var uid: String

    func update(givenUID: Int? = nil, immediately: Bool = true) {
        guard let givenUID = givenUID ?? Int(uid) else { return }
        fireTask(
            animatedPreparationTask: nil,
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
}
