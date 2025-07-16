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
            if let theTask = task {
                stateGuard?.cancel()
                stateGuard = Task { [weak self] in
                    guard let this = self else { return }
                    await theTask.value
                    await MainActor.run {
                        this.taskState = .standby
                    }
                }
                taskState = .busy
            } else {
                taskState = .standby
            }
        }
    }

    // MARK: Private

    @ObservationIgnored private var stateGuard: Task<Void, Never>?
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

    // MARK: Private

    private var stateGuard: Task<Void, Never>?
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

    /// 不要在子 class 内 override 这个方法，因为一点儿屌用也没有。
    /// 除非你在子 class 内也复写了 fireTask()，否则其预设的 Error 处理函式永远都是父 class 的。
    ///
    /// 正确方法是在子 class 内直接改写 `super.assignableErrorHandlingTask` 的资料值。
    /// 或者你可以在 fireTask 的参数里面就地指定如何处理错误（但与之有关的动画与状态控制得自己搞）。
    ///
    /// 你可以在其中用 `if error is CancellationError` 处理与任务取消有关的错误。
    public func handleError(_ error: Error) {
        withAnimation {
            currentError = error
            // taskState = .standby
        }
        assignableErrorHandlingTask(error)
        task?.cancel()
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
                withAnimation {
                    notMetHandler()
                }
            }
            return
        }
        withAnimation {
            currentError = nil
            taskState = .busy
            animatedPreparationTask?()
        }
        Task { [weak self] in
            guard let self else { return }
            let previousTask = task
            let newTask = Task(priority: .background) { [weak self] in
                if cancelPreviousTask {
                    previousTask?.cancel() // 按需取消既有任务。
                } else {
                    await previousTask?.value // 等待既有任务执行完毕。
                }
                do {
                    let retrieved = try await givenTask()
                    await MainActor.run { [weak self] in
                        guard let this = self else { return }
                        withAnimation {
                            if let retrieved {
                                completionHandler?(retrieved)
                            }
                            this.currentError = nil
                            this.taskState = .standby // 此步骤必需。
                        }
                    }
                } catch {
                    Task { @MainActor [weak self] in
                        guard let this = self else { return }
                        (errorHandler ?? this.handleError)(error) // 处理其他的错误。
                        this.taskState = .standby // 此步骤必需。
                    }
                }
            }
            await MainActor.run {
                task = newTask
            }
        }
    }
}
