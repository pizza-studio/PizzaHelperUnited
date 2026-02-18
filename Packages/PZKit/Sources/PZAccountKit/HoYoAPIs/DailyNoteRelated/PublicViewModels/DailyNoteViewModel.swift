// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Foundation
import Observation
import PZBaseKit
import SwiftUI

// MARK: - MultiNoteViewModel

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
public final class MultiNoteViewModel {
    // MARK: Lifecycle

    public init() {
        updateVMInstances()
        Task { [weak self] in
            for await _ in Defaults.updates(.pzProfiles) {
                self?.updateVMInstances()
            }
        }
    }

    // MARK: Public

    public static let shared: MultiNoteViewModel = .init()

    public var vmMap: [String: DailyNoteViewModel] = [:]
}
#else
@MainActor
public final class MultiNoteViewModel: ObservableObject {
    // MARK: Lifecycle

    public init() {
        updateVMInstances()
        Task { [weak self] in
            for await _ in Defaults.updates(.pzProfiles) {
                self?.updateVMInstances()
            }
        }
    }

    // MARK: Public

    public static let shared: MultiNoteViewModel = .init()

    @Published public var vmMap: [String: DailyNoteViewModel] = [:] {
        didSet {
            objectWillChange.send()
        }
    }
}
#endif

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, *)
#endif
extension MultiNoteViewModel {
    public func updateVMInstances() {
        let dailyNoteVMMapKeys = Set(vmMap.keys)
        let latestProfileKeys = Set<String>(Defaults[.pzProfiles].keys)
        let vmKeysToDrop = dailyNoteVMMapKeys.subtracting(latestProfileKeys)
        let vmKeysToAdd = latestProfileKeys.subtracting(dailyNoteVMMapKeys)
        vmKeysToDrop.forEach { vmMap.removeValue(forKey: $0) }
        vmKeysToAdd.forEach { uuidStr in
            if vmMap[uuidStr] == nil, let profile = Defaults[.pzProfiles][uuidStr] {
                vmMap[uuidStr] = .init(profile: profile)
            }
        }
    }

    public func getAllDailyNoteUnchecked() async {
        for subVM in vmMap.values {
            await subVM.getDailyNoteUncheckAndWaitUntilFinish()
        }
    }
}

// MARK: - DailyNoteViewModel

// 因为该 VM 也用于 Apple Watch，所以塞到 PZAccountKit 里面。

#if !os(watchOS)

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
public final class DailyNoteViewModel: TaskManagedVM {
    // MARK: Lifecycle

    /// Initializes a new instance of the view model.
    ///
    /// - Parameter account: The account for which the daily note will be fetched.
    public init(profile: PZProfileSendable, extraTaskAfterFetch: ((any DailyNoteProtocol) -> Void)? = nil) {
        self.profile = profile
        self.extraTask = extraTaskAfterFetch
        super.init()
        getDailyNoteUncheck(getCachedResult: true)
    }

    // MARK: Public

    /// The fetched daily note result.
    public private(set) var dailyNote: (any DailyNoteProtocol)?

    /// The date when the daily note was last refreshed.
    public private(set) var refreshDate: Date?

    /// The account for which the daily note is being fetched.
    public var profile: PZProfileSendable

    // MARK: Private

    @ObservationIgnored private let extraTask: ((any DailyNoteProtocol) -> Void)?
}

#else

@MainActor
public final class DailyNoteViewModel: TaskManagedVMBackported {
    // MARK: Lifecycle

    /// Initializes a new instance of the view model.
    ///
    /// - Parameter account: The account for which the daily note will be fetched.
    public init(profile: PZProfileSendable, extraTaskAfterFetch: ((any DailyNoteProtocol) -> Void)? = nil) {
        self.profile = profile
        self.extraTask = extraTaskAfterFetch
        super.init()
        getDailyNoteUncheck(getCachedResult: true)
    }

    // MARK: Public

    /// The fetched daily note result.
    @Published public private(set) var dailyNote: (any DailyNoteProtocol)?

    /// The date when the daily note was last refreshed.
    @Published public private(set) var refreshDate: Date?

    /// The account for which the daily note is being fetched.
    @Published public var profile: PZProfileSendable

    // MARK: Private

    private let extraTask: ((any DailyNoteProtocol) -> Void)?
}

#endif

#if !os(watchOS)
@available(iOS 17.0, macCatalyst 17.0, *)
#endif
extension DailyNoteViewModel {
    public enum Status: Sendable {
        case succeed(dailyNote: any DailyNoteProtocol, refreshDate: Date)
        case failure(error: AnyLocalizedError)
        case progress(Task<Void, Never>?)
    }

    /// Computed status for backward-compatible view consumption.
    public var dailyNoteStatus: Status {
        if taskState == .busy {
            return .progress(task)
        } else if let error = currentError {
            return .failure(error: AnyLocalizedError(error))
        } else if let dailyNote, let refreshDate {
            return .succeed(dailyNote: dailyNote, refreshDate: refreshDate)
        } else {
            return .progress(nil)
        }
    }

    /// Fetches the daily note and updates the published `dailyNote` property accordingly.
    public func getDailyNote() {
        switch dailyNoteStatus {
        case let .succeed(_, refreshDate):
            // check if note is older than 15 minutes
            let shouldUpdateAfterMinute: Double = 15
            let shouldUpdateAfterSecond = 60.0 * shouldUpdateAfterMinute
            if Date().timeIntervalSince(refreshDate) > shouldUpdateAfterSecond {
                getDailyNoteUncheck()
            }
        case .progress:
            return // another operation is already in progress
        default:
            getDailyNoteUncheck()
        }
    }

    /// Asynchronously fetches the daily note using the MiHoYoAPI with the account information it was initialized with.
    public func getDailyNoteUncheck(
        getCachedResult: Bool = true
    ) {
        getDailyNoteUncheckWithExtraTasks(
            getCachedResult: getCachedResult
        )
    }

    public func getDailyNoteUncheckAndWaitUntilFinish(getCachedResult: Bool = true) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            getDailyNoteUncheckWithExtraTasks(
                getCachedResult: getCachedResult,
                onEverythingEnds: { continuation.resume() }
            )
        }
    }

    fileprivate func getDailyNoteUncheckWithExtraTasks(
        getCachedResult: Bool = true,
        onEverythingEnds: (() -> Void)? = nil
    ) {
        let theProfile = profile
        let theExtraTask = extraTask
        fireTask(
            cancelPreviousTask: true,
            givenTask: {
                try await theProfile.getDailyNote(cached: getCachedResult)
            },
            completionHandler: { [weak self] result in
                guard let self, let result else {
                    onEverythingEnds?()
                    return
                }
                dailyNote = result
                refreshDate = Date()
                theExtraTask?(result)
                onEverythingEnds?()
            },
            errorHandler: { _ in
                onEverythingEnds?()
            }
        )
    }
}
