// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI

extension PZProfileSendable {
    public func getDailyNote(cached returnCachedResult: Bool = false) async throws -> DailyNoteProtocol {
        handleCachedResults: if returnCachedResult {
            let possibleResult: DailyNoteProtocol? = switch game {
            case .genshinImpact:
                DailyNoteCacheSputnik<FullNote4GI>.getCache(
                    uidWithGame: uidWithGame
                ) ?? DailyNoteCacheSputnik<WidgetNote4GI>.getCache(
                    uidWithGame: uidWithGame
                )
            case .starRail: DailyNoteCacheSputnik<FullNote4HSR>.getCache(uidWithGame: uidWithGame)
            case .zenlessZone: DailyNoteCacheSputnik<Note4ZZZ>.getCache(uidWithGame: uidWithGame)
            }
            guard let possibleResult else { break handleCachedResults }
            return possibleResult
        }
        await HoYo.waitFor300ms()
        do {
            let result = switch game {
            case .genshinImpact: try await HoYo.note4GI(profile: self)
            case .starRail: try await HoYo.note4HSR(profile: self)
            case .zenlessZone: try await HoYo.note4ZZZ(profile: self)
            }
            PZNotificationCenter.refreshScheduledNotifications(for: self, dailyNote: result)
            return result
        } catch {
            throw error
        }
    }
}

extension PZProfileMO {
    public func getDailyNote() async throws -> DailyNoteProtocol {
        try await asSendable.getDailyNote()
    }
}

extension Pizza.SupportedGame {
    public var maxPrimaryStamina: Int {
        switch self {
        case .genshinImpact: 200
        case .zenlessZone: 240
        case .starRail: 300
        }
    }

    public var exampleDailyNoteData: DailyNoteProtocol {
        switch self {
        case .genshinImpact: FullNote4GI.exampleData()
        case .starRail: FullNote4HSR.exampleData()
        case .zenlessZone: Note4ZZZ.exampleData()
        }
    }

    /// DailyNoteProtocol: Stamina, counted as seconds.
    public var eachStaminaRecoveryTime: TimeInterval {
        switch self {
        case .genshinImpact: 60 * 8
        case .starRail: 60 * 6
        case .zenlessZone: 60 * 6
        }
    }
}

// MARK: - DailyNoteProtocol

public protocol DailyNoteProtocol: Sendable, DecodableFromMiHoYoAPIJSONResult {
    static var game: Pizza.SupportedGame { get }
    static func exampleData() -> Self
}

extension DailyNoteProtocol {
    public var game: Pizza.SupportedGame { Self.game }
}

// MARK: - Per-game properties (Stamina)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: Stamina, counted as seconds.
    public var eachStaminaRecoveryTime: TimeInterval {
        game.eachStaminaRecoveryTime
    }

    /// DailyNoteProtocol: Stamina
    public var staminaFullTimeOnFinish: Date {
        switch self {
        case let dailyNote as any Note4GI:
            return dailyNote.resinInfo.resinRecoveryTime
        case let dailyNote as Note4HSR:
            return dailyNote.staminaInfo.fullTime
        case let dailyNote as Note4ZZZ:
            return dailyNote.energy.timeOnFinish
        default: return .now
        }
    }

    /// DailyNoteProtocol: Stamina
    public var staminaIntel: FieldCompletionIntel<Int> {
        switch self {
        case let dailyNote as any Note4GI:
            let existing: Int = dailyNote.resinInfo.currentResinDynamic
            let max = dailyNote.resinInfo.maxResin
            let restToFill = max - existing
            return .init(pending: restToFill, finished: existing, all: max)
        case let dailyNote as Note4HSR:
            let existing: Int = dailyNote.staminaInfo.currentStamina
            let max = dailyNote.staminaInfo.maxStamina
            let restToFill = max - existing
            return .init(pending: restToFill, finished: existing, all: max)
        case let dailyNote as Note4ZZZ:
            let existing: Int = dailyNote.energy.currentEnergyAmountDynamic
            let max = dailyNote.energy.progress.max
            let restToFill = max - existing
            return .init(pending: restToFill, finished: existing, all: max)
        default: return .init(pending: 0, finished: 0, all: 0)
        }
    }

    /// DailyNoteProtocol: Stamina
    public var maxPrimaryStamina: Int { Self.maxPrimaryStamina }

    /// DailyNoteProtocol: Stamina
    public static var maxPrimaryStamina: Int {
        game.maxPrimaryStamina
    }
}

// MARK: - Per-game properties (Expedition)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: Expedition
    public var hasExpeditions: Bool { !expeditionTasks.isEmpty }

    /// DailyNoteProtocol: Expedition
    public var expeditionTasks: [any ExpeditionTask] {
        switch self {
        case let dailyNote as FullNote4GI: dailyNote.expeditionInfo.expeditions
        case let dailyNote as WidgetNote4GI: dailyNote.expeditionInfo.expeditions
        case let dailyNote as Note4HSR: dailyNote.assignmentInfo.assignments
        case _ as Note4ZZZ: []
        default: []
        }
    }

    /// DailyNoteProtocol: Expedition
    public var expeditionCompletionStatus: FieldCompletionIntel<Int> {
        let theExpeditions = expeditionTasks
        let pending = theExpeditions.pendingTaskCount
        let finished = theExpeditions.finishedTaskCount
        let all = theExpeditions.count
        return .init(pending: pending, finished: finished, all: all)
    }

    /// DailyNoteProtocol: Expedition
    public var allExpeditionsAccomplished: Bool {
        expeditionTasks.allAccomplished
    }

    /// DailyNoteProtocol: Expedition, estimated time of accomplishment.
    public var expeditionTotalETA: Date? {
        expeditionTasks.totalETA
    }
}

// MARK: - Per-game properties (DailyTask / DailyTraining / Vitality)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: DailyTaskTrainingVitality. Will return nil for non-Genshin DailyNotes.
    ///
    /// 凯瑟琳的领奖状态独立于每日任务之外。
    public var claimedRewardsFromKatheryne: Bool? {
        switch self {
        case let dailyNote as any Note4GI: dailyNote.dailyTaskInfo.isExtraRewardReceived
        case _ as Note4HSR: nil
        case _ as Note4ZZZ: nil
        default: nil
        }
    }

    /// DailyNoteProtocol: DailyTaskTrainingVitality
    public var hasDailyTaskIntel: Bool {
        switch self {
        case _ as any Note4GI: true
        case _ as Note4HSR: true
        case _ as Note4ZZZ: true
        default: false
        }
    }

    /// DailyNoteProtocol: DailyTaskTrainingVitality
    public var allDailyTasksAccomplished: Bool? {
        let extraRewards = claimedRewardsFromKatheryne ?? true
        return dailyTaskCompletionStatus.isAccomplished && extraRewards
    }

    /// DailyNoteProtocol: DailyTaskTrainingVitality
    public var dailyTaskCompletionStatus: FieldCompletionIntel<Int> {
        switch self {
        case let dailyNote as any Note4GI:
            let intel = dailyNote.dailyTaskInfo
            return .init(
                pending: intel.totalTaskCount - intel.finishedTaskCount,
                finished: intel.finishedTaskCount,
                all: intel.totalTaskCount
            )
        case let dailyNote as Note4HSR:
            let intel = dailyNote.dailyTrainingInfo
            return .init(
                pending: Int((Double(intel.maxScore - intel.currentScore) / 100).rounded(.down)),
                finished: Int((Double(intel.currentScore) / 100).rounded(.down)),
                all: Int((Double(intel.maxScore) / 100).rounded(.down))
            )
        case let dailyNote as Note4ZZZ:
            let intel = dailyNote.vitality
            return .init(
                pending: Int((Double(intel.max - intel.current) / 100).rounded(.down)),
                finished: Int((Double(intel.current) / 100).rounded(.down)),
                all: Int((Double(intel.max) / 100).rounded(.down))
            )
        default:
            return .init(pending: 0, finished: 0, all: 0)
        }
    }
}

// MARK: - Per-game properties (Realm Currency)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: RealmCurrency, Genshin Impact Only
    public var realmCurrencyIntel: HomeCoinInfo4GI? {
        (self as? any Note4GI)?.homeCoinInfo
    }
}

// MARK: - Per-game properties (Simulated Universe)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: SimulatedUniverse, Star Rail Only
    public var simulatedUniverseIntel: SimuUnivInfo4HSR? {
        (self as? FullNote4HSR)?.simulatedUniverseInfo
    }
}

// MARK: - Per-game properties (Parametric Transformer)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: ParametricTransformer, Genshin Impact Only
    public var parametricTransformerIntel: FullNote4GI.TransformerInfo4GI? {
        (self as? FullNote4GI)?.transformerInfo
    }
}

// MARK: - Per-game properties (Genshin Weekly-Boss Resin Discounts)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: WeeklyBossesResinDiscounts, Genshin Impact Only
    public var trounceBlossomIntel: FullNote4GI.WeeklyBossesInfo4GI? {
        (self as? FullNote4GI)?.weeklyBossesInfo
    }
}

// MARK: - Per-game properties (HSR Echo-of-War Weekly Attempts)

extension DailyNoteProtocol {
    /// DailyNoteProtocol: HSR Echo-of-War Weekly Attempts, Star Rail Only
    public var echoOfWarIntel: EchoOfWarInfo4HSR? {
        (self as? FullNote4HSR)?.echoOfWarCostStatus
    }
}

// MARK: - Asset Icons (non-SVG)

extension Pizza.SupportedGame {
    /// 主要玩家体力。
    public var primaryStaminaAssetIcon: Image {
        let assetName = switch self {
        case .genshinImpact: "gi_note_resin"
        case .starRail: "hsr_note_trailblazePower"
        case .zenlessZone: "zzz_note_battery"
        }
        return AccountKit.imageAsset(assetName)
    }

    /// 后备体力。
    public var secondaryStaminaAssetIcon: Image {
        switch self {
        case .starRail: AccountKit.imageAsset("hsr_note_trailblazePowerReserved")
        case .zenlessZone: AccountKit.imageAsset("zzz_note_battery_backup")
        default: AccountKit.imageAsset("gi_note_resin_condensed")
        }
    }

    public var dailyTaskAssetIcon: Image {
        let assetName = switch self {
        case .genshinImpact: "gi_note_dailyTask"
        case .starRail: "hsr_note_dailyTask"
        case .zenlessZone: "zzz_note_vitality"
        }
        return AccountKit.imageAsset(assetName)
    }

    public var expeditionAssetIcon: Image {
        let assetName = switch self {
        case .genshinImpact: "gi_note_expedition"
        case .starRail: "hsr_note_expedition"
        case .zenlessZone: "gi_note_expedition"
        }
        return AccountKit.imageAsset(assetName)
    }

    public var giTrounceBlossomAssetIcon: Image {
        AccountKit.imageAsset("gi_note_weeklyBosses")
    }

    public var giTransformerAssetIcon: Image {
        AccountKit.imageAsset("gi_note_transformer")
    }

    public var giRealmCurrencyAssetIcon: Image {
        AccountKit.imageAsset("gi_note_teapot_coin")
    }

    public var hsrEchoOfWarAssetIcon: Image {
        AccountKit.imageAsset("hsr_note_weeklyBosses")
    }

    public var hsrSimulatedUniverseAssetIcon: Image {
        AccountKit.imageAsset("hsr_note_simulatedUniverse")
    }

    public var zzzVHSStoreAssetIcon: Image {
        AccountKit.imageAsset("zzz_note_vhsStore")
    }

    public var zzzScratchCardAssetIcon: Image {
        AccountKit.imageAsset("zzz_note_scratchCard")
    }

    public var zzzBountyAssetIcon: Image {
        AccountKit.imageAsset("zzz_note_bounty")
    }

    public var zzzInvestigationPointsAssetIcon: Image {
        AccountKit.imageAsset("zzz_note_investigationPoints")
    }
}
