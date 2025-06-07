// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import WallpaperKit

// MARK: - Config4DesktopProfileWidgets

@available(watchOS, unavailable)
public struct Config4DesktopProfileWidgets: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(noticeMessage: String? = nil) {
        self.showAccountName = true
        self.showTransformer = true
        self.trounceBlossomDisplayMethod = .disappearAfterCompleted
        self.echoOfWarDisplayMethod = .disappearAfterCompleted
        self.selectedBackgrounds = [.defaultBackground]
        self.randomBackground = false
        self.isDarkModeRespected = true
        self.showMaterialsInLargeSizeWidget = true
        self.noticeMessage = noticeMessage
        self.showStaminaOnly = false
        self.useTinyGlassDisplayStyle = false
        self.expeditionDisplayPolicy = .displayWhenAvailable
    }

    public init(
        showAccountName: Bool,
        showTransformer: Bool,
        showExpeditionCompleteTime: Bool,
        showWeeklyBosses: Bool,
        noticeMessage: String?
    ) {
        self.showAccountName = showAccountName
        self.showTransformer = showTransformer
        self.trounceBlossomDisplayMethod = .disappearAfterCompleted
        self.echoOfWarDisplayMethod = .disappearAfterCompleted
        self.randomBackground = false
        self.selectedBackgrounds = [.defaultBackground]
        self.isDarkModeRespected = true
        self.showMaterialsInLargeSizeWidget = true
        self.showStaminaOnly = false
        self.useTinyGlassDisplayStyle = false
        self.expeditionDisplayPolicy = .displayWhenAvailable
    }

    // MARK: Public

    public static var defaultConfig: Self { .init() }

    public var showAccountName: Bool
    public var showTransformer: Bool
    public var trounceBlossomDisplayMethod: PZWidgetsSPM.WeeklyBossesDisplayMethod
    public var echoOfWarDisplayMethod: PZWidgetsSPM.WeeklyBossesDisplayMethod
    public var noticeMessage: String?
    public var isDarkModeRespected: Bool
    public var showStaminaOnly: Bool
    public var useTinyGlassDisplayStyle: Bool
    public var showMaterialsInLargeSizeWidget: Bool
    public var randomBackground: Bool
    public var expeditionDisplayPolicy: PZWidgetsSPM.ExpeditionDisplayPolicy
    public var selectedBackgrounds: Set<WidgetBackgroundEntityRAW>

    public var neverDisplayExpeditionList: Bool { expeditionDisplayPolicy == .neverDisplay }

    // MARK: Internal

    mutating func addMessage(_ msg: String) {
        noticeMessage = msg
    }
}

// MARK: - WidgetBackgroundEntityRAW

public struct WidgetBackgroundEntityRAW: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    // MARK: Public

    public static let defaultBackground: Self = {
        BundledWallpaper.defaultValue(for: appGame).asWidgetBackgroundEntity
    }()

    public var id: String
    public var displayString: String
}

extension BundledWallpaper {
    fileprivate var asWidgetBackgroundEntity: WidgetBackgroundEntityRAW {
        .init(id: assetName4LiveActivity, displayString: localizedNameForWidgets)
    }

    private var localizedNameForWidgets: String {
        Defaults[.useRealCharacterNames]
            ? localizedRealName
            : localizedName
    }
}
