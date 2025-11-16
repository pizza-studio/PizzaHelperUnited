// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - MetaBar4DailyTask

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4DailyTask: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        note.game.dailyTaskAssetIcon
    }

    public var statusIcon4SUI: Image {
        if note.dailyTaskCompletionStatus.isAccomplished {
            if let extraRewardClaimed = note.claimedRewardsFromKatheryne {
                Image(systemSymbol: extraRewardClaimed ? .checkmark : .exclamationmark)
            } else {
                Image(systemSymbol: .checkmark)
            }
        } else {
            Image(systemSymbol: .ellipsis)
        }
    }

    public var statusTextUnits4SUI: [Text] {
        var result = [Text]()
        let sitrep = note.dailyTaskCompletionStatus
        result.append(Text(verbatim: "\(sitrep.finished) / \(sitrep.all)"))
        let extraRewardClaimed = note.claimedRewardsFromKatheryne
        if sitrep.isAccomplished, !(extraRewardClaimed ?? true) {
            let key: String.LocalizationValue = "pzWidgetsKit.status.not_received"
            result.append(Text(String(localized: key, bundle: .module)).fontWidth(.condensed))
        }
        return result
    }

    public var completionStatusRatio: Double {
        let sitrep = note.dailyTaskCompletionStatus
        guard sitrep.all > 0 else { return 0 }
        return Double(sitrep.finished) / Double(sitrep.all)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }
}

// MARK: - MetaBar4Expedition

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4Expedition: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        // ZZZ 没有探索派遣资料。
        if note is Note4ZZZ { return nil }
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        note.game.expeditionAssetIcon
    }

    public var statusIcon4SUI: Image {
        Image(systemSymbol: .figureWalk)
    }

    public var statusTextUnits4SUI: [Text] {
        let sitrep = note.expeditionCompletionStatus
        return [Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")]
    }

    public var completionStatusRatio: Double {
        let sitrep = note.expeditionCompletionStatus
        guard sitrep.all > 0 else { return 0 }
        return Double(sitrep.finished) / Double(sitrep.all)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }
}

// MARK: - MetaBar4WeeklyBosses

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4WeeklyBosses: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any PZAccountKit.DailyNoteProtocol) {
        self.init(note: note, disappearIfAllCompleted: false)
    }

    nonisolated public init?(note: any DailyNoteProtocol, disappearIfAllCompleted: Bool) {
        self.note = note
        guard isInfoAvailable else { return nil }
        if disappearIfAllCompleted {
            guard !allCompleted else { return nil }
        }
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        switch game {
        case .genshinImpact:
            Pizza.SupportedGame.genshinImpact.giTrounceBlossomAssetIcon
        case .starRail:
            Pizza.SupportedGame.genshinImpact.hsrEchoOfWarAssetIcon
        case .zenlessZone:
            Image(systemSymbol: .slashCircle)
        }
    }

    public var statusIcon4SUI: Image {
        let giStatus = note.trounceBlossomIntel?.allDiscountsAreUsedUp ?? false
        let hsrStatus = note.echoOfWarIntel?.allRewardsClaimed ?? false
        return (giStatus || hsrStatus)
            ? Image(systemSymbol: .checkmark)
            : Image(systemSymbol: .questionmark)
    }

    public var statusTextUnits4SUI: [Text] {
        let giStatus = note.trounceBlossomIntel?.textDescription
        let hsrStatus = note.echoOfWarIntel?.textDescription
        return [Text(verbatim: giStatus ?? hsrStatus ?? "N/A")]
    }

    public var completionStatusRatio: Double {
        if let info = note.trounceBlossomIntel {
            let current = info.totalResinDiscount - info.remainResinDiscount
            guard info.totalResinDiscount > 0 else { return 0 }
            return Double(current) / Double(info.totalResinDiscount)
        } else if let info = note.echoOfWarIntel {
            let current = info.weeklyEOWMaxRewards - info.weeklyEOWRewardsLeft
            let max = info.weeklyEOWMaxRewards
            guard max > 0 else { return 0 }
            return Double(current) / Double(max)
        }
        return 0
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    nonisolated private var isInfoAvailable: Bool {
        switch game {
        case .genshinImpact: note.trounceBlossomIntel != nil
        case .starRail: note.echoOfWarIntel != nil
        case .zenlessZone: false
        }
    }

    nonisolated private var allCompleted: Bool {
        let giStatus = note.trounceBlossomIntel?.allDiscountsAreUsedUp ?? false
        let hsrStatus = note.echoOfWarIntel?.allRewardsClaimed ?? false
        return giStatus || hsrStatus
    }
}

// MARK: - MetaBar4GIRealmCurrency

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4GIRealmCurrency: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let info = note.realmCurrencyIntel else { return nil }
        self.info = info
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetIcon
    }

    public var statusIcon4SUI: Image {
        info.currentHomeCoin == info.maxHomeCoin
            ? Image(systemSymbol: .exclamationmark)
            : Image(systemSymbol: .leafFill)
    }

    public var statusTextUnits4SUI: [Text] {
        [Text(verbatim: "\(info.currentHomeCoin)")]
    }

    public var completionStatusRatio: Double {
        guard info.maxHomeCoin > 0 else { return 0 }
        return Double(info.currentHomeCoin) / Double(info.maxHomeCoin)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let info: any HomeCoinInfo4GI
}

// MARK: - MetaBar4GITransformer

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4GITransformer: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let info = (note as? FullNote4GI)?.transformerInfo else { return nil }
        guard info.obtained else { return nil }
        self.info = info
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.genshinImpact.giTransformerAssetIcon
    }

    public var statusIcon4SUI: Image {
        info.isAvailable
            ? Image(systemSymbol: .checkmark)
            : Image(systemSymbol: .hourglass)
    }

    public var statusTextUnits4SUI: [Text] {
        if info.isAvailable {
            let key: String.LocalizationValue = "pzWidgetsKit.infoBlock.transformerAvailable"
            return [Text(String(localized: key, bundle: .module)).fontWidth(.condensed)]
        } else if info.remainingDays > 0 {
            let key: String.LocalizationValue = "pzWidgetsKit.unit.day:\(info.remainingDays)"
            return [Text(String(localized: key, bundle: .module)).fontWidth(.condensed)]
        } else {
            let intervalString = PZWidgetsSPM.intervalFormatter
                .string(from: TimeInterval.sinceNow(to: info.recoveryTime)) ?? ""
            return [Text(verbatim: intervalString)]
        }
    }

    public var completionStatusRatio: Double {
        info.percentage
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let info: FullNote4GI.TransformerInfo4GI
}

// MARK: - MetaBar4HSRReservedTBPower

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4HSRReservedTBPower: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let info = (note as? (any Note4HSR))?.staminaInfo else { return nil }
        self.info = info
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.starRail.secondaryStaminaAssetIcon
    }

    public var statusIcon4SUI: Image {
        info.currentReserveStamina == info.maxReserveStamina
            ? Image(systemSymbol: .exclamationmark)
            : Image(systemSymbol: .leafFill)
    }

    public var statusTextUnits4SUI: [Text] {
        [Text(verbatim: "\(info.currentReserveStamina)")]
    }

    public var completionStatusRatio: Double {
        guard info.maxReserveStamina > 0 else { return 0 }
        return Double(info.currentReserveStamina) / Double(info.maxReserveStamina)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let info: StaminaInfo4HSR
}

// MARK: - MetaBar4HSRSimulUniv

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4HSRSimulUniv: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let hsr = note as? (any Note4HSR) else { return nil }
        self.intel = hsr.simulatedUniverseInfo
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        (note as? (any Note4HSR))?.game.hsrSimulatedUniverseAssetIcon ?? Image(systemName: "questionmark")
    }

    public var statusIcon4SUI: Image {
        let isFinished = intel.currentScore == intel.maxScore
        return isFinished ? Image(systemSymbol: .checkmark) : Image(systemSymbol: .ellipsis)
    }

    public var statusTextUnits4SUI: [Text] {
        guard intel.currentScore < intel.maxScore else { return [Text(verbatim: "100%")] }
        let ratio = (Double(intel.currentScore) / Double(intel.maxScore) * 100).rounded(.down)
        guard ratio <= 100, ratio >= 0 else { return [Text(verbatim: "100%")] }
        return [Text(verbatim: "\(Int(ratio))%")]
    }

    public var completionStatusRatio: Double {
        guard intel.maxScore > 0 else { return 0 }
        return Double(intel.currentScore) / Double(intel.maxScore)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let intel: SimuUnivInfo4HSR
}

// MARK: - MetaBar4ZZZBounty

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4ZZZBounty: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let zzz = note as? Note4ZZZ, let data = zzz.hollowZero.bountyCommission else { return nil }
        self.data = data
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.zenlessZone.zzzBountyAssetIcon
    }

    public var statusIcon4SUI: Image {
        Image(systemSymbol: .scope)
    }

    public var statusTextUnits4SUI: [Text] {
        [Text(verbatim: "\(data.num) / \(data.total)")]
    }

    public var completionStatusRatio: Double {
        guard data.total > 0 else { return 0 }
        return Double(data.num) / Double(data.total)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let data: Note4ZZZ.HollowZero.BountyCommission
}

// MARK: - MetaBar4ZZZInvestigationPoint

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4ZZZInvestigationPoint: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let zzz = note as? Note4ZZZ, let data = zzz.hollowZero.investigationPoint else { return nil }
        self.data = data
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.zenlessZone.zzzInvestigationPointsAssetIcon
    }

    public var statusIcon4SUI: Image {
        Image(systemSymbol: .textMagnifyingglass)
    }

    public var statusTextUnits4SUI: [Text] {
        [Text(verbatim: "\(data.num) / \(data.total)")]
    }

    public var completionStatusRatio: Double {
        guard data.total > 0 else { return 0 }
        return Double(data.num) / Double(data.total)
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let data: Note4ZZZ.HollowZero.InvestigationPointIntel
}

// MARK: - MetaBar4ZZZScratchCard

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4ZZZScratchCard: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let zzz = note as? Note4ZZZ, let scratched = zzz.cardScratched else { return nil }
        self.scratchable = !scratched
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.zenlessZone.zzzScratchCardAssetIcon
    }

    public var statusIcon4SUI: Image {
        Image(systemSymbol: .giftcardFill)
    }

    public var statusTextUnits4SUI: [Text] {
        let key: String.LocalizationValue = scratchable
            ? "pzWidgetsKit.infoBlock.zzzScratchableCard.notYet"
            : "pzWidgetsKit.infoBlock.zzzScratchableCard.done"
        return [Text(String(localized: key, bundle: .module)).fontWidth(.condensed)]
    }

    public var completionStatusRatio: Double {
        scratchable ? 0.0 : 1.0
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let scratchable: Bool
}

// MARK: - MetaBar4ZZZVHSStore

@available(iOS 16.2, macCatalyst 16.2, *)
public struct MetaBar4ZZZVHSStore: View, MetaBar {
    // MARK: Lifecycle

    public init?(note: any DailyNoteProtocol) {
        guard let zzz = note as? Note4ZZZ else { return nil }
        self.state = zzz.vhsStoreState
        self.note = note
    }

    // MARK: Public

    public let note: any DailyNoteProtocol

    public var labelIcon4SUI: Image {
        Pizza.SupportedGame.zenlessZone.zzzVHSStoreAssetIcon
    }

    public var statusIcon4SUI: Image {
        Image(systemSymbol: .recordingtape)
    }

    public var statusTextUnits4SUI: [Text] {
        [Text(state.localizedDescription)]
    }

    public var completionStatusRatio: Double {
        1.0
    }

    public var game: Pizza.SupportedGame {
        note.game
    }

    // MARK: Private

    private let state: Note4ZZZ.VHSState
}
