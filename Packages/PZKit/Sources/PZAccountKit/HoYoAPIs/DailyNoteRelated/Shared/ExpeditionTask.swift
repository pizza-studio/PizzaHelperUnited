// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - ExpeditionTask

public protocol ExpeditionTask {
    var isFinished: Bool { get }
    var iconURL: URL { get }
    var game: Pizza.SupportedGame { get }
    static var game: Pizza.SupportedGame { get }
}

extension ExpeditionTask {
    // Expedition Protocol Method.
    public var game: Pizza.SupportedGame { Self.game }
    // Expedition Protocol Method.
    public var timeOnFinish: Date? {
        switch self {
        case let data as AssignmentInfo4HSR.Assignment: return data.finishedTime
        case let data as GeneralNote4GI.ExpeditionInfo4GI.Expedition: return data.finishTime
        case _ as WidgetNote4GI.ExpeditionInfo4GI.Expedition: return nil
        default: return nil
        }
    }
}

extension [ExpeditionTask] {
    public var hasPendingTask: Bool {
        !self.map { !$0.isFinished }.isEmpty
    }

    public var pendingTaskCount: Int {
        self.filter { !$0.isFinished }.count
    }

    public var finishedTaskCount: Int {
        self.filter(\.isFinished).count
    }

    public var allAccomplished: Bool {
        !hasPendingTask
    }

    public var totalETA: Date? {
        compactMap(\.timeOnFinish).max()
    }
}
