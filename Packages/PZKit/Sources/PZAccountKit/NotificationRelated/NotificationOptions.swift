// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZBaseKit
import SwiftUI

extension Defaults.Keys {
    public static let notificationOptions = Key<NotificationOptions>(
        "notificationOptions", default: .init(), suite: .baseSuite
    )
}

// MARK: - NotificationOptions

public struct NotificationOptions: Codable, Hashable, Sendable, _DefaultsSerializable {
    // MARK: Lifecycle

    public init() {}

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.allowStaminaNotification = try container.decode(Bool.self, forKey: .allowStaminaNotification)
        let readableThresholds = try? container.decode(
            [StaminaThreshold].self,
            forKey: .staminaAdditionalNotificationThresholds
        )
        if let readableThresholds {
            self.staminaAdditionalNotificationThresholds = readableThresholds
        }
        self.allowExpeditionNotification = try container.decode(Bool.self, forKey: .allowExpeditionNotification)
        self.expeditionNotificationSetting = try container.decode(
            ExpeditionNotificationSetting.self, forKey: .expeditionNotificationSetting
        )
        self.dailyTaskNotificationSetting = try container.decode(
            ManualSetting.self,
            forKey: .dailyTaskNotificationSetting
        )
        self.giKatheryneNotificationSetting = try container.decode(
            ManualSetting.self,
            forKey: .giKatheryneNotificationSetting
        )
        self.allowGIRealmCurrencyNotification = try container.decode(
            Bool.self,
            forKey: .allowGIRealmCurrencyNotification
        )
        self.allowGITransformerNotification = try container.decode(Bool.self, forKey: .allowGITransformerNotification)
        self.giTrounceBlossomNotificationSetting = try container.decode(
            ManualSetting.self,
            forKey: .giTrounceBlossomNotificationSetting
        )
        self.hsrSimulUnivNotificationSetting = try container.decode(
            ManualSetting.self,
            forKey: .hsrSimulUnivNotificationSetting
        )
    }

    // MARK: Public

    public enum ExpeditionNotificationSetting: String, CustomStringConvertible, CaseIterable, Sendable, Hashable,
        Codable {
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

    public enum ManualSetting: Codable, Sendable, Hashable {
        case disallowed
        case notifyAt(weekday: Int = 0, hour: Int, minute: Int)
    }

    public struct StaminaThreshold: Codable, Sendable, Hashable {
        // MARK: Lifecycle

        public init(game: Pizza.SupportedGame, threshold: Int) {
            self.game = game
            self.threshold = threshold
        }

        // MARK: Public

        public let game: Pizza.SupportedGame
        public let threshold: Int
    }

    /// Stamina, Toggle
    public var allowStaminaNotification: Bool = true {
        willSet {
            guard !newValue else { return }
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .staminaPerThreshold)
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .staminaFull)
            }
        }
    }

    /// Stamina, Additional Threshold (by Game)
    public var staminaAdditionalNotificationThresholds: [StaminaThreshold] = [
        StaminaThreshold(game: .genshinImpact, threshold: 190),
        StaminaThreshold(game: .starRail, threshold: 230),
        StaminaThreshold(game: .zenlessZone, threshold: 230),
    ] {
        willSet {
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .staminaPerThreshold)
            }
        }
    }

    /// Expedition, Toggle
    public var allowExpeditionNotification: Bool = true {
        willSet {
            guard !newValue else { return }
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .expeditionEach)
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .expeditionSummary)
            }
        }
    }

    /// Expedition, Notification Method
    public var expeditionNotificationSetting: ExpeditionNotificationSetting = .onlySummary {
        willSet {
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(
                    of: newValue == .forEachExpedition ? .expeditionSummary : .expeditionEach
                )
            }
        }
    }

    /// Daily Task, Notification TimeStamp (Daily)
    public var dailyTaskNotificationSetting: ManualSetting = .notifyAt(hour: 19, minute: 0) {
        willSet {
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .dailyTask)
            }
        }
    }

    /// Katheryne Daily Rewards, Notification TimeStamp (Daily)
    public var giKatheryneNotificationSetting: ManualSetting = .notifyAt(hour: 19, minute: 0) {
        willSet {
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .giRewardsFromKatheryne)
            }
        }
    }

    /// Realm Currency (GI), Toggle // 可预知完成时间。
    public var allowGIRealmCurrencyNotification: Bool = true {
        willSet {
            guard !newValue else { return }
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .giRealmCurrency)
            }
        }
    }

    /// Parametric Transformer (GI), Toggle // 可预知完成时间。
    public var allowGITransformerNotification: Bool = true {
        willSet {
            guard !newValue else { return }
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .giParametricTransformer)
            }
        }
    }

    /// Trounce Blossom (Weekly Bosses) (GI), Notification TimeStamp (Weekly)
    public var giTrounceBlossomNotificationSetting: ManualSetting = .notifyAt(weekday: 7, hour: 19, minute: 0) {
        willSet {
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .giTrounceBlossomResinDiscounts)
            }
        }
    }

    /// Simulated Universe, Notification TimeStamp (Weekly)
    public var hsrSimulUnivNotificationSetting: ManualSetting = .notifyAt(weekday: 7, hour: 19, minute: 0) {
        willSet {
            Task {
                try? await PZNotificationCenter.deleteDailyNoteNotification(of: .hsrSimulatedUniverse)
            }
        }
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case allowStaminaNotification
        case staminaAdditionalNotificationThresholds
        case allowExpeditionNotification
        case expeditionNotificationSetting
        case dailyTaskNotificationSetting
        case giKatheryneNotificationSetting
        case allowGIRealmCurrencyNotification
        case allowGITransformerNotification
        case giTrounceBlossomNotificationSetting
        case hsrSimulUnivNotificationSetting
    }
}

extension [NotificationOptions.StaminaThreshold] {
    public func byGame(_ game: Pizza.SupportedGame) -> Self {
        filter { $0.game == game }.sorted { $0.threshold < $1.threshold }
    }
}

// MARK: - Binding Generators

extension NotificationOptions {
    private static var shared: NotificationOptions {
        get {
            Defaults[.notificationOptions]
        }
        set {
            Defaults[.notificationOptions] = newValue
        }
    }

    public var dailyTaskNotificationTime: Binding<Date?> {
        Binding<Date?>(
            get: {
                switch Self.shared.dailyTaskNotificationSetting {
                case let .notifyAt(_, hour, minute):
                    return Calendar.current.nextDate(
                        after: Date.now,
                        matching: DateComponents(hour: hour, minute: minute),
                        matchingPolicy: .nextTime
                    )!
                case .disallowed:
                    return nil
                }
            },
            set: { date in
                guard let date else { return }
                let hours = Calendar.autoupdatingCurrent.component(.hour, from: date)
                let mins = Calendar.autoupdatingCurrent.component(.minute, from: date)
                Self.shared.dailyTaskNotificationSetting = .notifyAt(hour: hours, minute: mins)
            }
        )
    }

    public var allowDailyTaskNotification: Binding<Bool> {
        .init {
            if case .disallowed = Self.shared.dailyTaskNotificationSetting {
                return false
            } else {
                return true
            }
        } set: { newValue in
            if !newValue {
                Self.shared.dailyTaskNotificationSetting = .disallowed
            } else {
                Self.shared.dailyTaskNotificationSetting = Self().dailyTaskNotificationSetting
            }
        }
    }

    public var giKatheryneNotificationTime: Binding<Date?> {
        Binding<Date?>(
            get: {
                switch Self.shared.giKatheryneNotificationSetting {
                case let .notifyAt(_, hour, minute):
                    return Calendar.current.nextDate(
                        after: Date.now,
                        matching: DateComponents(hour: hour, minute: minute),
                        matchingPolicy: .nextTime
                    )!
                case .disallowed:
                    return nil
                }
            },
            set: { date in
                if let date {
                    let hours = Calendar.autoupdatingCurrent.component(.hour, from: date)
                    let mins = Calendar.autoupdatingCurrent.component(.minute, from: date)
                    Self.shared.giKatheryneNotificationSetting = .notifyAt(hour: hours, minute: mins)
                }
            }
        )
    }

    public var allowGIKatheryneNotification: Binding<Bool> {
        .init {
            if case .disallowed = Self.shared.giKatheryneNotificationSetting {
                return false
            } else {
                return true
            }
        } set: { newValue in
            if !newValue {
                Self.shared.giKatheryneNotificationSetting = .disallowed
            } else {
                Self.shared.giKatheryneNotificationSetting = Self().giKatheryneNotificationSetting
            }
        }
    }

    public var hsrSimulUnivNotificationTime: Binding<Date?> {
        .init {
            switch Self.shared.hsrSimulUnivNotificationSetting {
            case let .notifyAt(weekday: _, hour: hour, minute: minute):
                return Calendar.current.nextDate(
                    after: Date(),
                    matching: DateComponents(hour: hour, minute: minute),
                    matchingPolicy: .nextTime
                )!
            case .disallowed:
                return nil
            }
        } set: { date in
            guard let date else { return }
            switch Self.shared.hsrSimulUnivNotificationSetting {
            case let .notifyAt(weekday: weekday, hour: _, minute: _):
                let hours = Calendar.autoupdatingCurrent.component(.hour, from: date)
                let mins = Calendar.autoupdatingCurrent.component(.minute, from: date)
                Self.shared.hsrSimulUnivNotificationSetting = .notifyAt(
                    weekday: weekday,
                    hour: hours,
                    minute: mins
                )
            case .disallowed:
                break
            }
        }
    }

    public var hsrSimulUnivNotificationWeekday: Binding<Weekday?> {
        .init {
            switch Self.shared.hsrSimulUnivNotificationSetting {
            case let .notifyAt(weekday: weekday, hour: _, minute: _):
                return Weekday(rawValue: weekday)
            case .disallowed:
                return nil
            }
        } set: { weekday in
            guard let weekday else { return }
            switch Self.shared.hsrSimulUnivNotificationSetting {
            case let .notifyAt(weekday: _, hour: hour, minute: minute):
                Self.shared.hsrSimulUnivNotificationSetting = .notifyAt(
                    weekday: weekday.rawValue,
                    hour: hour,
                    minute: minute
                )
            case .disallowed:
                break
            }
        }
    }

    public var allowHSRSimulUnivNotification: Binding<Bool> {
        .init {
            if case .disallowed = Self.shared.hsrSimulUnivNotificationSetting {
                return false
            } else {
                return true
            }
        } set: { newValue in
            if !newValue {
                Self.shared.hsrSimulUnivNotificationSetting = .disallowed
            } else {
                Self.shared.hsrSimulUnivNotificationSetting = Self().hsrSimulUnivNotificationSetting
            }
        }
    }

    public var giTrounceBlossomNotificationTime: Binding<Date?> {
        .init {
            switch Self.shared.giTrounceBlossomNotificationSetting {
            case let .notifyAt(weekday: _, hour: hour, minute: minute):
                return Calendar.current.nextDate(
                    after: Date(),
                    matching: DateComponents(hour: hour, minute: minute),
                    matchingPolicy: .nextTime
                )!
            case .disallowed:
                return nil
            }
        } set: { date in
            guard let date else { return }
            switch Self.shared.giTrounceBlossomNotificationSetting {
            case let .notifyAt(weekday: weekday, hour: _, minute: _):
                let hours = Calendar.autoupdatingCurrent.component(.hour, from: date)
                let mins = Calendar.autoupdatingCurrent.component(.minute, from: date)
                Self.shared.giTrounceBlossomNotificationSetting = .notifyAt(
                    weekday: weekday,
                    hour: hours,
                    minute: mins
                )
            case .disallowed:
                break
            }
        }
    }

    public var giTrounceBlossomNotificationWeekday: Binding<Weekday?> {
        .init {
            switch Self.shared.giTrounceBlossomNotificationSetting {
            case let .notifyAt(weekday: weekday, hour: _, minute: _):
                return Weekday(rawValue: weekday)
            case .disallowed:
                return nil
            }
        } set: { weekday in
            guard let weekday else { return }
            switch Self.shared.giTrounceBlossomNotificationSetting {
            case let .notifyAt(weekday: _, hour: hour, minute: minute):
                Self.shared.giTrounceBlossomNotificationSetting = .notifyAt(
                    weekday: weekday.rawValue,
                    hour: hour,
                    minute: minute
                )
            case .disallowed:
                break
            }
        }
    }

    public var allowGITrounceBlossomNotification: Binding<Bool> {
        .init {
            if case .disallowed = Self.shared.giTrounceBlossomNotificationSetting {
                return false
            } else {
                return true
            }
        } set: { newValue in
            if !newValue {
                Self.shared.giTrounceBlossomNotificationSetting = .disallowed
            } else {
                Self.shared.giTrounceBlossomNotificationSetting = Self().hsrSimulUnivNotificationSetting
            }
        }
    }
}
