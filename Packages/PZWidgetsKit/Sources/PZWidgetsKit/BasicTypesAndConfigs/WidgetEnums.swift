// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

@available(iOS 16.2, macCatalyst 16.2, *)
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
