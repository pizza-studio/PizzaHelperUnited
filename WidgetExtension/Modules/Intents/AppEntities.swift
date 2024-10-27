// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation

// MARK: - AccountIntentAppEntity

/// Local Profile Intent Entity. Named 'Account' here for compatibility purposes.
public struct AccountIntentAppEntity: AppEntity {
    // MARK: Lifecycle

    public init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    // MARK: Public

    public struct AccountIntentAppEntityQuery: EntityQuery {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public func entities(for identifiers: [AccountIntentAppEntity.ID]) async throws -> [AccountIntentAppEntity] {
            // TODO: return AccountIntentAppEntity entities with the specified identifiers here.
            []
        }

        public func suggestedEntities() async throws -> [AccountIntentAppEntity] {
            // TODO: return likely AccountIntentAppEntity entities here.
            // This method is optional; the default implementation returns an empty array.
            []
        }
    }

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "appEntity.localeProfile")

    public static let defaultQuery = AccountIntentAppEntityQuery()

    public var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    public var displayString: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
}

// MARK: - WidgetBackgroundAppEntity

public struct WidgetBackgroundAppEntity: AppEntity {
    // MARK: Lifecycle

    public init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    // MARK: Public

    public struct WidgetBackgroundAppEntityQuery: EntityQuery {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public func entities(for identifiers: [WidgetBackgroundAppEntity.ID]) async throws
            -> [WidgetBackgroundAppEntity] {
            // TODO: return WidgetBackgroundAppEntity entities with the specified identifiers here.
            []
        }

        public func suggestedEntities() async throws -> [WidgetBackgroundAppEntity] {
            // TODO: return likely WidgetBackgroundAppEntity entities here.
            // This method is optional; the default implementation returns an empty array.
            []
        }
    }

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "appEntity.widgetBackground")

    public static let defaultQuery = WidgetBackgroundAppEntityQuery()

    public var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    public var displayString: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
}
