// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZBaseKit
@preconcurrency import UserNotifications

@MainActor private var center: UNUserNotificationCenter { PZNotificationCenter.center }

extension PZNotificationCenter {
    public static func scheduleNotification(for profile: PZProfileSendable, dailyNote: any DailyNoteProtocol) {
        #if !os(watchOS)
        NotificationSputnik(profile: profile, dailyNote: dailyNote)
            .send()
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
                        id.contains(profile.uuid.uuidString)
                    }
            )
        }
    }

    public static func deleteDailyNoteNotification(for type: DailyNoteNotificationType) async throws {
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
                    id.starts(with: type.rawValue) && id.contains(profile.uuid.uuidString)
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
    case hsrSimulatedUniverse
}

// MARK: - DailyNoteNotificationSetting

public enum DailyNoteNotificationSetting {
    public enum ExpeditionNotificationSetting: String, _DefaultsSerializable, CustomStringConvertible, CaseIterable {
        case onlySummary
        case forEachExpedition

        // MARK: Public

        public var description: String {
            String(localized: descriptionKey, bundle: .module)
        }

        public var descriptionKey: String.LocalizationValue {
            switch self {
            case .onlySummary:
                return "notification.expedition.method.summary"
            case .forEachExpedition:
                return "notification.expedition.method.each"
            }
        }
    }

    public enum ManualNotificationSetting: Codable, _DefaultsSerializable {
        case disallowed
        case notifyAt(weekday: Int = 0, hour: Int, minute: Int)
    }
}

extension Defaults.Keys {
    /// Stamina, Toggle
    public static let allowStaminaNotification = Key<Bool>(
        "notificationSettings4StaminaToggle", default: true, suite: .baseSuite
    )

    /// Stamina, Additional Threshold
    public static let staminaAdditionalNotificationThresholds = Key<[Int]>(
        "notificationSettings4StaminaAdditionalThresholds", default: [190, 230], suite: .baseSuite
    )

    /// Expedition, Toggle
    public static let allowExpeditionNotification = Key<Bool>(
        "notificationSettings4ExpeditionsToggle", default: true, suite: .baseSuite
    )

    /// Expedition, Notification Method
    public static let expeditionNotificationSetting = Key<DailyNoteNotificationSetting.ExpeditionNotificationSetting>(
        "notificationSettings4Expeditions", default: .onlySummary, suite: .baseSuite
    )

    /// Daily Task, Notification TimeStamp (Daily)
    public static let dailyTaskNotificationSetting = Key<DailyNoteNotificationSetting.ManualNotificationSetting>(
        "notificationSettings4DailyTask", default: .notifyAt(hour: 19, minute: 0), suite: .baseSuite
    )

    /// Katheryne Daily Rewards, Notification TimeStamp (Daily)
    public static let giKatheryneNotificationSetting = Key<DailyNoteNotificationSetting.ManualNotificationSetting>(
        "notificationSettings4GIKatheryne", default: .notifyAt(hour: 19, minute: 0), suite: .baseSuite
    )

    /// Realm Currency (GI), Toggle // 可预知完成时间。
    public static let allowGIRealmCurrencyNotification = Key<Bool>(
        "notificationSettings4GIRealmCurrencyToggle", default: true, suite: .baseSuite
    )

    /// Parametric Transformer (GI), Toggle // 可预知完成时间。
    public static let allowGITransformerNotification = Key<Bool>(
        "notificationSettings4GITransformerToggle", default: true, suite: .baseSuite
    )

    /// Trounce Blossom (Weekly Bosses) (GI), Notification TimeStamp (Weekly)
    public static let giTrounceBlossomNotificationSetting = Key<DailyNoteNotificationSetting.ManualNotificationSetting>(
        "notificationSettings4GITrounceBlossom", default: .notifyAt(weekday: 7, hour: 19, minute: 0), suite: .baseSuite
    )

    /// Simulated Universe, Notification TimeStamp (Weekly)
    public static let hsrSimulUnivNotificationSetting = Key<DailyNoteNotificationSetting.ManualNotificationSetting>(
        "notificationSettings4HSRSimulUniv", default: .notifyAt(weekday: 7, hour: 19, minute: 0), suite: .baseSuite
    )
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

    func send() {
        Task { @MainActor in
            do {
                guard profile.allowNotification else { return }
                // STAMINA
                if Defaults[.allowStaminaNotification] {
                    try await scheduleStaminaFullNotification()
                    if case let .notifyAt(_, hour, minute) = Defaults[.giKatheryneNotificationSetting] {
                        try await scheduleGIKatheryneRewardsNotification(hour: hour, minute: minute)
                    }
                    // 去除可能重复的通知阈值。
                    var thresholds = Defaults[.staminaAdditionalNotificationThresholds]
                    thresholds = Array(Set(thresholds)).sorted()
                    for number in thresholds {
                        try await scheduleStaminaNotification(to: number)
                    }
                }
                // EXPEDITION
                if Defaults[.allowExpeditionNotification], dailyNote.hasExpeditions {
                    switch Defaults[.expeditionNotificationSetting] {
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
                if case let .notifyAt(_, hour, minute) = Defaults[.dailyTaskNotificationSetting] {
                    try await scheduleDailyTaskNotification(hour: hour, minute: minute)
                }
                // REALM CURRENCY (GI)
                if Defaults[.allowGIRealmCurrencyNotification] {
                    try await scheduleGIRealmCurrencyNotification()
                }
                // PARAMETRIC TRANSFORMER (GI)
                if Defaults[.allowGITransformerNotification] {
                    try await scheduleGITransformerNotification()
                }
                // TROUNCE BLOSSOM RESIN DISCOUNTS (GI)
                if case let .notifyAt(weekday, hour, minute) = Defaults[.giTrounceBlossomNotificationSetting] {
                    try await scheduleGITrounceBlossomNotification(
                        weekday: Swift.max(0, Swift.min(7, weekday)),
                        hour: hour,
                        minute: minute
                    )
                }
                // SIMULATED UNIVERSE (HSR)
                if case let .notifyAt(weekday, hour, minute) = Defaults[.hsrSimulUnivNotificationSetting] {
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
        type.rawValue + profile.uuid.uuidString + extraID
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
        content.title = String(
            format: String(localized: "notification.stamina.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.stamina.full.body:%@", bundle: .module),
            profile.name
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
        content.title = String(
            format: String(localized: "notification.stamina.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.stamina.customize.body:%@%@%@", bundle: .module),
            profile.name,
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

    /// 星穹铁道的话，恐仅对米游社帐号有效，因为国际服的星穹铁道的探索派遣没有预计完成时间。
    @MainActor
    private func scheduleExpeditionSummaryNotification() async throws {
        guard dailyNote.hasExpeditions else { return }
        guard let eta = dailyNote.expeditionTotalETA, eta.timeIntervalSinceNow > 0 else {
            await deleteNotification(.expeditionSummary)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(
            format: String(localized: "notification.expedition.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.expedition.summary.body:%@", bundle: .module),
            profile.name
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
        content.title = String(
            format: String(localized: "notification.expedition.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.expedition.each.body:%@%@", bundle: .module),
            profile.name,
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
        content.title = String(
            format: String(localized: "notification.dailyTask.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.dailyTask.body:%@%@%@", bundle: .module),
            profile.name,
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
        guard dailyNote.hasDailyTaskIntel else { return }
        let sitrep = dailyNote.dailyTaskCompletionStatus
        guard !sitrep.isAccomplished else {
            await deleteNotification(.giRewardsFromKatheryne)
            return
        }
        // 只有尚未领取时才提醒。
        guard dailyNote.claimedRewardsFromKatheryne ?? true else {
            await deleteNotification(.giRewardsFromKatheryne)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(
            format: String(localized: "notification.katheryneRewardsAvailable.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.katheryneRewardsAvailable.body:%@", bundle: .module),
            profile.name
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
        guard let eta = dailyNote.realmCurrencyIntel?.fullTime, eta.timeIntervalSinceNow > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = String(
            format: String(localized: "notification.realmCurrency.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.realmCurrency.body:%@", bundle: .module),
            profile.name
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
        guard let intel = dailyNote.parametricTransformerIntel else { return }
        guard intel.obtained else { return }
        let eta = intel.recoveryTime
        guard eta.timeIntervalSinceNow > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = String(
            format: String(localized: "notification.parametricTransformer.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.parametricTransformer.body:%@", bundle: .module),
            profile.name
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
        guard let trounceBlossom = dailyNote.trounceBlossomIntel else { return }
        guard trounceBlossom.remainResinDiscount > 0 else {
            await deleteNotification(.giTrounceBlossomResinDiscounts)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(
            format: String(localized: "notification.trounceBlossom.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.trounceBlossom.body:%@%@", bundle: .module),
            profile.name,
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

    /// 模拟宇宙。
    @MainActor
    private func scheduleHSRSimulatedUniverseNotification(weekday: Int, hour: Int, minute: Int) async throws {
        guard let simulatedUniverse = dailyNote.simulatedUniverseIntel else { return }
        guard simulatedUniverse.currentScore < simulatedUniverse.maxScore else {
            await deleteNotification(.hsrSimulatedUniverse)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = String(
            format: String(localized: "notification.simulatedUniverse.title:%@", bundle: .module),
            profile.name
        )
        content.body = String(
            format: String(localized: "notification.simulatedUniverse.body:%@%@%@", bundle: .module),
            profile.name,
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
