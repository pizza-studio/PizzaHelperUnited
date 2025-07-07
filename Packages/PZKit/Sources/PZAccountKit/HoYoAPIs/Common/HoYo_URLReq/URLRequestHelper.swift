// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - URLRequestHelper

/// Abstract class help generate api url request
@available(iOS 15.0, macCatalyst 15.0, *)
enum URLRequestHelper {
    /// Calculate the DS used in url request headers
    /// - Parameters:
    ///   - region: the region of account. `.china` for miyoushe and `.global` for hoyolab.
    ///   - queries: query items of url request
    ///   - body: body of this url request
    /// - Returns: `ds` used in url request headers
    public static func getDS(region: HoYo.AccountRegion, query: String, body: Data? = nil) -> String {
        let salt: String = URLRequestConfig.salt(region: region)

        let time = String(Int(Date().timeIntervalSince1970))
        let randomNumber = String(Int.random(in: 100_000 ..< 200_000))

        let bodyString: String
        if let body = body {
            bodyString = String(data: body, encoding: .utf8) ?? ""
        } else {
            bodyString = ""
        }

        let verification = "salt=\(salt)&t=\(time)&r=\(randomNumber)&b=\(bodyString)&q=\(query)".md5

        return time + "," + randomNumber + "," + verification
    }
}

extension HoYo {
    private static let taskBuffer: URLAsyncTaskStack = .init()

    public static func waitFor300ms() async {
        guard !Pizza.isWidgetExtension else { return }
        await Self.taskBuffer.addTask {
            try await Task.sleep(nanoseconds: 300_000_000) // 300ms sleep
        }
    }
}

// MARK: - URLAsyncTaskStack

private actor URLAsyncTaskStack {
    // MARK: Internal

    func addTask(_ task: @escaping () async throws -> Void) async {
        // Add the task to the queue and await its execution in sequence
        tasks.append(task)

        // If this is the only task, start processing the queue
        if tasks.count == 1 {
            await processNextTask()
        }
    }

    func cancelAllTasks() {
        tasks.removeAll()
    }

    // MARK: Private

    private var tasks: [() async throws -> Void] = []

    private func processNextTask() async {
        while !tasks.isEmpty {
            let currentTask = tasks.removeFirst()
            do {
                // Execute the current task
                try await currentTask()
            } catch let error as NSError {
                print("Task failed with error: \(error)")
            }
        }
    }
}
