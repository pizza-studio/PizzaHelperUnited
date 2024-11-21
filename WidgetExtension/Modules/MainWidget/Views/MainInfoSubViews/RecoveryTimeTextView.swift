// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - RecoveryTimeText

@available(watchOS, unavailable)
struct RecoveryTimeText: View {
    let entry: any TimelineEntry
    let data: any DailyNoteProtocol

    var body: some View {
        Group {
            let textData = makeContentText()
            switch textData.isFull {
            case true: textData.text.lineLimit(2).lineSpacing(1)
            case false: textData.text.multilineTextAlignment(.leading)
            }
        }
        .font(.caption)
        .minimumScaleFactor(0.2)
        .foregroundColor(Color("textColor3", bundle: .main))
        .widgetLegibilityShadow()
    }

    @MainActor
    func makeContentText() -> (text: Text, isFull: Bool) {
        let textFull = Text("pzWidgetsKit.infoBlock.staminaFullyFilledDescription", bundle: .main)
        switch data {
        case let data as any Note4GI:
            let resinInfo = data.resinInfo
            if resinInfo.currentResinDynamic < resinInfo.maxResin {
                let compoundedText = """
                \(PZWidgets.dateFormatter.string(from: resinInfo.resinRecoveryTime))
                \(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: resinInfo.resinRecoveryTime))!)
                """
                return (Text(compoundedText), false)
            } else {
                return (textFull, true)
            }
        case let data as Note4HSR:
            let staminaInfo = data.staminaInfo
            if staminaInfo.currentStamina < staminaInfo.maxStamina {
                let compoundedText = """
                \(PZWidgets.dateFormatter.string(from: staminaInfo.fullTime))
                \(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: staminaInfo.fullTime))!)
                """
                return (Text(compoundedText), false)
            } else {
                return (textFull, true)
            }
        case let data as Note4ZZZ:
            let energyInfo = data.energy
            if energyInfo.currentEnergyAmountDynamic < energyInfo.progress.max {
                let compoundedText = """
                \(PZWidgets.dateFormatter.string(from: energyInfo.timeOnFinish))
                \(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: energyInfo.timeOnFinish))!)
                """
                return (Text(compoundedText), false)
            } else {
                return (textFull, true)
            }
        default: return (Text(verbatim: ""), false)
        }
    }
}
