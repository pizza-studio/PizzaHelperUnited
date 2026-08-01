// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Foundation
import Observation

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
final class AlertToastEventStatus {
    public var isProfileTaskSucceeded = false
    public var isFailureSituationTriggered = false
    public var isDeviceFPPropagationSucceeded = false

    /// 在导航 pop 转场结束后再触发「任务成功」toast。
    /// iOS 17 上若与 dismiss 同一拍翻转 isPresenting，
    /// AlertToast 内部的 onChange 回调会被转场吞掉，
    /// 导致自动消退计时器从未排程、toast 常驻画面。
    @MainActor
    public func triggerProfileTaskSucceededAfterTransition() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.6))
            isProfileTaskSucceeded.toggle()
        }
    }
}
