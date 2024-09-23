// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import SwiftUI

@Observable
open class TaskManagedViewModel {
    // MARK: Lifecycle

    @MainActor
    public init() {}

    // MARK: Public

    public enum State: String, Sendable, Hashable, Identifiable {
        case busy
        case standBy

        // MARK: Public

        public var id: String { rawValue }
    }

    public var task: Task<Void, Never>?
    @MainActor public var taskState: State = .standBy
    @MainActor public var currentError: Error?
    /// 这是能够用来干涉父 class 里面的 errorHanler 的唯一途径。
    @MainActor public var assignableErrorHandlingTask: ((Error) -> Void) = { _ in }

    /// 不要在子 class 内 override 这个方法，因为一点儿屌用也没有。
    /// 除非你在子 class 内也复写了 fireTask()，否则其预设的 Error 处理函式永远都是父 class 的。
    ///
    /// 正确方法是在子 class 内直接改写 `super.assignableErrorHandlingTask` 的资料值。
    /// 或者你可以在 fireTask 的参数里面就地指定如何处理错误（但与之有关的动画与状态控制得自己搞）。
    ///
    /// 你可以在其中用 `if error is CancellationError` 处理与任务取消有关的错误。
    @MainActor
    public func handleError(_ error: Error) {
        withAnimation {
            currentError = error
            taskState = .standBy
        }
        assignableErrorHandlingTask(error)
        task?.cancel()
    }

    @MainActor
    public func fireTask<T: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)? = nil,
        animatedPreparationTask: (() -> Void)? = nil,
        cancelPreviousTask: Bool = true,
        givenTask: @escaping () async throws -> T?,
        completionHandler: ((T?) -> Void)? = nil,
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
            taskState = .busy
            currentError = nil
            animatedPreparationTask?()
        }
        Task {
            if cancelPreviousTask {
                task?.cancel() // 按需取消既有任务。
            } else {
                await task?.value // 等待既有任务执行完毕。
            }
            task = Task {
                do {
                    let retrieved = try await givenTask()
                    Task { @MainActor in
                        withAnimation {
                            if let retrieved {
                                completionHandler?(retrieved)
                            }
                            taskState = .standBy
                            currentError = nil
                        }
                    }
                } catch {
                    Task { @MainActor in
                        (errorHandler ?? handleError)(error) // 处理其他的错误。
                    }
                }
            }
        }
    }

    @MainActor
    public func fireTask<T1: Sendable, T2: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: () -> Void)? = nil,
        cancelPreviousTask: Bool = true,
        givenTask: @escaping () async throws -> (T1, T2)?,
        completionHandler: ((T1, T2) -> Void)? = nil,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        if let prerequisite, !prerequisite.condition {
            withAnimation {
                prerequisite.notMetHandler()
            }
            return
        }
        withAnimation {
            taskState = .busy
            currentError = nil
        }
        Task {
            if cancelPreviousTask {
                task?.cancel() // Cancel previous task if needed
            } else {
                await task?.value // Wait for previous task to complete
            }
            task = Task {
                do {
                    let retrieved = try await givenTask()
                    Task { @MainActor in
                        withAnimation {
                            if let retrieved {
                                completionHandler?(retrieved.0, retrieved.1)
                            }
                            taskState = .standBy
                            currentError = nil
                        }
                    }
                } catch {
                    Task { @MainActor in
                        (errorHandler ?? handleError)(error) // Handle other errors
                    }
                }
            }
        }
    }
}
