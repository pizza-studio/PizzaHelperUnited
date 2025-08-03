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

@available(iOS 16.2, macCatalyst 16.2, *)
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
            Task { @MainActor in
                do {
                    try await StaminaLiveActivityController.shared.createResinRecoveryTimerActivity(
                        for: profile,
                        data: dailyNote
                    )
                } catch {
                    self.error = .otherError(error)
                    showErrorAlert.toggle()
                }
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
@available(iOS 16.2, macCatalyst 16.2, *)
extension LiveActivityAttributes: ActivityAttributes {}
#endif

// MARK: - LiveActivityAttributes

@available(iOS 16.2, macCatalyst 16.2, *)
public struct LiveActivityAttributes: Sendable {
    public typealias LiveActivityState = ContentState

    @available(iOS 16.2, macCatalyst 16.2, *)
    public struct ContentState: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            dailyNote: any DailyNoteProtocol,
            showExpedition: Bool
        ) async {
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
            let wpConf = LiveActivityBackgroundValueParsed(Defaults[.liveActivityWallpaperIDs])
            if wpConf.useEmptyBackground {
                self.wallpaperID = nil
            } else if wpConf.useRandomBackground {
                self.wallpaperID = WidgetBackground.randomWallpaperBackground4Game(dailyNote.game).id
                // 此时 realWPs 必为空。
            } else {
                let realWPs = wpConf.liveActivityWallpaperIDsReal // 必不为空。
                self.wallpaperID = realWPs.randomElement() ?? realWPs[realWPs.startIndex]
            }
            wpCacheHandling: if let wpID = wallpaperID {
                guard let wpMatched = Wallpaper(id: wpID) else { break wpCacheHandling }
                guard case let .bundled(bundledWP) = wpMatched else { break wpCacheHandling }
                await bundledWP.saveOnlineBackgroundAsset()
            }
        }

        // MARK: Public

        public let game: Pizza.SupportedGame
        public let wallpaperID: String?
        public let staminaCompletionStatus: FieldCompletionIntel<Int>
        public let primaryStaminaRecoverySpeed: TimeInterval
        public let primaryStaminaRecoveryTime: Date
        public let expeditionAllCompleteTime: Date?
        public let showExpedition: Bool
    }

    public let profileName: String
    public let profileUUID: UUID
}

@available(iOS 16.2, macCatalyst 16.2, *)
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
        let result = Date(
            timeIntervalSinceNow: TimeInterval(
                Double(next20PrimaryStamina - currentPrimaryStamina) * primaryStaminaRecoverySpeed
            )
        )
        return Swift.min(primaryStaminaRecoveryTime, result)
    }
}

// MARK: - StaminaLiveActivityController

@available(iOS 16.2, macCatalyst 16.2, *)
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

    @MainActor
    public func createResinRecoveryTimerActivity(
        for profile: PZProfileSendable,
        data: some DailyNoteProtocol
    ) async throws {
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
        let status: LiveActivityAttributes.LiveActivityState = await .init(
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
                let status: LiveActivityAttributes.LiveActivityState = await .init(
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

@available(iOS 16.2, macCatalyst 16.2, *)
public enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
    case noInfo
}

// MARK: LocalizedError

@available(iOS 16.2, macCatalyst 16.2, *)
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
