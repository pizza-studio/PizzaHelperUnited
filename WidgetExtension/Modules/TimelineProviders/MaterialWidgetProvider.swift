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

@available(watchOS, unavailable)
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

@available(watchOS, unavailable)
struct WeaponMaterialProvider {
    var weekday: MaterialWeekday? = .today()

    var todaysMaterials: [GITodayMaterial] {
        GITodayMaterial.bundledData.filter {
            $0.availableWeekDay == weekday && $0.isWeapon
        }
    }
}

// MARK: - TalentMaterialProvider

@available(watchOS, unavailable)
struct TalentMaterialProvider {
    var weekday: MaterialWeekday? = .today()

    var todaysMaterials: [GITodayMaterial] {
        GITodayMaterial.bundledData.filter {
            $0.availableWeekDay == weekday && !$0.isWeapon
        }
    }
}

// MARK: - MaterialWidgetProvider

@available(watchOS, unavailable)
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

@available(watchOS, unavailable)
extension View {
    fileprivate func myWidgetContainerBackground<V: View>(
        withPadding padding: CGFloat,
        @ViewBuilder _ content: @escaping () -> V
    )
        -> some View {
        modifier(ContainerBackgroundModifier(padding: padding, background: content))
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    let padding: CGFloat
    let background: () -> V

    func body(content: Content) -> some View {
        content.containerBackground(for: .widget) {
            background()
        }
    }
}
