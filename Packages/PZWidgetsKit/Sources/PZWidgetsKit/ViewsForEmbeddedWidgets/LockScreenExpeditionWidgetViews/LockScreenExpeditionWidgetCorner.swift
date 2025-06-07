// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(macOS, unavailable)
extension EmbeddedWidgets {
    // MARK: - LockScreenExpeditionWidgetCorner

    @available(macOS, unavailable)
    public struct LockScreenExpeditionWidgetCorner: View {
        // MARK: Lifecycle

        public init(result: Result<any DailyNoteProtocol, any Error>) {
            self.result = result
        }

        // MARK: Public

        public var body: some View {
            Pizza.SupportedGame(dailyNoteResult: result).expeditionAssetSVG
                .resizable()
                .scaledToFit()
                .padding(4.5)
                .widgetLabel(text)
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let result: Result<any DailyNoteProtocol, any Error>

        private let formatter: DateFormatter = {
            let fmt = DateFormatter.CurrentLocale()
            fmt.doesRelativeDateFormatting = true
            fmt.dateStyle = .short
            fmt.timeStyle = .short
            return fmt
        }()

        private var text: String {
            switch result {
            case let .success(data):
                /// ZZZ Has no expedition intels available through API yet.
                switch data {
                case _ as Note4ZZZ: return "NOT 4\nZZZ"
                default:
                    let timeDescription: String = {
                        if data.allExpeditionsAccomplished {
                            return String(
                                localized: String.LocalizationValue(stringLiteral: "pzWidgetsKit.status.done"),
                                bundle: .module
                            )
                        } else if let maxFinishTime = data.expeditionTotalETA {
                            return formatter.string(from: maxFinishTime)
                        } else {
                            return ""
                        }
                    }()

                    let numerator = data.expeditionCompletionStatus.finished
                    let denominator = data.expeditionCompletionStatus.all
                    return "\(numerator) / \(denominator) \(timeDescription)"
                }
            case .failure:
                return String(
                    localized: String.LocalizationValue(stringLiteral: "pzWidgetsKit.expedition"),
                    bundle: .module
                )
            }
        }
    }
}
