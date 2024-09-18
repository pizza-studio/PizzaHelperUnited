// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Observation
import SwiftUI

// MARK: - GachaVM

@Observable
public class GachaVM: @unchecked Sendable {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public enum State: String, Sendable, Hashable, Identifiable {
        case busy
        case standBy

        // MARK: Public

        public var id: String { rawValue }
    }

    public static let shared = GachaVM()

    public var currentGachaProfile: PZGachaProfileMO?
    public var allAvailableGPIDs: [GachaProfileID] = []
    public var task: Task<Void, Never>?

    public var taskState: State = .standBy

    // MARK: Internal

    var errorMsg: String?
}

// MARK: - Tasks and Error Handlers.

extension GachaVM {
    public func handleError(_ error: Error) {
        withAnimation {
            errorMsg = "\(error)"
        }
        GachaActor.sharedBg.modelExecutor.modelContext.rollback()
        task?.cancel()
    }
}
