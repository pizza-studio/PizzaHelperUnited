// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Note4GI

public protocol Note4GI: DailyNoteProtocol {
    associatedtype DailyTaskInfo4GI: PZAccountKit.DailyTaskInfo4GI
    var dailyTaskInfo: DailyTaskInfo4GI { get }
    associatedtype ExpeditionInfo4GI: PZAccountKit.ExpeditionInfo4GI
    var expeditionInfo4GI: ExpeditionInfo4GI { get }
    associatedtype HomeCoinInfo4GI: PZAccountKit.HomeCoinInfo4GI
    var homeCoinInfo: HomeCoinInfo4GI { get }
    associatedtype ResinInfo4GI: PZAccountKit.ResinInfo4GI
    var resinInfo: ResinInfo4GI { get }
}

extension Note4GI {
    public static var game: Pizza.SupportedGame { .genshinImpact }
}

// MARK: - DailyTaskInfo4GI

public protocol DailyTaskInfo4GI {
    var totalTaskCount: Int { get }
    var finishedTaskCount: Int { get }
    var isExtraRewardReceived: Bool { get }
}

// MARK: - ExpeditionInfo4GI

public protocol ExpeditionInfo4GI {
    var maxExpeditionsCount: Int { get }
    associatedtype Expedition: PZAccountKit.Expedition
    var expeditions: [Expedition] { get }
}

extension ExpeditionInfo4GI {
    public var ongoingExpeditionCount: Int {
        expeditions.filter { !$0.isFinished }.count
    }

    public var allCompleted: Bool {
        expeditions.filter { !$0.isFinished }.isEmpty
    }
}

// MARK: - Expedition

public protocol Expedition {
    var isFinished: Bool { get }
    var iconURL: URL { get }
}

// MARK: - HomeCoinInfo4GI

public protocol HomeCoinInfo4GI {
    var maxHomeCoin: Int { get }
    var currentHomeCoin: Int { get }
    var fullTime: Date { get }
}

// MARK: - ResinInfo4GI

public protocol ResinInfo4GI {
    var maxResin: Int { get }
    var currentResin: Int { get }
    var resinRecoveryTime: Date { get }
}
