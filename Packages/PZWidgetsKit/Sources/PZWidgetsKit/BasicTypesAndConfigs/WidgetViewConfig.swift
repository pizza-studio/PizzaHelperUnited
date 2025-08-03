// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import WallpaperKit

// MARK: - WidgetViewConfig

@available(iOS 16.2, macCatalyst 16.2, *)
public struct WidgetViewConfig: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(noticeMessage: String? = nil) {
        self.noticeMessage = noticeMessage
        updateBackgroundValue()
    }

    // MARK: Public

    public static var defaultConfig: Self { .init() }

    public var showTransformer: Bool = true
    public var trounceBlossomDisplayMethod: PZWidgetsSPM.WeeklyBossesDisplayMethod = .disappearAfterCompleted
    public var echoOfWarDisplayMethod: PZWidgetsSPM.WeeklyBossesDisplayMethod = .disappearAfterCompleted
    public var noticeMessage: String?
    public var isDarkModeRespected: Bool = true
    public var showStaminaOnly: Bool = false
    public var useTinyGlassDisplayStyle: Bool = false
    public var showMaterialsInLargeSizeWidget: Bool = true
    public var randomBackground: Bool = false
    public var expeditionDisplayPolicy: PZWidgetsSPM.ExpeditionDisplayPolicy = .displayWhenAvailable
    public var staminaContentRevolverStyle: PZWidgetsSPM.StaminaContentRevolverStyle = .byDefault
    public var background: WidgetBackground = .defaultBackground
    public var selectedBackgrounds: Set<WidgetBackground> = [.defaultBackground]

    public var neverDisplayExpeditionList: Bool { expeditionDisplayPolicy == .neverDisplay }

    public mutating func updateBackgroundValue() {
        background = {
            guard !randomBackground else {
                return .randomElementOrWallpaperBackground
            }
            if selectedBackgrounds.isEmpty {
                return .defaultBackground
            } else {
                return selectedBackgrounds.randomElement() ?? .defaultBackground
            }
        }()
    }

    public mutating func addMessage(_ msg: String) {
        noticeMessage = msg
    }

    public func saveOnlineBackgroundAsset() async {
        switch Wallpaper(id: background.id) {
        case let .bundled(bundledWP): await bundledWP.saveOnlineBackgroundAsset()
        default: break
        }
    }
}
