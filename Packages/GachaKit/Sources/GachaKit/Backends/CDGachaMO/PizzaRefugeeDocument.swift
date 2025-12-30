// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZCoreDataKit4GachaEntries
import PZCoreDataKit4LocalAccounts
import SwiftUI
import UniformTypeIdentifiers

// MARK: - PZRefugeeFile

public struct PZRefugeeFile: Codable, Hashable, Sendable {
    // MARK: Lifecycle

    public init(
        oldProfiles4GI: [AccountMO4GI] = [],
        oldGachaEntries4GI: [CDGachaMO4GI] = [],
        newPZProfiles: [PZProfileSendable] = [],
        newGachaEntries: [PZGachaEntrySendable] = []
    ) {
        self.oldProfiles4GI = oldProfiles4GI
        self.oldGachaEntries4GI = oldGachaEntries4GI
        self.newProfiles = newPZProfiles
        self.newGachaEntries = newGachaEntries
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.newProfiles = (
            try container.decodeIfPresent(
                [PZProfileSendable].self,
                forKey: .newProfiles
            )
        ) ?? []
        self.newGachaEntries = (
            try container.decodeIfPresent(
                [PZGachaEntrySendable].self,
                forKey: .newGachaEntries
            )
        ) ?? []
        self.oldProfiles4GI = try container.decode(
            [AccountMO4GI].self,
            forKey: .oldProfiles4GI
        )
        self.oldGachaEntries4GI = try container.decode(
            [CDGachaMO4GI].self,
            forKey: .oldGachaEntries4GI
        )
    }

    // MARK: Public

    public var newProfiles: [PZProfileSendable]
    public var newGachaEntries: [PZGachaEntrySendable]
    public var oldProfiles4GI: [AccountMO4GI]
    public var oldGachaEntries4GI: [CDGachaMO4GI]

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(newProfiles, forKey: .newProfiles)
        try container.encode(newGachaEntries, forKey: .newGachaEntries)
        try container.encode(oldProfiles4GI, forKey: .oldProfiles4GI)
        try container.encode(oldGachaEntries4GI, forKey: .oldGachaEntries4GI)
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case newProfiles
        case newGachaEntries
        case oldProfiles4GI
        case oldGachaEntries4GI
    }
}

// MARK: - PZRefugeeDocument

public struct PZRefugeeDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let srgfModel = try PropertyListDecoder().decode(
            PZRefugeeFile.self,
            from: configuration.file.regularFileContents ?? .init([])
        )
        self.model = srgfModel
    }

    public init(file: PZRefugeeFile) {
        self.model = file
    }

    // MARK: Public

    public static var readableContentTypes: [UTType] { [.propertyList] }

    public let model: PZRefugeeFile

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try PropertyListEncoder().encode(model)
        return FileWrapper(regularFileWithContents: data)
    }
}
