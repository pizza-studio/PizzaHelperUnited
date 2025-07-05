// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension PZWidgetsSPM {
    // MARK: - WeeklyBossesDisplayMethod

    public enum WeeklyBossesDisplayMethod: String, AbleToCodeSendHash {
        case disappearAfterCompleted
        case alwaysShow
        case neverShow
    }

    // MARK: - ExpeditionDisplayPolicy

    public enum ExpeditionDisplayPolicy: String, AbleToCodeSendHash {
        case neverDisplay
        case displayWhenAvailable
        case displayExclusively
    }

    // MARK: - StaminaContentRevolverStyle

    public enum StaminaContentRevolverStyle: String, AbleToCodeSendHash {
        case byDefault
        case timer
        case time
        case roundMeter
    }
}
