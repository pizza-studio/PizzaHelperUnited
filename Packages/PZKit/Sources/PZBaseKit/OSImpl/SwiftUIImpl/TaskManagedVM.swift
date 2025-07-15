// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import SwiftUI

// MARK: - TaskManagedVM

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Observable
@MainActor
open class TaskManagedVM: TaskManagedVMProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var taskState: ManagedTaskState = .standby
    public var currentError: Error?

    /// 可被子类赋值的 error handler
    @ObservationIgnored public var assignableErrorHandlingTask: ((Error) -> Void) = { _ in }

    /// 唯一保留的业务 Task
    public var task: Task<Void, Never>? {
        didSet {
            if task == nil {
                taskState = .standby
            } else {
                taskState = .busy
            }
        }
    }
}

// MARK: - TaskManagedVMBackported

@MainActor
open class TaskManagedVMBackported: TaskManagedVMProtocol, ObservableObject {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @Published public var taskState: ManagedTaskState = .standby
    @Published public var currentError: Error?

    /// 可被子类赋值的 error handler
    public var assignableErrorHandlingTask: ((Error) -> Void) = { _ in }

    /// 唯一保留的业务 Task
    public var task: Task<Void, Never>? {
        didSet {
            if task == nil {
                taskState = .standby
            } else {
                taskState = .busy
            }
        }
    }
}

// MARK: - TaskManagedVMProtocol

@MainActor
public protocol TaskManagedVMProtocol: AnyObject {
    typealias State = ManagedTaskState
    var taskState: State { get set }
    var currentError: Error? { get set }
    var assignableErrorHandlingTask: (Error) -> Void { get set }
    var task: Task<Void, Never>? { get set }

    func forceStopTheTask()
    func handleError(_ error: Error)
    func fireTask<each T: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)?,
        animatedPreparationTask: (() -> Void)?,
        cancelPreviousTask: Bool,
        givenTask: @escaping () async throws -> (repeat each T)?,
        completionHandler: (((repeat each T)?) -> Void)?,
        errorHandler: ((Error) -> Void)?
    )
}

// MARK: - ManagedTaskState

public enum ManagedTaskState: String, Sendable, Hashable, Identifiable {
    case busy
    case standby

    // MARK: Public

    public var id: String { rawValue }
}

extension TaskManagedVMProtocol {
    /// 兼容旧接口，强制取消任务
    public func forceStopTheTask() {
        task?.cancel()
        taskState = .standby
    }

    public func handleError(_ error: Error) {
        withAnimation {
            currentError = error
        }
        assignableErrorHandlingTask(error)
        task?.cancel()
        taskState = .standby
    }

    public func fireTask<each T: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)? = nil,
        animatedPreparationTask: (() -> Void)? = nil,
        cancelPreviousTask: Bool = true,
        givenTask: @escaping () async throws -> (repeat each T)?,
        completionHandler: (((repeat each T)?) -> Void)? = nil,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        if let prerequisite, !prerequisite.condition {
            if let notMetHandler = prerequisite.notMetHandler {
                withAnimation { notMetHandler() }
            }
            return
        }
        withAnimation {
            currentError = nil
            taskState = .busy
            animatedPreparationTask?()
        }
        let oldTask = task
        if cancelPreviousTask {
            oldTask?.cancel()
        }
        task = Task(priority: .background) { [weak self] in
            guard let self else { return }
            if !cancelPreviousTask {
                await oldTask?.value
            }
            do {
                let retrieved = try await givenTask()
                await animateOnMain {
                    if let retrieved {
                        completionHandler?(retrieved)
                    }
                    self.currentError = nil
                }
            } catch {
                await animateOnMain {
                    (errorHandler ?? self.handleError)(error)
                }
            }
            await animateOnMain { self.taskState = .standby }
        }
    }

    private func animateOnMain<T>(
        resultType: T.Type = T.self,
        body action: @MainActor () throws -> T
    ) async rethrows
        -> T where T: Sendable {
        try await MainActor.run {
            try withAnimation { try action() }
        }
    }
}
