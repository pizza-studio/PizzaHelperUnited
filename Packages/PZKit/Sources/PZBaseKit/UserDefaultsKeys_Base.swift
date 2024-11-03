// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
@preconcurrency import Foundation

extension UserDefaults {
    // 此处的 suiteName 得与 container ID 一致。
    public static let baseSuite = UserDefaults(suiteName: appGroupID) ?? .standard
}

extension Defaults.Keys {
    /// App UI language. At least, this works with macOS. This must use the standard container.
    public static let appLanguage = Key<[String]?>(
        AppLanguage.defaultsKeyName,
        default: nil,
        suite: .standard
    )

    /// Remembering the most-recent tab index.
    public static let appTabIndex = Key<Int>(
        "appTabIndex",
        default: 0,
        suite: .baseSuite
    )

    /// Remembering the most-recent tab index.
    public static let restoreTabOnLaunching = Key<Bool>(
        "restoreTabOnLaunching",
        default: true,
        suite: .baseSuite
    )

    /// User-Specified Wanderer's name.
    public static let customizedNameForWanderer = Key<String>(
        "customizedNameForWanderer",
        default: .init(),
        suite: .baseSuite
    )

    /// 是否强制修复指定语言下的某些角色跟物品的名称用字。
    /// 该选项仅对中文介面可见。
    public static let forceCharacterWeaponNameFixed = Key<Bool>(
        "forceCharacterWeaponNameFixed",
        default: true,
        suite: .baseSuite
    )

    /// Whether displaying real names for certain characters, not affecting SRGF imports & exports.
    public static let useRealCharacterNames = Key<Bool>(
        "useRealCharacterNames",
        default: true,
        suite: .baseSuite
    )

    public static let defaultServer = Key<String>(
        "defaultServer",
        default: "os_asia",
        suite: .baseSuite
    )
}

// MARK: - MainWidgetProvider

extension Defaults.Keys {
    public static let allWidgetSyncFrequencyByMinutes = Key<Double>(
        "allWidgetSyncFrequencyByMinutes",
        default: 15,
        suite: .baseSuite
    )
}

// MARK: - ResinRecoveryActivityController

extension Defaults.Keys {
    public static let autoDeliveryResinTimerLiveActivity = Key<Bool>(
        "autoDeliveryResinTimerLiveActivity",
        default: false,
        suite: .baseSuite
    )
    public static let resinRecoveryLiveActivityShowExpedition = Key<Bool>(
        "resinRecoveryLiveActivityShowExpedition",
        default: true,
        suite: .baseSuite
    )
    public static let resinRecoveryLiveActivityBackgroundOptions =
        Key<[String]>("resinRecoveryLiveActivityBackgroundOptions", default: .init(), suite: .baseSuite)
    public static let autoUpdateResinRecoveryTimerUsingReFetchData =
        Key<Bool>("autoUpdateResinRecoveryTimerUsingReFetchData", default: true, suite: .baseSuite)
    public static let resinRecoveryLiveActivityUseEmptyBackground =
        Key<Bool>("resinRecoveryLiveActivityUseEmptyBackground", default: false, suite: .baseSuite)
    public static let resinRecoveryLiveActivityUseCustomizeBackground =
        Key<Bool>("resinRecoveryLiveActivityUseCustomizeBackground", default: false, suite: .baseSuite)
}

// MARK: - UserNotificationCenter

extension Defaults.Keys {
    public static let allowResinNotification = Key<Bool>("allowResinNotification", default: true, suite: .baseSuite)
    // 得保留「resinNotificationNum」原始 rawValue 命名，不然无法继承用户既有设定。
    public static let resinNotificationThreshold = Key<Double>(
        "resinNotificationNum",
        default: 180,
        suite: .baseSuite
    )
    public static let allowFullResinNotification = Key<Bool>(
        "allowFullResinNotification",
        default: true,
        suite: .baseSuite
    )
    public static let allowHomeCoinNotification = Key<Bool>(
        "allowHomeCoinNotification",
        default: true,
        suite: .baseSuite
    )
    public static let homeCoinNotificationHourBeforeFull = Key<Double>(
        "homeCoinNotificationHourBeforeFull",
        default: 8,
        suite: .baseSuite
    )
    public static let allowExpeditionNotification = Key<Bool>(
        "allowExpeditionNotification",
        default: true,
        suite: .baseSuite
    )
    public static let noticeExpeditionMethodRawValue = Key<Int>(
        "noticeExpeditionMethodRawValue",
        default: 1,
        suite: .baseSuite
    )
    public static let allowWeeklyBossesNotification = Key<Bool>(
        "allowWeeklyBossesNotification",
        default: true,
        suite: .baseSuite
    )
    public static let allowTransformerNotification = Key<Bool>(
        "allowTransformerNotification",
        default: true,
        suite: .baseSuite
    )
    public static let allowDailyTaskNotification = Key<Bool>(
        "allowDailyTaskNotification",
        default: true,
        suite: .baseSuite
    )

    public static let weeklyBossesNotificationTimePointData = Key<Data>(
        "weeklyBossesNotificationTimePointData",
        default: try! JSONEncoder().encode(DateComponents(
            calendar: Calendar.current,
            hour: 19,
            minute: 0,
            weekday: 7
        )),
        suite: .baseSuite
    )

    public static let dailyTaskNotificationTimePointData = Key<Data>(
        "dailyTaskNotificationTimePointData",
        default: try! JSONEncoder().encode(DateComponents(calendar: Calendar.current, hour: 19, minute: 0)),
        suite: .baseSuite
    )

    public static let notificationIgnoreUidsData = Key<Data>(
        "notificationIgnoreUidsData",
        default: try! JSONEncoder().encode([String]()),
        suite: .baseSuite
    )
}
