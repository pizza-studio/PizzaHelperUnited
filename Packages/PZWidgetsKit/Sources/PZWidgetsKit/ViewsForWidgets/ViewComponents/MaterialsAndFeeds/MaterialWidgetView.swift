// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import GITodayMaterialsKit
import SwiftUI

// MARK: - MaterialWidgetView

@available(watchOS, unavailable)
public struct MaterialWidgetView<RefreshIntent: AppIntent>: View {
    // MARK: Lifecycle

    public init(
        entry: MaterialWidgetEntry,
        refreshIntent: RefreshIntent?
    ) {
        self.entry = entry
        self.refreshIntent = refreshIntent
    }

    // MARK: Public

    public let entry: MaterialWidgetEntry

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                WeekdayDisplayView()
                Spacer()
                ZStack(alignment: .trailing) {
                    if entry.materialWeekday != nil {
                        MaterialView(alternativeLayout: true)
                    } else {
                        Image(systemSymbol: .checkmarkCircleFill)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .legibilityShadow(isText: false)
                    }
                }
                .frame(height: 35)
            }
            .frame(height: 40)
            .padding(.bottom, 12)
            OfficialFeedList4WidgetsView(
                events: entry.events,
                showLeadingBorder: true,
                refreshIntent: refreshIntent
            )
        }
        .environment(\.colorScheme, .dark)
        .pzWidgetContainerBackground(viewConfig: viewConfig)
    }

    // MARK: Private

    private let refreshIntent: RefreshIntent?

    private let viewConfig: WidgetViewConfig = {
        var result = WidgetViewConfig()
        result.randomBackground = false
        result.selectedBackgrounds = [
            WidgetBackground.randomNamecardBackground4Game(.genshinImpact),
        ]
        result.isDarkModeRespected = true
        return result
    }()
}

// MARK: - MaterialView

@available(watchOS, unavailable)
public struct MaterialView: View {
    // MARK: Lifecycle

    public init(alternativeLayout: Bool = false, today: GITodayMaterial.AvailableWeekDay? = nil) {
        self.alternativeLayout = alternativeLayout
        self.today = today ?? .today()
    }

    // MARK: Public

    public var body: some View {
        GITodayMaterialsView4Widgets(
            alternativeLayout: alternativeLayout,
            today: today
        ) {
            Text("pzWidgetsKit.material.sunday", bundle: .module)
                .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
                .legibilityShadow()
        }
    }

    // MARK: Private

    private let alternativeLayout: Bool
    private var today: GITodayMaterial.AvailableWeekDay? = .today()
}
