// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

public struct FieldCompletionIntel<Unit: AbleToCodeSendHash & AdditiveArithmetic>: AbleToCodeSendHash, Equatable {
    // MARK: Lifecycle

    public init(pending: Unit, finished: Unit, all: Unit) {
        self.pending = pending
        self.finished = finished
        self.all = all
    }

    // MARK: Public

    /// 还没完成的部分
    public let pending: Unit
    /// 完成的部分
    public let finished: Unit
    /// 总量
    public let all: Unit

    public var isMeaningful: Bool {
        (all == pending + finished) && !(all == pending && all == finished)
    }

    public var isAccomplished: Bool {
        finished == all && isMeaningful
    }
}
