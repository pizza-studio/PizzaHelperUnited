// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

@MainActor
public final class FolderMonitor: ObservableObject {
    // MARK: Lifecycle

    // MARK: - Initialization

    public init(url: URL) {
        self.url = url
    }

    // MARK: - Deinitialization

    deinit {
        // Synchronously cancel monitoring task
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    // MARK: Public

    /// URL for the directory being monitored.
    public let url: URL

    @Published public private(set) var stateHash: UUID = .init()

    // MARK: - Monitoring

    /// Starts monitoring the directory for changes.
    public func startMonitoring() async throws {
        guard !isMonitoring else { return }

        // Create directory if it doesn't exist
        try await createDirectoryIfNeeded()

        isMonitoring = true

        // Start monitoring task
        monitoringTask = Task { @MainActor in
            for await _ in directoryChanges() {
                if !isMonitoring { break }
                self.stateHash = .init()
            }
        }
    }

    /// Stops monitoring the directory.
    public func stopMonitoring() async {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil
    }

    // MARK: Internal

    // MARK: - Error Handling

    enum FolderMonitorError: LocalizedError {
        case notADirectory

        // MARK: Internal

        var errorDescription: String? {
            switch self {
            case .notADirectory:
                return "The specified URL is not a directory"
            }
        }
    }

    // MARK: Private

    /// Task for monitoring the directory.
    // @ObservationIgnored
    private var monitoringTask: Task<Void, Never>?

    /// Flag to control monitoring state.
    // @ObservationIgnored
    private var isMonitoring = false

    // MARK: - Private Methods

    private func createDirectoryIfNeeded() async throws {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        // Check if directory exists
        if !fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
            try fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } else if !isDir.boolValue {
            throw FolderMonitorError.notADirectory
        }
    }

    private func directoryChanges() -> AsyncStream<Void> {
        AsyncStream { continuation in
            Task {
                var lastContents: Set<String> = []

                while !Task.isCancelled {
                    do {
                        // Get current directory contents
                        let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
                        let currentContents = Set(contents)

                        // Check for changes
                        if currentContents != lastContents {
                            continuation.yield(())
                            lastContents = currentContents
                        }

                        // Wait before next check (0.5s)
                        try await Task.sleep(nanoseconds: 500_000_000)
                    } catch {
                        // Handle errors silently or log them
                        try await Task.sleep(nanoseconds: 500_000_000)
                    }
                }

                continuation.finish()
            }
        }
    }
}
