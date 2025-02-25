// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import ActivityKit
#endif
import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - EnableLiveActivityButton

public struct EnableLiveActivityButton: View {
    // MARK: Lifecycle

    public init?(for profile: PZProfileSendable, dailyNote: any DailyNoteProtocol) {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        self.account = profile
        self.dailyNote = dailyNote
        #else
        return nil
        #endif
    }

    // MARK: Public

    public var body: some View {
        Button {
            do {
                try ResinRecoveryActivityController.shared.createResinRecoveryTimerActivity(
                    for: account,
                    data: dailyNote
                )
            } catch {
                self.error = .otherError(error)
                showErrorAlert.toggle()
            }
        } label: {
            Text("app.dailynote.initiateLiveActivity", bundle: .module)
        }
        .alert(isPresented: $showErrorAlert, error: error) {
            Button("sys.cancel".i18nBaseKit) {
                showErrorAlert.toggle()
            }
        }
    }

    // MARK: Private

    @State private var error: AnyLocalizedError?
    @State private var showErrorAlert: Bool = false

    private let account: PZProfileSendable
    private let dailyNote: any DailyNoteProtocol
}

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
extension ResinRecoveryAttributes: ActivityAttributes {}
#endif

// MARK: - ResinRecoveryActivityBackground

public enum ResinRecoveryActivityBackground: Codable, Equatable, Hashable, Sendable {
    case random
    case customize([String])
    case noBackground
}

// MARK: - ResinRecoveryAttributes

public struct ResinRecoveryAttributes: Sendable {
    public typealias ResinRecoveryState = ContentState

    public struct ContentState: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            dailyNote: any DailyNoteProtocol,
            showExpedition: Bool,
            background: ResinRecoveryActivityBackground
        ) {
            self.background = background
            self.primaryStaminaRecoverySpeed = dailyNote.eachStaminaRecoveryTime
            self.staminaCompletionStatus = dailyNote.staminaIntel
            self.primaryStaminaRecoveryTime = dailyNote.staminaFullTimeOnFinish
            self.game = dailyNote.game
            // Expeditions.
            self.showExpedition = !(dailyNote is Note4ZZZ) && showExpedition
            if showExpedition {
                let maxTime = dailyNote.expeditionTotalETA
                self.expeditionAllCompleteTime = maxTime ?? .now
            } else {
                self.expeditionAllCompleteTime = nil
            }
        }

        // MARK: Public

        public let game: Pizza.SupportedGame
        public let staminaCompletionStatus: FieldCompletionIntel<Int>
        public let primaryStaminaRecoverySpeed: TimeInterval
        public let primaryStaminaRecoveryTime: Date
        public let expeditionAllCompleteTime: Date?
        public let showExpedition: Bool
        public let background: ResinRecoveryActivityBackground
    }

    public let accountName: String
    public let accountUUID: UUID
}

extension ResinRecoveryAttributes.ResinRecoveryState {
    public var maxPrimaryStamina: Int { staminaCompletionStatus.all }

    public var currentPrimaryStamina: Int {
        let secondRemaining = primaryStaminaRecoveryTime.timeIntervalSinceReferenceDate - Date()
            .timeIntervalSinceReferenceDate
        let minuteRemaining = Double(secondRemaining) / 60
        let currentResin: Int
        if minuteRemaining <= 0 {
            currentResin = maxPrimaryStamina
        } else {
            currentResin = maxPrimaryStamina - Int(ceil(minuteRemaining / 8))
        }
        return currentResin
    }

    /// 下一20倍数树脂
    public var next20PrimaryStamina: Int {
        Int(ceil((Double(currentPrimaryStamina) + 0.01) / 20.0)) * 20
    }

    public var showNext20PrimaryStamina: Bool {
        staminaCompletionStatus.all - staminaCompletionStatus.finished >= 20
    }

    /// 下一20倍数树脂回复时间点
    public var next20PrimaryStaminaRecoveryTime: Date {
        Date(
            timeIntervalSinceNow: TimeInterval(
                Double(next20PrimaryStamina - currentPrimaryStamina) * primaryStaminaRecoverySpeed
            )
        )
    }
}

// MARK: - ResinRecoveryActivityController

public final class ResinRecoveryActivityController: Sendable {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static let shared: ResinRecoveryActivityController = .init()

    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
    public var currentActivities: [Activity<ResinRecoveryAttributes>] {
        Activity<ResinRecoveryAttributes>.activities
    }
    #endif

    public var allowLiveActivity: Bool {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        return ActivityAuthorizationInfo().areActivitiesEnabled
        #else
        return false
        #endif
    }

    public static func backgroundSettingsSanityCheck() {
        let backgrounds = Defaults[.backgrounds4LiveActivity].map(\.assetName4LiveActivity)
        guard !backgrounds.isEmpty else { return }
        let allValidValues = Wallpaper.allCases.map(\.assetName4LiveActivity)
        for entry in backgrounds {
            guard !allValidValues.contains(entry) else { continue }
            // 之前的剔除方法无效，现在改了判定规则：
            // 只要发现不合规的 UserDefault 资料，那就全部清空。
            Defaults[.backgrounds4LiveActivity].removeAll()
            return
        }
    }

    public func getBackground(for game: Pizza.SupportedGame? = nil) -> ResinRecoveryActivityBackground {
        if Defaults[.resinRecoveryLiveActivityUseEmptyBackground] {
            return .noBackground
        } else if !Defaults[.resinRecoveryLiveActivityUseCustomizeBackground] {
            return .random
        } else {
            Self.backgroundSettingsSanityCheck()
            var backgrounds = Defaults[.backgrounds4LiveActivity].map(\.assetName4LiveActivity)
            if backgrounds.isEmpty {
                backgrounds = [Wallpaper.defaultValue(for: game).assetName4LiveActivity]
            }
            if backgrounds.isEmpty {
                backgrounds = [Wallpaper.defaultValue(for: nil).assetName4LiveActivity]
            }
            return .customize(backgrounds)
        }
    }

    public func createResinRecoveryTimerActivity(for profile: PZProfileSendable, data: some DailyNoteProtocol) throws {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        guard allowLiveActivity else {
            throw CreateLiveActivityError.notAllowed
        }
        let accountName = profile.name
        let accountUUID: UUID = profile.uuid

        guard !currentActivities.map({ $0.attributes.accountUUID })
            .contains(accountUUID) else {
            updateResinRecoveryTimerActivity(for: profile, data: data)
            return
        }
        let attributes: ResinRecoveryAttributes = .init(
            accountName: accountName,
            accountUUID: accountUUID
        )
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
            dailyNote: data,
            showExpedition: Defaults[.resinRecoveryLiveActivityShowExpedition],
            background: getBackground(for: profile.game)
        )

        print(status.currentPrimaryStamina)
        print(status.next20PrimaryStamina)
        print(status.showNext20PrimaryStamina)
        print(status.next20PrimaryStaminaRecoveryTime)

        do {
            let deliveryActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: status, staleDate: .now.adding(seconds: 360))
            )
            print("request activity succeed ID=\(deliveryActivity.id)")
            Task {
                for await state in deliveryActivity.activityStateUpdates {
                    print(state)
                }
            }
        } catch {
            print(
                "Error requesting pizza delivery Live Activity \(error.localizedDescription)."
            )
            throw CreateLiveActivityError
                .otherError(error.localizedDescription)
        }
        #endif
    }

    public func updateResinRecoveryTimerActivity(for profile: PZProfileSendable, data: some DailyNoteProtocol) {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        Task {
            let filtered = currentActivities.filter { activity in
                activity.attributes.accountUUID == profile.uuid
            }

            for activity in filtered {
                if Date.now >= data.staminaFullTimeOnFinish {
                    endActivity(for: profile)
                    continue
                }
                let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
                    dailyNote: data,
                    showExpedition: Defaults[.resinRecoveryLiveActivityShowExpedition],
                    background: getBackground(for: profile.game)
                )

                await activity.update(
                    ActivityContent<Activity<ResinRecoveryAttributes>.ContentState>(
                        state: status, staleDate: Date.now.adding(seconds: 360)
                    )
                )
            }
        }
        #endif
    }

    public func endActivity(for account: PZProfileSendable) {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        Task {
            let filtered = currentActivities.filter { activity in
                activity.attributes.accountUUID == account.uuid
            }
            for activity in filtered {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
        #endif
    }

    public func endAllActivity() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        Task {
            for activity in currentActivities {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
        #endif
    }
}

// MARK: - CreateLiveActivityError

public enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
    case noInfo
}

// MARK: LocalizedError

extension CreateLiveActivityError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notAllowed:
            return .init(localized: errorDescriptionKeys, bundle: .module)
        case .noInfo:
            return .init(localized: errorDescriptionKeys, bundle: .module)
        case let .otherError(message):
            return String(format: .init(localized: errorDescriptionKeys, bundle: .module), message)
        }
    }

    private var errorDescriptionKeys: String.LocalizationValue {
        switch self {
        case .notAllowed:
            return "pzAccountKit.CreateLiveActivityError.systemSettings"
        case .noInfo:
            return "pzAccountKit.CreateLiveActivityError.noInfo"
        case .otherError:
            return "pzAccountKit.CreateLiveActivityError.unknown:%@"
        }
    }
}
