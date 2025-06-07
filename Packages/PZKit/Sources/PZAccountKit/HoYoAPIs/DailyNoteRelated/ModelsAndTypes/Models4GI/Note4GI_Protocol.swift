// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Note4GI

public protocol Note4GI: DailyNoteProtocol, AbleToCodeSendHash {
    associatedtype DailyTaskInfo4GI: PZAccountKit.DailyTaskInfo4GI
    var dailyTaskInfo: DailyTaskInfo4GI { get }
    associatedtype ExpeditionInfo4GI: PZAccountKit.ExpeditionInfo4GI
    var expeditionInfo: ExpeditionInfo4GI { get }
    associatedtype HomeCoinInfo4GI: PZAccountKit.HomeCoinInfo4GI
    var homeCoinInfo: HomeCoinInfo4GI { get }
    associatedtype ResinInfo4GI: PZAccountKit.ResinInfo4GI
    var resinInfo: ResinInfo4GI { get }
}

extension Note4GI {
    public static var game: Pizza.SupportedGame { .genshinImpact }
}

// MARK: - DailyTaskInfo4GI

public protocol DailyTaskInfo4GI: AbleToCodeSendHash {
    var totalTaskCount: Int { get }
    var finishedTaskCount: Int { get }
    var isExtraRewardReceived: Bool { get }
}

// MARK: - ExpeditionInfo4GI

public protocol ExpeditionInfo4GI: AbleToCodeSendHash {
    var maxExpeditionsCount: Int { get }
    associatedtype Expedition: ExpeditionTask
    var expeditions: [Expedition] { get }
}

// MARK: - HomeCoinInfo4GI

public protocol HomeCoinInfo4GI: AbleToCodeSendHash {
    var maxHomeCoin: Int { get }
    var currentHomeCoin: Int { get }
    var fullTime: Date { get }
}

// MARK: - ResinInfo4GI

public protocol ResinInfo4GI: AbleToCodeSendHash {
    var maxResin: Int { get }
    var currentResin: Int { get }
    var resinRecoveryTime: Date { get }
}
