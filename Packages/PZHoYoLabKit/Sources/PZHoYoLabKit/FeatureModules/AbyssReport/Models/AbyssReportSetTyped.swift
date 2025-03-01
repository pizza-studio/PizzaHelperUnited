// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - AbyssReportSetTyped

/// 一套深渊战报得允许包括前一次的深渊战绩。
public struct AbyssReportSetTyped<Report: AbyssReport>: AbyssReportSet {
    // MARK: Lifecycle

    public init?(
        current: Report?,
        previous: Report? = nil,
        costumeMap: [String: String]? = nil,
        profile: PZProfileSendable?
    ) {
        guard let current else { return nil }
        self.current = current
        self.previous = previous
        self.costumeMap = costumeMap ?? [:]
        self.profile = profile
    }

    // MARK: Public

    public let current: Report
    public var previous: Report?
    public var costumeMap: [String: String]
    public let profile: PZProfileSendable?

    @MainActor public var asView: AbyssReportSetView<Report> {
        AbyssReportSetView(data: self, profile: profile)
    }
}

public typealias AbyssReportSet4GI = AbyssReportSetTyped<HoYo.AbyssReport4GI>
public typealias AbyssReportSet4HSR = AbyssReportSetTyped<HoYo.AbyssReport4HSR>
