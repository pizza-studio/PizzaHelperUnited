// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit)
import ActivityKit
@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import WallpaperKit

final class ResinRecoveryActivityController: Sendable {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static func backgroundSettingsSanityCheck() {
        let backgrounds = Defaults[.resinRecoveryLiveActivityBackgroundOptions]
        guard !backgrounds.isEmpty else { return }
        let allValidValues = Wallpaper.allCases.map(\.assetName4LiveActivity)
        for entry in backgrounds {
            guard !allValidValues.contains(entry) else { continue }
            // 之前的剔除方法无效，现在改了判定规则：
            // 只要发现不合规的 UserDefault 资料，那就全部清空。
            Defaults[.resinRecoveryLiveActivityBackgroundOptions].removeAll()
            return
        }
    }

    // MARK: Internal

    static let shared: ResinRecoveryActivityController = .init()

    var currentActivities: [Activity<ResinRecoveryAttributes>] {
        Activity<ResinRecoveryAttributes>.activities
    }

    var allowLiveActivity: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    var background: ResinRecoveryActivityBackground {
        if Defaults[.resinRecoveryLiveActivityUseEmptyBackground] {
            return .noBackground
        } else if !Defaults[.resinRecoveryLiveActivityUseCustomizeBackground] {
            return .random
        } else {
            Self.backgroundSettingsSanityCheck()
            let backgrounds = Defaults[.resinRecoveryLiveActivityBackgroundOptions]
            if backgrounds.isEmpty {
                return .customize([Wallpaper.defaultValue(for: nil).assetName4LiveActivity])
            } else {
                return .customize(backgrounds)
            }
        }
    }

    func createResinRecoveryTimerActivity(for account: PZProfileSendable, data: some DailyNoteProtocol) throws {
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
    }

    func updateResinRecoveryTimerActivity(for account: PZProfileSendable, data: some DailyNoteProtocol) {
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
    }

    func endActivity(for account: PZProfileSendable) {
        Task {
            let filtered = currentActivities.filter { activity in
                activity.attributes.accountUUID == account.uuid
            }
            for activity in filtered {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
    }

    func endAllActivity() {
        Task {
            for activity in currentActivities {
                await activity.end(nil, dismissalPolicy: .default)
            }
        }
    }
}

enum CreateLiveActivityError: Error {
    case notAllowed
    case otherError(String)
    case noInfo
}

extension CreateLiveActivityError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notAllowed:
            return .init(localized: errorDescriptionKeys)
        case .noInfo:
            return .init(localized: errorDescriptionKeys)
        case let .otherError(message):
            return String(format: .init(localized: errorDescriptionKeys), message)
        }
    }

    private var errorDescriptionKeys: LocalizedStringResource {
        switch self {
        case .notAllowed:
            return "settings.resinTimer.error.systemSettings"
        case .noInfo:
            return "settings.resinTimer.error.noInfo"
        case .otherError:
            return "settings.resinTimer.error.unknown:%@"
        }
    }
}
#endif
