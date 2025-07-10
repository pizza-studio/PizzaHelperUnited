// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation

@MainActor
final class AlertToastEventStatus: ObservableObject {
    public var isProfileTaskSucceeded = false
    public var isFailureSituationTriggered = false
    public var isDeviceFPPropagationSucceeded = false
}
