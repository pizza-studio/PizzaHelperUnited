// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if ENABLE_ININTENTS_BACKPORTS

import Intents
import PZAccountKit
import PZWidgetsKit
import WallpaperKit

// MARK: - INIntentHandler

public class INIntentHandler: INExtension {}

// MARK: SelectDualProfileIntentHandling

@available(iOS 16.2, macCatalyst 16.2, *)
extension INIntentHandler: SelectDualProfileIntentHandling {
    public func provideChosenBackgroundsOptionsCollection(for intent: SelectDualProfileIntent) async throws
        -> INObjectCollection<INWidgetBackgroundEntity> {
        let queried = try await WidgetBackgroundAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INWidgetBackgroundEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func provideProfileSlot1OptionsCollection(for intent: SelectDualProfileIntent) async throws
        -> INObjectCollection<INAccountIntentEntity> {
        let queried = try await AccountIntentAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INAccountIntentEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func provideProfileSlot2OptionsCollection(for intent: SelectDualProfileIntent) async throws
        -> INObjectCollection<INAccountIntentEntity> {
        let queried = try await AccountIntentAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INAccountIntentEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func defaultProfileSlot1(for intent: SelectDualProfileIntent) -> INAccountIntentEntity? {
        nil
    }

    public func defaultProfileSlot2(for intent: SelectDualProfileIntent) -> INAccountIntentEntity? {
        nil
    }

    public func defaultChosenBackgrounds(for intent: SelectDualProfileIntent) -> [INWidgetBackgroundEntity]? {
        []
    }
}

// MARK: SelectAccountIntentHandling

@available(iOS 16.2, macCatalyst 16.2, *)
extension INIntentHandler: SelectAccountIntentHandling {
    public func provideChosenBackgroundsOptionsCollection(for intent: SelectAccountIntent) async throws
        -> INObjectCollection<INWidgetBackgroundEntity> {
        let queried = try await WidgetBackgroundAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INWidgetBackgroundEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func provideAccountIntentOptionsCollection(for intent: SelectAccountIntent) async throws
        -> INObjectCollection<INAccountIntentEntity> {
        let queried = try await AccountIntentAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INAccountIntentEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func defaultAccountIntent(for intent: SelectAccountIntent) -> INAccountIntentEntity? {
        nil
    }

    public func defaultChosenBackgrounds(for intent: SelectAccountIntent) -> [INWidgetBackgroundEntity]? {
        []
    }
}

// MARK: SelectOnlyAccountIntentHandling

@available(iOS 16.2, macCatalyst 16.2, *)
extension INIntentHandler: SelectOnlyAccountIntentHandling {
    public func provideAccountOptionsCollection(for intent: SelectOnlyAccountIntent) async throws
        -> INObjectCollection<INAccountIntentEntity> {
        let queried = try await AccountIntentAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INAccountIntentEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func defaultAccount(for intent: SelectOnlyAccountIntent) -> INAccountIntentEntity? {
        nil
    }
}

// MARK: SelectAccountAndShowWhichInfoIntentHandling

@available(iOS 16.2, macCatalyst 16.2, *)
extension INIntentHandler: SelectAccountAndShowWhichInfoIntentHandling {
    public func provideAccountOptionsCollection(for intent: SelectAccountAndShowWhichInfoIntent) async throws
        -> INObjectCollection<INAccountIntentEntity> {
        let queried = try await AccountIntentAppEntity.defaultQuery.suggestedEntities()
        let returnables = queried.map {
            INAccountIntentEntity(identifier: $0.id, display: $0.displayString)
        }
        return .init(items: returnables)
    }

    public func defaultAccount(for intent: SelectAccountAndShowWhichInfoIntent) -> INAccountIntentEntity? {
        nil
    }
}

#endif
