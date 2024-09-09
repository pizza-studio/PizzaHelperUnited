// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI

// MARK: - Ledger

public protocol Ledger: Codable, Hashable, Sendable, DecodableFromMiHoYoAPIJSONResult {
    associatedtype ViewType: LedgerView where Self == ViewType.LedgerData
}

extension Ledger {
    @MainActor @ViewBuilder
    public func asView() -> some View {
        ViewType(data: self)
    }
}

// MARK: - LedgerView

@MainActor
public protocol LedgerView: View {
    associatedtype LedgerData: Ledger where Self == LedgerData.ViewType
    init(data: LedgerData)
    var data: LedgerData { get }
    @MainActor @ViewBuilder var body: Self.Body { get }
}
