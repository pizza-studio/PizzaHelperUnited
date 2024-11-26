// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WallpaperKit

// MARK: - GITodayMaterialsView

@available(watchOS, unavailable)
public struct GITodayMaterialsView<T: View>: View {
    // MARK: Lifecycle

    public init(@ViewBuilder querier: @escaping (Bool, String) -> T) {
        self.data = Material.bundledData
        self.querier = querier
        switch Calendar.current.component(.weekday, from: Date.now) {
        case 2, 5: self.weekday = .MonThu
        case 3, 6: self.weekday = .TueFri
        case 4, 7: self.weekday = .WedSat
        default: self.weekday = nil
        }
    }

    // MARK: Public

    public static var navTitle: String {
        "todayMaterialsKit.navTitle".i18nTodayMaterials
    }

    public var body: some View {
        Form {
            content
                .listRowMaterialBackground()
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navBarTitleDisplayMode(.large)
        .navigationTitle(Self.navTitle)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $isWeapon.animation()) {
                    Text("todayMaterialsKit.character.short".i18nTodayMaterials).tag(false)
                    Text("todayMaterialsKit.weapon.short".i18nTodayMaterials).tag(true)
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .background(
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial)
                )
            }
            ToolbarItem(placement: .principal) {
                Picker("".description, selection: $weekday.animation()) {
                    Text(Material.AvailableWeekDay?.none.localizedName).tag(Material.AvailableWeekDay?.none)
                    ForEach(Material.AvailableWeekDay.allCases) { weekday in
                        let weekday = weekday as Material.AvailableWeekDay?
                        Text(weekday.localizedName).tag(weekday as Material.AvailableWeekDay?)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()
                .background(
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial)
                )
            }
        }
        .onAppear {
            if !initialized {
                switch Calendar.current.component(.weekday, from: Date.now) {
                case 2, 5: weekday = .MonThu
                case 3, 6: weekday = .TueFri
                case 4, 7: weekday = .WedSat
                default: weekday = nil
                }
                initialized.toggle()
            }
        }
    }

    // MARK: Internal

    @MainActor var content: some View {
        ForEach(materialsFiltered.reversed()) { material in
            LabeledContent {
                VStack(alignment: .leading, spacing: 4) {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 4) {
                            ForEach(material.costedBy.reversed(), id: \.self) { itemID in
                                querier(material.isWeapon, itemID)
                            }
                        }
                    }
                    HStack {
                        Text(material.localized)
                        Spacer()
                    }
                }
                .frame(height: 96)
            } label: {
                material.iconObj
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
                    .scaleEffect(1)
                    .clipped()
                    .frame(width: 84, height: 96)
                    .corneredTag(
                        verbatim: material.availableWeekDay.localizedName,
                        alignment: .bottom
                    )
            }
        }
    }

    // MARK: Private

    private typealias Material = GITodayMaterial

    @State private var isWeapon: Bool = false
    @State private var weekday: Material.AvailableWeekDay?
    @State private var initialized: Bool = false

    private let data: [Material]
    private let querier: (Bool, String) -> T

    private var materialsFiltered: [Material] {
        data.filter {
            guard $0.isWeapon == isWeapon else { return false }
            return $0.availableWeekDay == weekday || weekday == nil
        }
    }
}

#if DEBUG && !os(watchOS)

#Preview {
    NavigationStack {
        GITodayMaterialsView { _, _ in
            EmptyView()
        }
    }
}

#endif
