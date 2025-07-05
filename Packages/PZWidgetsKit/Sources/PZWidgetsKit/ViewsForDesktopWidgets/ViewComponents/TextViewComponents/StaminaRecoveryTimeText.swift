// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct StaminaRecoveryTimeText: View {
        // MARK: Lifecycle

        public init(data: any DailyNoteProtocol, tiny: Bool = false) {
            self.data = data
            self.tiny = tiny
        }

        // MARK: Public

        public var body: some View {
            Group {
                let textData = makeContentText()
                switch textData.isFull {
                case true: textData.text.lineLimit(2).lineSpacing(1)
                case false: textData.text.multilineTextAlignment(.leading)
                }
            }
            .font(.caption2)
            .allowsTightening(true)
            .minimumScaleFactor(0.2)
            .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
            .legibilityShadow()
        }

        // MARK: Private

        private let data: any DailyNoteProtocol
        private let tiny: Bool

        private func makeContentText() -> (text: Text, isFull: Bool) {
            let key: String
                .LocalizationValue = tiny ? "pzWidgetsKit.infoBlock.staminaFullyFilledDescription.tiny" :
                "pzWidgetsKit.infoBlock.staminaFullyFilledDescription"
            let textFull = Text(.init(localized: key, bundle: .module))
            let staminaIntel = data.staminaIntel
            let fullTimeOnFinish = data.staminaFullTimeOnFinish
            if staminaIntel.finished < staminaIntel.all {
                let compoundedText = """
                \(PZWidgetsSPM.dateFormatter.string(from: fullTimeOnFinish))
                \(PZWidgetsSPM.intervalFormatter.string(from: TimeInterval.sinceNow(to: fullTimeOnFinish))!)
                """
                return (Text(compoundedText), false)
            } else {
                return (textFull, true)
            }
        }
    }
}

#endif
