// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit)
import ActivityKit
#endif
@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - EnableLiveActivityButton

public struct EnableLiveActivityButton: View {
    // MARK: Lifecycle

    public init?(for profile: PZProfileSendable, dailyNote: any DailyNoteProtocol) {
        #if canImport(ActivityKit)
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

    private let account: PZProfileSendable
    private let dailyNote: any DailyNoteProtocol

    @State private var error: AnyLocalizedError?
    @State private var showErrorAlert: Bool = false
}

#if canImport(ActivityKit)
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

    public struct ContentState: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(
            dailyNote: any DailyNoteProtocol,
            showExpedition: Bool,
            background: ResinRecoveryActivityBackground
        ) {
            self.background = background
            let staminaIntel = dailyNote.staminaIntel
            self.maxResin = staminaIntel.max
            self.resinCountWhenUpdated = staminaIntel.existing
            self.resinRecoveryTime = dailyNote.staminaFullTimeOnFinish
            self.game = dailyNote.game
            switch dailyNote {
            case _ as WidgetNote4GI:
                self.expeditionAllCompleteTime = nil
                self.showExpedition = showExpedition
            case let data as GeneralNote4GI:
                self.expeditionAllCompleteTime = data.expeditions.expeditions.map(\.finishTime).max() ?? .now
                self.showExpedition = showExpedition
            case let data as Note4HSR:
                self.expeditionAllCompleteTime = data.assignmentInfo.assignments.map(\.finishedTime).max() ?? .now
                self.showExpedition = showExpedition
            case _ as Note4ZZZ:
                self.showExpedition = false
                self.expeditionAllCompleteTime = nil
            default:
                self.showExpedition = false
                self.expeditionAllCompleteTime = nil
            }
        }

        // MARK: Public

        public let game: Pizza.SupportedGame
        public let resinCountWhenUpdated: Int
        public let resinRecoveryTime: Date
        public let expeditionAllCompleteTime: Date?
        public let showExpedition: Bool
        public let maxResin: Int

        public let background: ResinRecoveryActivityBackground
    }

    public let accountName: String
    public let accountUUID: UUID
}

extension ResinRecoveryAttributes.ResinRecoveryState {
    public var currentResin: Int {
        let secondRemaining = resinRecoveryTime.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
        let minuteRemaining = Double(secondRemaining) / 60
        let currentResin: Int
        if minuteRemaining <= 0 {
            currentResin = maxResin
        } else {
            currentResin = maxResin - Int(ceil(minuteRemaining / 8))
        }
        return currentResin
    }

    /// 下一20倍数树脂
    public var next20ResinCount: Int {
        Int(ceil((Double(currentResin) + 0.01) / 20.0)) * 20
    }

    public var showNext20Resin: Bool {
        next20ResinCount != maxResin
    }

    /// 下一20倍数树脂回复时间点
    public var next20ResinRecoveryTime: Date {
        Date(timeIntervalSinceNow: TimeInterval((next20ResinCount - currentResin) * 8 * 60))
    }
}

// MARK: - ResinRecoveryActivityController

public final class ResinRecoveryActivityController: Sendable {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static let shared: ResinRecoveryActivityController = .init()

    #if canImport(ActivityKit)
    public var currentActivities: [Activity<ResinRecoveryAttributes>] {
        Activity<ResinRecoveryAttributes>.activities
    }
    #endif

    public var allowLiveActivity: Bool {
        #if canImport(ActivityKit)
        return ActivityAuthorizationInfo().areActivitiesEnabled
        #else
        return false
        #endif
    }

    public var background: ResinRecoveryActivityBackground {
        if Defaults[.resinRecoveryLiveActivityUseEmptyBackground] {
            return .noBackground
        } else if !Defaults[.resinRecoveryLiveActivityUseCustomizeBackground] {
            return .random
        } else {
            Self.backgroundSettingsSanityCheck()
            let backgrounds = Defaults[.backgrounds4LiveActivity].map(\.assetName4LiveActivity)
            if backgrounds.isEmpty {
                return .customize([Wallpaper.defaultValue(for: nil).assetName4LiveActivity])
            } else {
                return .customize(backgrounds)
            }
        }
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

    public func createResinRecoveryTimerActivity(for account: PZProfileSendable, data: some DailyNoteProtocol) throws {
        #if canImport(ActivityKit)
        guard allowLiveActivity else {
            throw CreateLiveActivityError.notAllowed
        }
        let accountName = account.name
        let accountUUID: UUID = account.uuid

        guard !currentActivities.map({ $0.attributes.accountUUID })
            .contains(accountUUID) else {
            updateResinRecoveryTimerActivity(for: account, data: data)
            return
        }
        let attributes: ResinRecoveryAttributes = .init(
            accountName: accountName,
            accountUUID: accountUUID
        )
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
            dailyNote: data,
            showExpedition: Defaults[.resinRecoveryLiveActivityShowExpedition],
            background: background
        )

        print(status.currentResin)
        print(status.next20ResinCount)
        print(status.showNext20Resin)
        print(status.next20ResinRecoveryTime)

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
//            Task {
//                if #available(iOSApplicationExtension 16.2, *) {
//                    for await content in deliveryActivity.contentUpdates {
//                        print(content)
//                    }
//                }
//            }

        } catch {
            print(
                "Error requesting pizza delivery Live Activity \(error.localizedDescription)."
            )
            throw CreateLiveActivityError
                .otherError(error.localizedDescription)
        }
        #endif
    }

    public func updateResinRecoveryTimerActivity(for account: PZProfileSendable, data: some DailyNoteProtocol) {
        #if canImport(ActivityKit)
        Task {
            let filtered = currentActivities.filter { activity in
                activity.attributes.accountUUID == account.uuid
            }

            for activity in filtered {
                if Date.now >= data.staminaFullTimeOnFinish {
                    endActivity(for: account)
                    continue
                }
                let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
                    dailyNote: data,
                    showExpedition: Defaults[.resinRecoveryLiveActivityShowExpedition],
                    background: background
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
        #if canImport(ActivityKit)
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
        #if canImport(ActivityKit)
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
