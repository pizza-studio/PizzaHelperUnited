// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct WidgetErrorView: View {
        // MARK: Lifecycle

        public init(error: any Error, message: String, refreshIntent: WidgetRefreshIntent? = nil) {
            self.error = error
            self.message = message
            self.refreshIntent = refreshIntent
        }

        // MARK: Public

        public var body: some View {
            HStack(alignment: .top) {
                let imageLabel = Image(systemSymbol: .arrowClockwiseCircle)
                    .font(.title3)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .clipShape(.circle)
                    .legibilityShadow()
                Group {
                    if let refreshIntent {
                        Button(intent: refreshIntent) {
                            imageLabel
                        }
                        .buttonStyle(.plain)
                    } else {
                        imageLabel
                    }
                }
                .padding()
                Text(error.localizedDescription)
                    .bold()
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .legibilityShadow()
            }
            .padding(20)
        }

        // MARK: Private

        private let error: any Error
        private let message: String
        private let refreshIntent: WidgetRefreshIntent?
    }
}
