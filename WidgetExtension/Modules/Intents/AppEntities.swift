// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - AccountIntentAppEntity

/// Local Profile Intent Entity. Named 'Account' here for compatibility purposes.
public struct AccountIntentAppEntity: AppEntity {
    // MARK: Lifecycle

    public init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    // MARK: Public

    public struct AccountIntentAppEntityQuerier: EntityQuery {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public typealias Entity = AccountIntentAppEntity

        public func entities(for identifiers: [Self.Entity.ID]) async throws -> [Self.Entity] {
            let accounts = PZWidgets.getAllProfiles().filter {
                identifiers.contains($0.uuid.uuidString)
            }
            return accounts.map {
                Self.Entity(
                    id: $0.uuid.uuidString,
                    displayString: $0.name + "\n(\($0.uidWithGame))"
                )
            }
        }

        public func suggestedEntities() async throws -> Self.Result {
            PZWidgets.getAllProfiles().map {
                Self.Entity(
                    id: $0.uuid.uuidString,
                    displayString: $0.name + "\n(\($0.uidWithGame))"
                )
            }
        }

        public func defaultResult() async -> Entity? {
            try? await suggestedEntities().first
        }
    }

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "appEntity.localeProfile")

    public static let defaultQuery = AccountIntentAppEntityQuerier()

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

    public struct WidgetBackgroundAppEntityQuerier: EntityQuery {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public typealias Entity = WidgetBackgroundAppEntity

        public func entities(for identifiers: [Self.Entity.ID]) async throws -> [Self.Entity] {
            let matched = BackgroundOptions.allOptions.filter { identifiers.contains($0.0) }
            return matched.map {
                .init(id: $0.0, displayString: $0.1)
            }
        }

        public func suggestedEntities() async throws -> Self.Result {
            BackgroundOptions.allOptions.map {
                .init(id: $0.0, displayString: $0.1)
            }
        }

        public func defaultResult() async -> Self.Entity? {
            Entity.defaultBackground
        }
    }

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "appEntity.widgetBackground")

    public static let defaultQuery = WidgetBackgroundAppEntityQuerier()

    public var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    public var displayString: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
}

// MARK: - WidgetUserWallpaperAppEntity

public struct WidgetUserWallpaperAppEntity: AppEntity {
    // MARK: Lifecycle

    public init(id: String, displayString: String) {
        self.id = id
        self.displayString = displayString
    }

    // MARK: Public

    public struct WidgetUserWallpaperAppEntityQuerier: EntityQuery {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public typealias Entity = WidgetUserWallpaperAppEntity

        public func entities(for identifiers: [Self.Entity.ID]) async throws -> [Self.Entity] {
            Entity.allOptions.filter {
                identifiers.contains($0.id)
            }
        }

        public func suggestedEntities() async throws -> Self.Result {
            Entity.allOptions
        }

        public func defaultResult() async -> Self.Entity? {
            Entity.defaultWallpaper
        }
    }

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "appEntity.widgetUserWallpaper")

    public static let defaultQuery = WidgetUserWallpaperAppEntityQuerier()

    public var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    public var displayString: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
}
