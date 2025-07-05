// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
import ActivityKit
#endif
import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - EnableLiveActivityButton

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public struct EnableLiveActivityButton: View {
    // MARK: Lifecycle

    public init?(for profile: PZProfileSendable, dailyNote: any DailyNoteProtocol) {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        self.profile = profile
        self.dailyNote = dailyNote
        #else
        return nil
        #endif
    }

    // MARK: Public

    public var body: some View {
        Button {
            do {
                try StaminaLiveActivityController.shared.createResinRecoveryTimerActivity(
                    for: profile,
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

    private let profile: PZProfileSendable
    private let dailyNote: any DailyNoteProtocol
}

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension LiveActivityAttributes: ActivityAttributes {}
#endif

// MARK: - LiveActivityAttributes

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public struct LiveActivityAttributes: Sendable {
    public typealias LiveActivityState = ContentState

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
    public struct ContentState: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            dailyNote: any DailyNoteProtocol,
            showExpedition: Bool
        ) {
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
    }

    public let profileName: String
    public let profileUUID: UUID
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension LiveActivityAttributes.LiveActivityState {
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

// MARK: - StaminaLiveActivityController

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public final class StaminaLiveActivityController: Sendable {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static let shared: StaminaLiveActivityController = .init()

    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
    public var currentActivities: [Activity<LiveActivityAttributes>] {
        Activity<LiveActivityAttributes>.activities
    }
    #endif

    public var allowLiveActivity: Bool {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        return ActivityAuthorizationInfo().areActivitiesEnabled
        #else
        return false
        #endif
    }

    public func createResinRecoveryTimerActivity(for profile: PZProfileSendable, data: some DailyNoteProtocol) throws {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        guard allowLiveActivity else {
            throw CreateLiveActivityError.notAllowed
        }
        let profileName = profile.name
        let profileUUID: UUID = profile.uuid

        guard !currentActivities.map({ $0.attributes.profileUUID })
            .contains(profileUUID) else {
            updateResinRecoveryTimerActivity(for: profile, data: data)
            return
        }
        let attributes: LiveActivityAttributes = .init(
            profileName: profileName,
            profileUUID: profileUUID
        )
        let status: LiveActivityAttributes.LiveActivityState = .init(
            dailyNote: data,
            showExpedition: Defaults[.showExpeditionInLiveActivity]
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
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        Task {
            let filtered = currentActivities.filter { activity in
                activity.attributes.profileUUID == profile.uuid
            }

            for activity in filtered {
                if Date.now >= data.staminaFullTimeOnFinish {
                    endActivity(for: profile)
                    continue
                }
                let status: LiveActivityAttributes.LiveActivityState = .init(
                    dailyNote: data,
                    showExpedition: Defaults[.showExpeditionInLiveActivity]
                )

                await activity.update(
                    ActivityContent<Activity<LiveActivityAttributes>.ContentState>(
                        state: status, staleDate: Date.now.adding(seconds: 360)
                    )
                )
            }
        }
        #endif
    }

    public func endActivity(for profile: PZProfileSendable) {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        Task {
            let filtered = currentActivities.filter { activity in
                activity.attributes.profileUUID == profile.uuid
            }
            for activity in filtered {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
        #endif
    }

    public func endAllActivity() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
        Task {
            for activity in currentActivities {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
        #endif
    }
}

// MARK: - CreateLiveActivityError

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
    case noInfo
}

// MARK: LocalizedError

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
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
            return "pzWidgetsKit.CreateLiveActivityError.systemSettings"
        case .noInfo:
            return "pzWidgetsKit.CreateLiveActivityError.noInfo"
        case .otherError:
            return "pzWidgetsKit.CreateLiveActivityError.unknown:%@"
        }
    }
}
