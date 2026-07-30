// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import OSLog

// MARK: - PZDiagnostics

/// 全專案共用的診斷 Logger，OS 26+ 不會 redact 內容。
public enum PZDiagnostics {
    public static let logger = Logger(
        subsystem: sharedBundleIDHeader,
        category: "PZDiagnostics"
    )
}

// MARK: - PZLog

public enum PZLog {
    public static func debug(_ msg: String) {
        PZDiagnostics.logger.debug("\(msg)")
    }

    public static func info(_ msg: String) {
        PZDiagnostics.logger.info("\(msg)")
    }

    public static func warning(_ msg: String) {
        PZDiagnostics.logger.warning("\(msg)")
    }

    public static func error(_ msg: String) {
        PZDiagnostics.logger.error("\(msg)")
    }

    public static func fault(_ msg: String) {
        PZDiagnostics.logger.fault("\(msg)")
    }

    public static func critical(_ msg: String) {
        PZDiagnostics.logger.critical("\(msg)")
    }

    public static func notice(_ msg: String) {
        PZDiagnostics.logger.notice("\(msg)")
    }
}
