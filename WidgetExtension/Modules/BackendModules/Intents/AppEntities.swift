// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import WallpaperKit

// MARK: - AccountIntentAppEntity

/// Local Profile Intent Entity. Named 'Account' here for compatibility purposes.
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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
            let result = accounts.map {
                Self.Entity(
                    id: $0.uuid.uuidString,
                    displayString: $0.name + "\n(\($0.uidWithGame))"
                )
            }
            PZLog.info(
                "[AccountEntity.entities] requested=\(identifiers.count) matched=\(result.count)"
            )
            return result
        }

        public func suggestedEntities() async throws -> Self.Result {
            let profiles = PZWidgets.getAllProfiles()
            let result = profiles.map {
                Self.Entity(
                    id: $0.uuid.uuidString,
                    displayString: $0.name + "\n(\($0.uidWithGame))"
                )
            }
            PZLog.info("[AccountEntity.suggested] count=\(result.count)")
            return result
        }

        public func defaultResult() async -> Entity? {
            try? await suggestedEntities().first
        }
    }

    public static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "appEntity.localProfile")

    public static let defaultQuery = AccountIntentAppEntityQuerier()

    public var id: String // if your identifier is not a String, conform the entity to EntityIdentifierConvertible.
    public var displayString: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }
}

// MARK: - WidgetBackgroundAppEntity

@available(iOS 17.0, macCatalyst 17.0, *)
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
            let matched = WidgetBackground.allOptions.filter { identifiers.contains($0.id) }
            let result: [Self.Entity] = matched.map {
                .init(id: $0.id, displayString: $0.displayString)
            }
            PZLog.info(
                "[WallpaperEntity.entities] requested=\(identifiers.count) matched=\(result.count)"
            )
            return result
        }

        public func suggestedEntities() async throws -> Self.Result {
            let userWallpaperCount = UserWallpaper.allCases.count
            let allOptions = WidgetBackground.allOptions
            let result: Self.Result = allOptions.map {
                .init(id: $0.id, displayString: $0.displayString)
            }
            PZLog.info(
                "[WallpaperEntity.suggested] userWPCnt=\(userWallpaperCount) totalOptions=\(allOptions.count)"
            )
            return result
        }

        public func defaultResult() async -> Self.Entity? {
            WidgetBackground.defaultBackground.asAppEntity
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension WidgetBackground {
    public var asAppEntity: WidgetBackgroundAppEntity {
        .init(id: id, displayString: displayString)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension WidgetBackgroundAppEntity {
    public var asRawEntity: WidgetBackground {
        .init(id: id, displayString: displayString)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Array where Element == WidgetBackgroundAppEntity {
    public var asRawEntitySet: Set<WidgetBackground> {
        Set(map(\.asRawEntity))
    }
}
