// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenDailyTaskWidgetView

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct LockScreenDailyTaskWidgetView: View {
        // MARK: Lifecycle

        public init(entry: ProfileWidgetEntry) {
            self.entry = entry
        }

        // MARK: Public

        public let entry: ProfileWidgetEntry

        public var body: some View {
            Group {
                switch family {
                #if os(watchOS)
                case .accessoryCorner:
                    LockScreenDailyTaskWidgetCorner(result: result)
                #endif
                case .accessoryCircular:
                    LockScreenDailyTaskWidgetCircular(result: result)
                default:
                    EmptyView()
                }
            }
            .widgetURL(url)
        }

        // MARK: Private

        @Environment(\.widgetFamily) private var family: WidgetFamily

        private var result: Result<any DailyNoteProtocol, any Error> { entry.result }

        private var url: URL? {
            let errorURL: URL = {
                var components = URLComponents()
                components.scheme = "ophelperwidget"
                components.host = "accountSetting"
                components.queryItems = [
                    .init(
                        name: "accountUUIDString",
                        value: entry.profile?.uuid.uuidString
                    ),
                ]
                return components.url!
            }()

            switch result {
            case .success:
                return nil
            case .failure:
                return errorURL
            }
        }
    }
}

#endif
