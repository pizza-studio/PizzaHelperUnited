// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
final class AlertToastEventStatus {
    public var isProfileTaskSucceeded = false
    public var isFailureSituationTriggered = false
    public var isDeviceFPPropagationSucceeded = false
}
