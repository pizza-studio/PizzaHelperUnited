// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
// @_exported import PZIntentKit
import SwiftUI
import WidgetKit

typealias EventModel = GIOngoingEvents.EventList.EventModel
typealias MaterialWeekday = GITodayMaterial.AvailableWeekDay

// MARK: - MaterialWidgetEntry

struct MaterialWidgetEntry: TimelineEntry {
    // MARK: Lifecycle

    init(events: [EventModel]?) {
        self.date = Date()
        self.materialWeekday = .today()
        self.talentMateirals = TalentMaterialProvider(weekday: materialWeekday)
            .todaysMaterials
        self.weaponMaterials = WeaponMaterialProvider(weekday: materialWeekday)
            .todaysMaterials
        self.events = events
    }

    // MARK: Internal

    let date: Date
    let materialWeekday: MaterialWeekday?
    let talentMateirals: [GITodayMaterial]
    let weaponMaterials: [GITodayMaterial]
    let events: [EventModel]?
}

// MARK: - WeaponMaterialProvider

struct WeaponMaterialProvider {
    var weekday: MaterialWeekday? = .today()

    var todaysMaterials: [GITodayMaterial] {
        GITodayMaterial.bundledData.filter {
            $0.availableWeekDay == weekday && $0.isWeapon
        }
    }
}

// MARK: - TalentMaterialProvider

struct TalentMaterialProvider {
    var weekday: MaterialWeekday? = .today()

    var todaysMaterials: [GITodayMaterial] {
        GITodayMaterial.bundledData.filter {
            $0.availableWeekDay == weekday && !$0.isWeapon
        }
    }
}

// MARK: - MaterialWidgetProvider

struct MaterialWidgetProvider: TimelineProvider {
    typealias Entry = MaterialWidgetEntry

    func placeholder(in context: Context) -> MaterialWidgetEntry {
        .init(events: nil)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping @Sendable (MaterialWidgetEntry) -> Void
    ) {
        Task {
            switch await GIOngoingEvents.fetch() {
            case let .success(data):
                completion(.init(events: .init(data.event.values)))
            case .failure:
                completion(.init(events: nil))
            }
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<MaterialWidgetEntry>) -> Void
    ) {
        Task {
            switch await GIOngoingEvents.fetch() {
            case let .success(data):
                completion(.init(
                    entries: [.init(events: .init(data.event.values))],
                    policy: .after(
                        Calendar.current
                            .date(byAdding: .hour, value: 4, to: Date())!
                    )
                ))
            case .failure:
                completion(
                    .init(
                        entries: [.init(events: nil)],
                        policy: .after(
                            Calendar.current
                                .date(byAdding: .hour, value: 1, to: Date())!
                        )
                    )
                )
            }
        }
    }
}
