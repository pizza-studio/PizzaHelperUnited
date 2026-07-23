// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Combine
import Foundation
import Observation
import SwiftUI

// MARK: - JobExecutor

/// 序列化任务执行器。确保同一 VM 上一次只跑一个任务，
/// 且 `.busy` → `.standby` 状态转换严格由本物件控制。
///
/// 命名避让 Swift 标准库的 `TaskExecutor` protocol。
@available(iOS 14.0, macCatalyst 14.0, *)
public final class JobExecutor: @unchecked Sendable {
    // MARK: Internal

    func enqueue(
        cancelPrevious: Bool,
        operation: @escaping @Sendable () async throws -> Void,
        onError: @MainActor @escaping @Sendable (Error) -> Void,
        onFinalize: @MainActor @escaping @Sendable () -> Void
    ) async {
        if cancelPrevious {
            queue.sync { currentJob?.cancel() }
        } else {
            let previousJob = queue.sync { currentJob }
            await previousJob?.value
        }

        let newJob = Task {
            defer { queue.sync { currentJob = nil } }
            do {
                try await operation()
            } catch {
                await MainActor.run { onError(error) }
            }
        }
        queue.sync { currentJob = newJob }
        await newJob.value

        // 保证最小 busy 时长，让 SwiftUI observation 有足够时间窗反映 .busy 状态。
        if #available(iOS 27.0, macCatalyst 27.0, *) {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
        await MainActor.run(body: onFinalize)
    }

    func cancelAll() {
        queue.sync {
            currentJob?.cancel()
            currentJob = nil
        }
    }

    // MARK: Private

    private let queue = DispatchQueue(label: "com.pizzastudio.JobExecutor")
    private var currentJob: Task<Void, Never>?
}

// MARK: - TaskManagedVM

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Observable @MainActor
open class TaskManagedVM: TaskManagedVMProtocol {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var taskState: ManagedTaskState = .standby
    public var currentError: Error?

    /// 可被子类赋值的 error handler。
    @ObservationIgnored public var assignableErrorHandlingTask: @Sendable (Error) -> Void = { _ in }

    /// 保留以维持 public API 兼容。状态管理已移交 `JobExecutor`。
    @ObservationIgnored public var task: Task<Void, Never>?

    @ObservationIgnored public let executor = JobExecutor()
}

// MARK: - TaskManagedVMBackported

@available(iOS 14.0, macCatalyst 14.0, *)
@MainActor
open class TaskManagedVMBackported: TaskManagedVMProtocol, ObservableObject {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @Published public var taskState: ManagedTaskState = .standby
    @Published public var currentError: Error?

    /// 可被子类赋值的 error handler。
    public var assignableErrorHandlingTask: @Sendable (Error) -> Void = { _ in }

    /// 保留以维持 public API 兼容。状态管理已移交 `JobExecutor`。
    public var task: Task<Void, Never>?

    public let executor = JobExecutor()
}

// MARK: - TaskManagedVMProtocol

@available(iOS 14.0, macCatalyst 14.0, *)
@MainActor
public protocol TaskManagedVMProtocol: AnyObject, Sendable {
    typealias State = ManagedTaskState
    typealias SendableErrorHandler = @MainActor @Sendable (any Error) -> Void
    var taskState: State { get set }
    var currentError: Error? { get set }
    var assignableErrorHandlingTask: @Sendable (Error) -> Void { get set }
    var task: Task<Void, Never>? { get set }
    var executor: JobExecutor { get }

    func forceStopTheTask()
    func handleError(_ error: Error)
    func fireTask<each T: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)?,
        preparationTask: (() -> Void)?,
        shouldAnimatePreparationTask: Bool,
        cancelPreviousTask: Bool,
        givenTask: @escaping @MainActor @Sendable () async throws -> (repeat each T)?,
        completionHandler: (@MainActor @Sendable ((repeat each T)?) -> Void)?,
        errorHandler: SendableErrorHandler?
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
    /// 兼容旧接口，强制取消任务。
    public func forceStopTheTask() {
        executor.cancelAll()
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
            taskState = .standby
        }
        assignableErrorHandlingTask(error)
        executor.cancelAll()
        task = nil
    }

    public func fireTask<each T: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)? = nil,
        preparationTask: (() -> Void)? = nil,
        shouldAnimatePreparationTask: Bool = true,
        cancelPreviousTask: Bool = true,
        givenTask: @escaping @MainActor @Sendable () async throws -> (repeat each T)?,
        completionHandler: (@MainActor @Sendable ((repeat each T)?) -> Void)? = nil,
        errorHandler: SendableErrorHandler? = nil
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
            if shouldAnimatePreparationTask { preparationTask?() }
        }
        if !shouldAnimatePreparationTask { preparationTask?() }

        Task { [weak self] in
            guard let self else { return }
            await executor.enqueue(
                cancelPrevious: cancelPreviousTask,
                operation: {
                    let retrieved = try await givenTask()
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        withAnimation {
                            if let retrieved { completionHandler?(retrieved) }
                            currentError = nil
                        }
                    }
                },
                onError: { [weak self] error in
                    guard let self else { return }
                    if let errorHandler {
                        errorHandler(error)
                    } else {
                        handleError(error)
                    }
                },
                onFinalize: { [weak self] in
                    guard let self else { return }
                    withAnimation { taskState = .standby }
                    task = nil
                }
            )
        }
    }
}
