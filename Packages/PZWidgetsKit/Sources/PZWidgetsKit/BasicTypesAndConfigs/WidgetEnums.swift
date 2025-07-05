// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

@available(iOS 16.0, *)
@available(macCatalyst 16.0, *)
@available(macOS 13.0, *)
@available(watchOS 9.0, *)
extension PZWidgetsSPM {
    // MARK: - WeeklyBossesDisplayMethod

    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(macOS 13.0, *)
    @available(watchOS 9.0, *)
    public enum WeeklyBossesDisplayMethod: String, AbleToCodeSendHash {
        case disappearAfterCompleted
        case alwaysShow
        case neverShow
    }

    // MARK: - ExpeditionDisplayPolicy

    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(macOS 13.0, *)
    @available(watchOS 9.0, *)
    public enum ExpeditionDisplayPolicy: String, AbleToCodeSendHash {
        case neverDisplay
        case displayWhenAvailable
        case displayExclusively
    }

    // MARK: - StaminaContentRevolverStyle

    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(macOS 13.0, *)
    @available(watchOS 9.0, *)
    public enum StaminaContentRevolverStyle: String, AbleToCodeSendHash {
        case byDefault
        case timer
        case time
        case roundMeter
    }
}
