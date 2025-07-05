// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import UniformTypeIdentifiers

/// 该结构仅用作导出内容之用途，导出披萨助手的某些原始抽卡资料供诊断之用途。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct PZGachaEntrySendableDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        self.model = try JSONDecoder().decode(
            [PZGachaEntrySendable].self,
            from: configuration.file.regularFileContents!
        )
    }

    public init(dataList: [PZGachaEntrySendable]) {
        self.model = dataList
    }

    // MARK: Public

    public static let readableContentTypes: [UTType] = [.json]

    public let model: Codable & Sendable

    public var fileNameStem: String {
        let dateFormatter = DateFormatter.forUIGFFileName
        return "GESD_\(dateFormatter.string(from: Date()))"
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(model)
        return FileWrapper(regularFileWithContents: data)
    }
}
