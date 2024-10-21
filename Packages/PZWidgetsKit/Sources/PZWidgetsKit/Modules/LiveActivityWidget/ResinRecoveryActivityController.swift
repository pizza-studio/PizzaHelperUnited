// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit)
import ActivityKit
@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit

class ResinRecoveryActivityController {
    // MARK: Lifecycle

    private init() {}

    // MARK: Public

    public static func backgroundSettingsSanityCheck() {
        let backgrounds = Defaults[.resinRecoveryLiveActivityBackgroundOptions]
        guard !backgrounds.isEmpty else { return }
        let allValidValues = NameCard.allLegalCases.map(\.fileName)
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
                return .customize([NameCard.defaultValueForWidget.fileName])
            } else {
                return .customize(backgrounds)
            }
        }
    }

    func createResinRecoveryTimerActivity(for account: Account, data: some DailyNote) throws {
        guard allowLiveActivity else {
            throw CreateLiveActivityError.notAllowed
        }
        let accountName = account.safeName
        let accountUUID: UUID = account.safeUuid

        guard !currentActivities.map({ $0.attributes.accountUUID })
            .contains(account.safeUuid) else {
            updateResinRecoveryTimerActivity(for: account, data: data)
            return
        }
        let attributes: ResinRecoveryAttributes = .init(
            accountName: accountName,
            accountUUID: accountUUID
        )
        let status: ResinRecoveryAttributes.ResinRecoveryState = .init(
            resinInfo: data.resinInfo,
            expeditionInfo: data.expeditionInfo4GI,
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
                contentState: status
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

    func updateResinRecoveryTimerActivity(for account: Account, data: some DailyNote) {
        currentActivities.filter { activity in
            activity.attributes.accountUUID == account.uuid ?? UUID()
        }.forEach { activity in
            Task {
                guard Date
                    .now <
                    data.resinInfo
                    .resinRecoveryTime else {
                    endActivity(for: account)
                    return
                }
                let status: ResinRecoveryAttributes
                    .ResinRecoveryState = .init(
                        resinInfo: data.resinInfo,
                        expeditionInfo: data.expeditionInfo4GI,
                        showExpedition: Defaults[.resinRecoveryLiveActivityShowExpedition],
                        background: background
                    )
                await activity.update(using: status)
            }
        }
    }

    func endActivity(for account: Account) {
        currentActivities.filter { activity in
            activity.attributes.accountUUID == account.uuid ?? UUID()
        }.forEach { activity in
            Task {
                await activity.end()
            }
        }
    }

    func endAllActivity() {
        currentActivities.forEach { activity in
            Task {
                await activity.end()
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
            return "settings.resinTimer.error.systemSettings".localized
        case .noInfo:
            return "settings.resinTimer.error.noInfo".localized
        case let .otherError(message):
            return String(
                format: NSLocalizedString("settings.resinTimer.error.unknown:%@", comment: ""),
                message
            )
        }
    }
}
#endif
