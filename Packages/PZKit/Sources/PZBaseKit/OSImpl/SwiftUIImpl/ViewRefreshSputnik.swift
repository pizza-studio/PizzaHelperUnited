// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation

@Observable @MainActor
public final class ViewEventBroadcaster {
    public static let shared = ViewEventBroadcaster()

    public private(set) var eventForRefreshingCurrentPage: UUID = .init()
    public private(set) var eventForStoppingRootTabTasks: UUID = .init()

    public func refreshPage() {
        eventForRefreshingCurrentPage = .init()
    }

    public func stopRootTabTasks() {
        eventForStoppingRootTabTasks = .init()
    }
}
