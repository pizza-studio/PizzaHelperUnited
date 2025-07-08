// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - PZWidgetsSPM

/// Xcode 对下述类型要求必须由 Xcode 专案直辖、不得塞入 Swift Pacakge。这些类型如下：
/// - AppEnum
/// - AppEntity
/// - Intents (不被系统直接读取的、只通过 Widgets 画面交互触发的除外）
/// - Widgets
///
/// 虽有一定技术难度，但 PZWidgets 已经对小工具实现了最大程度上的 SPM 解耦。
@available(iOS 16.2, macCatalyst 16.2, *)
public enum PZWidgetsSPM {}

@available(iOS 16.2, macCatalyst 16.2, *)
extension PZWidgetsSPM {
    public static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter.CurrentLocale()
        fmt.doesRelativeDateFormatting = true
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    public static let intervalFormatter: DateComponentsFormatter = {
        let dateComponentFormatter = DateComponentsFormatter()
        dateComponentFormatter.allowedUnits = [.hour, .minute]
        dateComponentFormatter.maximumUnitCount = 2
        dateComponentFormatter.unitsStyle = .brief
        return dateComponentFormatter
    }()
}
