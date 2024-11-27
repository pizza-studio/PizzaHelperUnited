// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZBaseKit
@preconcurrency import UserNotifications

@MainActor private var center: UNUserNotificationCenter { PZNotificationCenter.center }

extension PZNotificationCenter {
    public static func refreshScheduledNotifications(
        for profile: PZProfileSendable, dailyNote: any DailyNoteProtocol
    ) {
        #if !os(watchOS)
        NotificationSputnik(profile: profile, dailyNote: dailyNote)
            .refreshPendingNotifications()
        #endif
    }

    public static func bleachNotificationsIfDisabled(for profile: PZProfileSendable) {
        guard !profile.allowNotification else { return }
        deleteDailyNoteNotification(for: profile)
    }

    public static func deleteDailyNoteNotification(for profile: PZProfileSendable) {
        Task { @MainActor in
            let requests = await center.pendingNotificationRequests()
            center.removePendingNotificationRequests(
                withIdentifiers: requests
                    .map(\.identifier)
                    .filter { id in
                        id.contains(profile.uuid.uuidString) || id.contains(profile.uidWithGame)
                    }
            )
        }
    }

    public static func deleteDailyNoteNotification(of type: DailyNoteNotificationType) async throws {
        let requests = await center.pendingNotificationRequests()
        await center.removePendingNotificationRequests(
            withIdentifiers: requests
                .map(\.identifier)
                .filter { id in
                    id.starts(with: type.rawValue)
                }
        )
    }

    public static func deleteDailyNoteNotification(profile: PZProfileSendable, type: DailyNoteNotificationType) async {
        let requests = await center.pendingNotificationRequests()
        await center.removePendingNotificationRequests(
            withIdentifiers: requests
                .map(\.identifier)
                .filter { id in
                    id.starts(with: type.rawValue)
                        && (id.contains(profile.uuid.uuidString) || id.contains(profile.uidWithGame))
                }
        )
    }
}

// MARK: - DailyNoteNotificationType

public enum DailyNoteNotificationType: String {
    case staminaPerThreshold
    case staminaFull
    case dailyTask
    case expeditionSummary
    case expeditionEach
    case giRewardsFromKatheryne
    case giRealmCurrency
    case giParametricTransformer
    case giTrounceBlossomResinDiscounts
    case hsrEchoOfWarRewardsLeft
    case hsrSimulatedUniverse
}

// MARK: - NotificationSputnik

private struct NotificationSputnik {
    // MARK: Lifecycle

    init(profile: PZProfileSendable, dailyNote: any DailyNoteProtocol) {
        self.profile = profile
        self.dailyNote = dailyNote
    }

    // MARK: Fileprivate

    fileprivate let profile: PZProfileSendable
    fileprivate let dailyNote: any DailyNoteProtocol
    fileprivate let options: NotificationOptions = Defaults[.notificationOptions]

    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
}

extension NotificationSputnik {
    // MARK: Internal

    func refreshPendingNotifications() {
        Task { @MainActor in
            do {
                // 如果没有权限的话，会先试图触发请求权限。
                let notificationAllowedByOS = (try? await PZNotificationCenter.requestAuthorization()) ?? false
                // 先清空既有的通知，包括可能已经过期的排定通知。
                PZNotificationCenter.deleteDailyNoteNotification(for: profile)
                // 然后检查此账号是否启用了通知，否则直接中断。
                guard notificationAllowedByOS, profile.allowNotification else { return }
                // STAMINA
                if options.allowStaminaNotification {
                    try await scheduleStaminaFullNotification()
                    if case let .notifyAt(_, hour, minute) = options.giKatheryneNotificationSetting {
                        try await scheduleGIKatheryneRewardsNotification(hour: hour, minute: minute)
                    }
                    // 去除可能重复的通知阈值。
                    var thresholds = options.staminaAdditionalNotificationThresholds
                        .byGame(profile.game).map(\.threshold)
                    thresholds = Array(Set(thresholds)) // Already sorted while being filtered by game.
                    for number in thresholds {
                        try await scheduleStaminaNotification(to: number)
                    }
                }
                // EXPEDITION
                if options.allowExpeditionNotification, dailyNote.hasExpeditions {
                    switch options.expeditionNotificationSetting {
                    case .onlySummary:
                        try await scheduleExpeditionSummaryNotification()
                    case .forEachExpedition:
                        for (index, expedition) in dailyNote.expeditionTasks.enumerated() {
                            // Swift 的 .enumerated() 以 0 作为第一个值，所以在这里需要 +1。
                            try await scheduleEachExpeditionNotification(expedition: expedition, index: index + 1)
                        }
                    }
                }
                // DAILY TASK
                if case let .notifyAt(_, hour, minute) = options.dailyTaskNotificationSetting {
                    try await scheduleDailyTaskNotification(hour: hour, minute: minute)
                }
                // REALM CURRENCY (GI)
                if options.allowGIRealmCurrencyNotification {
                    try await scheduleGIRealmCurrencyNotification()
                }
                // PARAMETRIC TRANSFORMER (GI)
                if options.allowGITransformerNotification {
                    try await scheduleGITransformerNotification()
                }
                // TROUNCE BLOSSOM RESIN DISCOUNTS (GI)
                if case let .notifyAt(weekday, hour, minute) = options.giTrounceBlossomNotificationSetting {
                    try await scheduleGITrounceBlossomNotification(
                        weekday: Swift.max(0, Swift.min(7, weekday)),
                        hour: hour,
                        minute: minute
                    )
                }
                // ECHO OF WAR (HSR)
                if case let .notifyAt(weekday, hour, minute) = options.hsrEchoOfWarNotificationSetting {
                    try await scheduleHSREchoOfWarNotification(
                        weekday: Swift.max(0, Swift.min(7, weekday)),
                        hour: hour,
                        minute: minute
                    )
                }
                // SIMULATED UNIVERSE (HSR)
                if case let .notifyAt(weekday, hour, minute) = options.hsrSimulUnivNotificationSetting {
                    try await scheduleHSRSimulatedUniverseNotification(
                        weekday: Swift.max(0, Swift.min(7, weekday)),
                        hour: hour,
                        minute: minute
                    )
                }
            } catch {
                print("[PZHelper.NotificationException] \(error)")
            }
        }
    }

    private func getID(for type: DailyNoteNotificationType, extraID: String = "") -> String {
        type.rawValue + profile.uidWithGame + extraID
    }

    private func deleteNotification(_ type: DailyNoteNotificationType) async {
        await PZNotificationCenter.deleteDailyNoteNotification(profile: profile, type: type)
    }

    /// 玩家体力，只要不满载就不提醒。
    @MainActor
    private func scheduleStaminaFullNotification() async throws {
        let timeOnFinish = dailyNote.staminaFullTimeOnFinish
        guard timeOnFinish > .now else {
            await deleteNotification(.staminaFull)
            return
        }
        let remainingSecs = timeOnFinish.timeIntervalSince1970 - Date.now.timeIntervalSince1970
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.stamina.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.stamina.full.body:%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))"
        )
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remainingSecs, repeats: false)
        let id = getID(for: .staminaFull)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 玩家体力，按阈值提醒。
    @MainActor
    private func scheduleStaminaNotification(to threshold: Int) async throws {
        let information = dailyNote.staminaIntel
        guard threshold <= information.all else { return } // 阈值不得高于满载值。
        let timeOnFinish = dailyNote.staminaFullTimeOnFinish
        let remainingSecs = timeOnFinish.timeIntervalSince1970 - Date.now.timeIntervalSince1970
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.stamina.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.stamina.customize.body:%@%@%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))",
            threshold.description,
            dateFormatter.string(from: timeOnFinish)
        )
        content.badge = 1
        let timeInterval = remainingSecs - Double(information.all - threshold) * dailyNote.eachStaminaRecoveryTime
        guard timeInterval > 0 else {
            await deleteNotification(.staminaPerThreshold)
            return
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let id = getID(for: .staminaPerThreshold, extraID: threshold.description)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 星穹铁道的话，恐仅对米游社账号有效，因为国际服的星穹铁道的探索派遣没有预计完成时间。
    @MainActor
    private func scheduleExpeditionSummaryNotification() async throws {
        guard dailyNote.hasExpeditions else { return }
        guard let eta = dailyNote.expeditionTotalETA, eta.timeIntervalSinceNow > 0 else {
            await deleteNotification(.expeditionSummary)
            return
        }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.expedition.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.expedition.summary.body:%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))"
        )
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: eta.timeIntervalSinceNow, repeats: false)
        let id = getID(for: .expeditionSummary)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 原神没有探索派遣任务名称，而星穹铁道的探索派遣任务名称无法本地化，所以用队伍编号代替。
    @MainActor
    private func scheduleEachExpeditionNotification(expedition: ExpeditionTask, index: Int) async throws {
        guard dailyNote.hasExpeditions else { return }
        guard let eta = expedition.timeOnFinish, eta.timeIntervalSinceNow > 0 else { return }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.expedition.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.expedition.each.body:%@%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))",
            index.description
        )
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: eta.timeIntervalSinceNow, repeats: false)
        let id = getID(for: .expeditionEach)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 每日任务。
    @MainActor
    private func scheduleDailyTaskNotification(hour: Int, minute: Int) async throws {
        guard dailyNote.hasDailyTaskIntel else { return }
        let sitrep = dailyNote.dailyTaskCompletionStatus
        guard !sitrep.isAccomplished else {
            await deleteNotification(.dailyTask)
            return
        }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.dailyTask.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.dailyTask.body:%@%@%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))",
            sitrep.finished.description,
            sitrep.all.description
        )
        content.badge = 1
        let dateComponents = DateComponents(calendar: .current, hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let id = getID(for: .dailyTask)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 凯瑟琳每日奖励。
    @MainActor
    private func scheduleGIKatheryneRewardsNotification(hour: Int, minute: Int) async throws {
        guard profile.game == .genshinImpact else {
            await deleteNotification(.giRewardsFromKatheryne)
            return
        }
        guard dailyNote.hasDailyTaskIntel else { return }
        // 只有尚未领取时才提醒。
        guard !(dailyNote.claimedRewardsFromKatheryne ?? true) else {
            await deleteNotification(.giRewardsFromKatheryne)
            return
        }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.katheryneRewardsAvailable.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.katheryneRewardsAvailable.body:%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))"
        )
        content.badge = 1
        let dateComponents = DateComponents(calendar: .current, hour: hour, minute: minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let id = getID(for: .giRewardsFromKatheryne)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 洞天宝钱。
    @MainActor
    private func scheduleGIRealmCurrencyNotification() async throws {
        guard profile.game == .genshinImpact else {
            await deleteNotification(.giRealmCurrency)
            return
        }
        guard let eta = dailyNote.realmCurrencyIntel?.fullTime, eta.timeIntervalSinceNow > 0 else { return }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.realmCurrency.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.realmCurrency.body:%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))"
        )
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: eta.timeIntervalSinceNow, repeats: false)
        let id = getID(for: .giRealmCurrency)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 参量质变仪。
    @MainActor
    private func scheduleGITransformerNotification() async throws {
        guard profile.game == .genshinImpact else {
            await deleteNotification(.giParametricTransformer)
            return
        }
        guard let intel = dailyNote.parametricTransformerIntel else { return }
        guard intel.obtained else { return }
        let eta = intel.recoveryTime
        guard eta.timeIntervalSinceNow > 0 else { return }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.parametricTransformer.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.parametricTransformer.body:%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))"
        )
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: eta.timeIntervalSinceNow, repeats: false)
        let id = getID(for: .giParametricTransformer)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 原神征讨之花树脂折扣，用光了的话不再提醒。
    @MainActor
    private func scheduleGITrounceBlossomNotification(weekday: Int, hour: Int, minute: Int) async throws {
        guard profile.game == .genshinImpact else {
            await deleteNotification(.giTrounceBlossomResinDiscounts)
            return
        }
        guard let trounceBlossom = dailyNote.trounceBlossomIntel else { return }
        guard !trounceBlossom.allDiscountsAreUsedUp else {
            await deleteNotification(.giTrounceBlossomResinDiscounts)
            return
        }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.trounceBlossom.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.trounceBlossom.body:%@%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))",
            trounceBlossom.remainResinDiscount.description
        )
        content.badge = 1
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute, weekday: weekday),
            repeats: false
        )
        let id = getID(for: .giTrounceBlossomResinDiscounts)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 星穹铁道历战馀响奖励剩余次数，领光了的话不再提醒。
    @MainActor
    private func scheduleHSREchoOfWarNotification(weekday: Int, hour: Int, minute: Int) async throws {
        guard profile.game == .genshinImpact else {
            await deleteNotification(.hsrEchoOfWarRewardsLeft)
            return
        }
        guard let eowIntel = dailyNote.echoOfWarIntel else { return }
        guard !eowIntel.allRewardsClaimed else {
            await deleteNotification(.hsrEchoOfWarRewardsLeft)
            return
        }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.echoOfWar.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.echoOfWar.body:%@%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))",
            eowIntel.weeklyEOWRewardsLeft.description
        )
        content.badge = 1
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute, weekday: weekday),
            repeats: false
        )
        let id = getID(for: .hsrEchoOfWarRewardsLeft)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }

    /// 星穹铁道模拟宇宙。
    @MainActor
    private func scheduleHSRSimulatedUniverseNotification(weekday: Int, hour: Int, minute: Int) async throws {
        guard profile.game == .starRail else {
            await deleteNotification(.hsrSimulatedUniverse)
            return
        }
        guard let simulatedUniverse = dailyNote.simulatedUniverseIntel else { return }
        guard simulatedUniverse.currentScore < simulatedUniverse.maxScore else {
            await deleteNotification(.hsrSimulatedUniverse)
            return
        }
        let content = UNMutableNotificationContent()
        let gameTag = "[\(profile.game.localizedShortName)] "
        content.title = gameTag + String(
            format: String(localized: "notification.simulatedUniverse.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.simulatedUniverse.body:%@%@%@", bundle: .module),
            "\(profile.name) (\(profile.uidWithGame))",
            simulatedUniverse.currentScore.description,
            simulatedUniverse.maxScore.description
        )
        content.badge = 1
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: hour, minute: minute, weekday: weekday),
            repeats: false
        )
        let id = getID(for: .hsrSimulatedUniverse)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await center.add(request)
    }
}
