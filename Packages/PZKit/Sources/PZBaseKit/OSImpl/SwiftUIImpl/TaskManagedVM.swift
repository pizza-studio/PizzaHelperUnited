// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
@MainActor
open class TaskManagedVM {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public enum State: String, Sendable, Hashable, Identifiable {
        case busy
        case standby

        // MARK: Public

        public var id: String { rawValue }
    }

    public var taskState: State = .standby
    public var currentError: Error?
    /// 这是能够用来干涉父 class 里面的 errorHanler 的唯一途径。
    @ObservationIgnored public var assignableErrorHandlingTask: ((Error) -> Void) = { _ in }

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
            task = Task(priority: .background) { [weak self] in
                if cancelPreviousTask {
                    previousTask?.cancel() // 按需取消既有任务。
                } else {
                    await previousTask?.value // 等待既有任务执行完毕。
                }
                do {
                    let retrieved = try await givenTask()
                    Task { @MainActor [weak self] in
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
        }
    }

    // MARK: Private

    @ObservationIgnored private var stateGuard: Task<Void, Never>?
}
