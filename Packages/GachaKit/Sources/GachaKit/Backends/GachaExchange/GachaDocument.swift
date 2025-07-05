// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import UniformTypeIdentifiers

/// 该结构仅用作导出内容之用途。
/// 由于 SwiftUI 给单个 View 连续挂接 fileExporter 的时候只有最后挂接的会生效的缘故，
/// 必须让 SRGF 与 UIGF 混用一个 Document 结构。
@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public struct GachaDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let uigfModel = try? JSONDecoder().decode(UIGFv4.self, from: configuration.file.regularFileContents!)
        if let uigfModel {
            self.model = uigfModel
            self.fileNameStem = uigfModel.defaultFileNameStem
        } else {
            let srgfModel = try JSONDecoder().decode(SRGFv1.self, from: configuration.file.regularFileContents!)
            self.model = srgfModel
            self.fileNameStem = srgfModel.defaultFileNameStem
        }
    }

    public init(model: Codable & Sendable, fileNameStem: String) {
        self.model = model
        self.fileNameStem = fileNameStem
    }

    public init(theUIGFv4: UIGFv4) {
        self.model = theUIGFv4
        self.fileNameStem = theUIGFv4.defaultFileNameStem
    }

    public init(theSRGFv1: SRGFv1) {
        self.model = theSRGFv1
        self.fileNameStem = theSRGFv1.defaultFileNameStem
    }

    // MARK: Public

    public static let readableContentTypes: [UTType] = [.json]

    public let model: Codable & Sendable

    public var fileNameStem: String

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
