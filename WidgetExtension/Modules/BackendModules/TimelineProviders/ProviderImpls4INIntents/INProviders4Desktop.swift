// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if ENABLE_ININTENTS_BACKPORTS
#if !os(watchOS)

import CoreGraphics
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import PZWidgetsKit
import WidgetKit

// MARK: - DualProfileWidgetProvider

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct INDualProfileWidgetProvider: INThreadSafeTimelineProvider {
    public typealias Entry = ProfileWidgetEntry
    public typealias Intent = SelectDualProfileIntent
    public typealias NextGenTLProvider = DualProfileWidgetProvider

    public let asyncTLProvider: NextGenTLProvider = .init()
}

// MARK: - SingleProfileWidgetProvider

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct INSingleProfileWidgetProvider: INThreadSafeTimelineProvider {
    public typealias Entry = ProfileWidgetEntry
    public typealias Intent = SelectAccountIntent
    public typealias NextGenTLProvider = SingleProfileWidgetProvider

    public let asyncTLProvider: NextGenTLProvider = .init()
}

// MARK: - OfficialFeedWidgetProvider

@available(iOS 16.2, macCatalyst 16.2, *)
@available(watchOS, unavailable)
struct INOfficialFeedWidgetProvider: INThreadSafeTimelineProvider {
    public typealias Entry = OfficialFeedWidgetEntry
    public typealias Intent = SelectOnlyGameIntent
    public typealias NextGenTLProvider = OfficialFeedWidgetProvider

    public let asyncTLProvider: NextGenTLProvider = .init()
}

#endif
#endif
