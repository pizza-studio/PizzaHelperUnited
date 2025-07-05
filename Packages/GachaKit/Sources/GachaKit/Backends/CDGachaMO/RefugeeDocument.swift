// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZCoreDataKit4GachaEntries
import PZCoreDataKit4LocalAccounts
import SwiftUI
import UniformTypeIdentifiers

// MARK: - RefugeeFile

public struct RefugeeFile: Codable, Hashable, Sendable {
    // MARK: Lifecycle

    public init(
        oldProfiles4GI: [AccountMO4GI] = [],
        oldGachaEntries4GI: [CDGachaMO4GI] = []
    ) {
        self.oldProfiles4GI = oldProfiles4GI
        self.oldGachaEntries4GI = oldGachaEntries4GI
    }

    // MARK: Public

    public var oldProfiles4GI: [AccountMO4GI]
    public var oldGachaEntries4GI: [CDGachaMO4GI]
}

// MARK: - RefugeeDocument

public struct RefugeeDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let srgfModel = try JSONDecoder().decode(RefugeeFile.self, from: configuration.file.regularFileContents!)
        self.model = srgfModel
    }

    public init(file: RefugeeFile) {
        self.model = file
    }

    // MARK: Public

    public static var readableContentTypes: [UTType] { [.json] }

    public let model: RefugeeFile

    public let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.locale = .init(identifier: "en_US_POSIX")
        result.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return result
    }()

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(model)
        return FileWrapper(regularFileWithContents: data)
    }
}
