// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - URLRequestHelper

/// Abstract class help generate api url request
enum URLRequestHelper {
    // MARK: Public

    /// Calculate the DS used in url request headers
    /// - Parameters:
    ///   - region: the region of account. `.china` for miyoushe and `.global` for hoyolab.
    ///   - queries: query items of url request
    ///   - body: body of this url request
    /// - Returns: `ds` used in url request headers
    public static func getDS(region: HoYo.AccountRegion, query: String, body: Data? = nil) -> String {
        let salt: String = URLRequestConfig.salt(region: region)

        let epochSeconds = Date().timeIntervalSince1970.asIntIfFinite() ?? 0
        let time = String(epochSeconds)
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

    /// Calculate the DS used by miyoushe App-end routes (e.g. K2 salt).
    /// - Parameter salt: App-end salt.
    /// - Returns: `ds` used in url request headers.
    public static func getAppSignDS(salt: String) -> String {
        appSignDS(salt: salt, time: epochSecondsAsString(), nonce: generateSignNonce())
    }

    /// Calculate the DS used by the V2 passport token exchange, which signs the request body.
    /// - Parameters:
    ///   - salt: the DS salt of the passport exchange route.
    ///   - body: the exact request body which will be sent.
    /// - Returns: `ds` used in url request headers.
    public static func getSignedBodyDS(salt: String, body: String) -> String {
        signedBodyDS(salt: salt, body: body, time: epochSecondsAsString(), nonce: generateSignNonce())
    }

    // MARK: Internal

    static func appSignDS(salt: String, time: String, nonce: String) -> String {
        "\(time),\(nonce),\("salt=\(salt)&t=\(time)&r=\(nonce)".md5)"
    }

    static func signedBodyDS(salt: String, body: String, time: String, nonce: String) -> String {
        "\(time),\(nonce),\("salt=\(salt)&t=\(time)&r=\(nonce)&b=\(body)&q=".md5)"
    }

    static func generateSignNonce() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< 6).map { _ in characters.randomElement() ?? "0" })
    }

    // MARK: Private

    private static func epochSecondsAsString() -> String {
        String(Date().timeIntervalSince1970.asIntIfFinite() ?? 0)
    }
}

extension HoYo {
    private static let taskBuffer: URLAsyncTaskStack = .init()

    public static func waitFor300ms() async {
        guard !Pizza.isNotMainApp else { return }
        await Self.taskBuffer.addTask {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms sleep
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
                PZLog.error("Task failed with error: \(error)")
            }
        }
    }
}
