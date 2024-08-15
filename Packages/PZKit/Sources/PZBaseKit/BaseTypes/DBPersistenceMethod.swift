// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - DBPersistenceMethod

public enum DBPersistenceMethod: String, Identifiable, Codable, Hashable {
    case inMemory
    case local
    case cloud

    // MARK: Public

    public var id: String { rawValue }
}
