// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import PZBaseKit
import SwiftUI

// MARK: - DailyNoteViewModel

// 因为该 VM 也用于 Apple Watch，所以塞到 PZAccountKit 里面。

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
@Observable @MainActor
public final class DailyNoteViewModel {
    // MARK: Lifecycle

    /// Initializes a new instance of the view model.
    ///
    /// - Parameter account: The account for which the daily note will be fetched.
    public init(profile: PZProfileSendable, extraTaskAfterFetch: ((any DailyNoteProtocol) -> Void)? = nil) {
        self.profile = profile
        self.extraTask = extraTaskAfterFetch
        getDailyNoteUncheck()
    }

    // MARK: Public

    public enum Status: Sendable {
        case succeed(dailyNote: any DailyNoteProtocol, refreshDate: Date)
        case failure(error: AnyLocalizedError)
        case progress(Task<Void, Never>?)
    }

    /// The current daily note.
    public private(set) var dailyNoteStatus: Status = .progress(nil)

    /// The account for which the daily note is being fetched.
    public let profile: PZProfileSendable

    /// Fetches the daily note and updates the published `dailyNote` property accordingly.
    @MainActor
    public func getDailyNote() {
        if case let .succeed(_, refreshDate) = dailyNoteStatus {
            // check if note is older than 15 minutes
            let shouldUpdateAfterMinute: Double = 15
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute

            if Date().timeIntervalSince(refreshDate) > shouldUpdateAfterSecond {
                getDailyNoteUncheck()
            }
        } else if case .progress = dailyNoteStatus {
            return // another operation is already in progress
        } else {
            getDailyNoteUncheck()
        }
    }

    /// Asynchronously fetches the daily note using the MiHoYoAPI with the account information it was initialized with.
    @MainActor
    public func getDailyNoteUncheck() {
        if case let .progress(task) = dailyNoteStatus {
            task?.cancel()
        }
        let task = Task { @MainActor in
            do {
                let result = try await profile.getDailyNote()
                withAnimation {
                    dailyNoteStatus = .succeed(dailyNote: result, refreshDate: Date())
                }
                extraTask?(result)
            } catch {
                withAnimation {
                    dailyNoteStatus = .failure(error: AnyLocalizedError(error))
                }
            }
        }
        dailyNoteStatus = .progress(task)
    }

    // MARK: Private

    private let extraTask: ((any DailyNoteProtocol) -> Void)?
}
