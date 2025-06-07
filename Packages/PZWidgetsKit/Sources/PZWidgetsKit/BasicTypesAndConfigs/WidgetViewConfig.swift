// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import WallpaperKit

// MARK: - WidgetViewConfig

@available(watchOS, unavailable)
public struct WidgetViewConfig: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(noticeMessage: String? = nil) {
        self.noticeMessage = noticeMessage
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
    public var selectedBackgrounds: Set<WidgetBackgroundEntityRAW> = [.defaultBackground]

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
