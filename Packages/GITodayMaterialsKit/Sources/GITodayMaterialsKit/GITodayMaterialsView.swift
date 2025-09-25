// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - GITodayMaterialsView

@available(iOS 16.0, macCatalyst 16.0, *)
@available(watchOS, unavailable)
public struct GITodayMaterialsView<T: View>: View {
    // MARK: Lifecycle

    public init(@ViewBuilder querier: @escaping (Bool, String) -> T) {
        self.data = Material.bundledData
        self.querier = querier
        self.weekday = GITodayMaterial.AvailableWeekDay.today()
    }

    // MARK: Public

    public static var navTitle: String {
        "todayMaterialsKit.navTitle".i18nTodayMaterials
    }

    public var body: some View {
        NavigationStack {
            Form {
                content
                    .listRowMaterialBackground()
            }
            .formStyle(.grouped).disableFocusable()
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Picker("".description, selection: $isWeapon.animation()) {
                        Text("todayMaterialsKit.character.short".i18nTodayMaterials).tag(false)
                        Text("todayMaterialsKit.weapon.short".i18nTodayMaterials).tag(true)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
                if !isAppKit {
                    ToolbarItem(placement: .principal) {
                        Picker("".description, selection: $weekday.animation()) {
                            Text(Material.AvailableWeekDay?.none.localizedName).tag(Material.AvailableWeekDay?.none)
                            ForEach(Material.AvailableWeekDay.allCases) { weekday in
                                let weekday = weekday as Material.AvailableWeekDay?
                                Text(weekday.localizedName).tag(weekday as Material.AvailableWeekDay?)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .fixedSize()
                        // 在正中心位置时，不是玻璃按钮，所以始终启用。
                        .blurMaterialBackground(enabled: true, shape: .capsule)
                    }
                }
            }
            .listContainerBackground()
            .navBarTitleDisplayMode(.large)
            .navigationTitle(Self.navTitle)
        }
        .onAppear {
            if !initialized {
                weekday = GITodayMaterial.AvailableWeekDay.today()
                initialized.toggle()
            }
        }
    }

    // MARK: Internal

    @ViewBuilder var content: some View {
        if isAppKit {
            Picker("".description, selection: $weekday.animation()) {
                Text(Material.AvailableWeekDay?.none.localizedName).tag(Material.AvailableWeekDay?.none)
                ForEach(Material.AvailableWeekDay.allCases) { weekday in
                    let weekday = weekday as Material.AvailableWeekDay?
                    Text(weekday.localizedName).tag(weekday as Material.AvailableWeekDay?)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
        }
        ForEach(materialsFiltered.reversed()) { material in
            HStack {
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
                .frame(maxWidth: .infinity)
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
    private let isAppKit = OS.type == .macOS && !OS.isCatalyst

    private var materialsFiltered: [Material] {
        data.filter {
            guard $0.isWeapon == isWeapon else { return false }
            return $0.availableWeekDay == weekday || weekday == nil
        }
    }
}

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
#Preview {
    NavigationStack {
        GITodayMaterialsView { _, _ in
            EmptyView()
        }
    }
}

#endif
#endif
