// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftData

extension ModelActor {
    public func asyncInsert<T: PersistentModel>(_ model: T) throws {
        modelContext.insert(model)
    }

    public func asyncDelete<T: PersistentModel>(_ model: T) throws {
        modelContext.delete(model)
    }

    public func asyncSave() throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }

    public func asyncRollback() {
        if modelContext.hasChanges {
            modelContext.rollback()
        }
    }

    public func asyncTransaction(block: (ModelContext) throws -> Void) throws {
        try modelContext.transaction {
            try block(modelContext)
        }
    }

    public func asyncTransaction(block: (ModelContext) -> Void) throws {
        try modelContext.transaction {
            block(modelContext)
        }
    }
}
