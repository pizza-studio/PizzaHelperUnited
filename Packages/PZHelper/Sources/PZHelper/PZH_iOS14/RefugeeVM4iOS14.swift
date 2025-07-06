// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import GachaKit
import PZCoreDataKit4GachaEntries
import PZCoreDataKit4LocalAccounts
import PZCoreDataKitShared
import SwiftUI

// MARK: - RefugeeVM4iOS14

@MainActor
public final class RefugeeVM4iOS14: TaskManagedVM4OS21 {
    // MARK: Lifecycle

    override private init() {
        super.init()
        configurePublisherObservations()
        startCountingDataEntriesTask(forced: true)
    }

    // MARK: Public

    public static let shared = RefugeeVM4iOS14()

    @Published public var currentExportableDocument: RefugeeDocument?
    @Published public var gachaEntriesCount: Int = 0
    @Published public var localProfileEntriesCount: Int = 0

    // MARK: Internal

    var isExportDialogVisible: Binding<Bool> {
        .init(get: {
            self.currentExportableDocument != nil
        }, set: { newValue in
            if !newValue {
                self.currentExportableDocument = nil
            }
        })
    }

    // MARK: Private

    nonisolated(unsafe) private var cancellables: [AnyCancellable] = []

    private func configurePublisherObservations() {
        if #unavailable(iOS 17) {
            NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
                .sink(receiveValue: { _ in
                    self.startCountingDataEntriesTask(forced: false)
                })
                .store(in: &cancellables)
        }
    }
}

extension RefugeeVM4iOS14 {
    public func startDocumentationPreparationTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: { [weak self] this in
                self?.prepareDocument(completion: this)
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                withAnimation {
                    this.currentExportableDocument = .init(file: newResult)
                }
            }
        )
    }

    public func startCountingDataEntriesTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: { [weak self] this in
                self?.countAllDataEntries(completion: this)
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                let (intGacha, intProfile) = newResult
                withAnimation {
                    this.gachaEntriesCount = intGacha
                    this.localProfileEntriesCount = intProfile
                }
            }
        )
    }
}

extension RefugeeVM4iOS14 {
    private func prepareDocument(completion: @escaping (Result<RefugeeFile?, Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            var result = RefugeeFile()
            do {
                result.oldGachaEntries4GI = try CDGachaMOSputnik.shared.getAllGenshinDataEntriesVanilla()
                result.oldProfiles4GI = try AccountMOSputnik.shared.allAccountDataForGenshin()
                completion(.success(result))
                self?.taskState = .standby
            } catch {
                completion(.failure(error))
                self?.taskState = .standby
            }
        }
    }

    private func countAllDataEntries(completion: @escaping (Result<(Int, Int)?, Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            var (intGacha, intProfile) = (0, 0)
            do {
                intGacha = try CDGachaMOSputnik.shared.countAllDataEntries(for: .genshinImpact)
                intProfile = try AccountMOSputnik.shared.countAllAccountData(for: .genshinImpact)
                completion(.success((intGacha, intProfile)))
                self?.taskState = .standby
            } catch {
                completion(.failure(error))
                self?.taskState = .standby
            }
        }
    }
}
