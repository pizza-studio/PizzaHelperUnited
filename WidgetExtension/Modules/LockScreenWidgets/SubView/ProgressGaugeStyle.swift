// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - ProgressGaugeStyle

struct ProgressGaugeStyle: GaugeStyle {
    var circleColor: Color = .white

    #if os(watchOS)
    let strokeLineWidth: CGFloat = 4.7
    #else
    let strokeLineWidth: CGFloat = 6
    #endif

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            TotalArc()
                .stroke(
                    circleColor,
                    style: StrokeStyle(
                        lineWidth: strokeLineWidth,
                        lineCap: .round
                    )
                )
                .widgetAccentable()
                .opacity(0.5)
            if configuration.value > 0 {
                Arc(percentage: configuration.value)
                    .stroke(
                        circleColor,
                        style: StrokeStyle(
                            lineWidth: strokeLineWidth,
                            lineCap: .round
                        )
                    )
                    .widgetAccentable()
                    .shadow(radius: 1)
            }
            configuration.currentValueLabel
                .padding(strokeLineWidth * 1.4)
            VStack {
                Spacer()
                configuration.label
                #if os(watchOS)
                    .frame(width: 10, height: 10)
                    .padding(.bottom, -1.5)
                #else
                    .frame(width: 12, height: 12)
                    .padding(.bottom, -1.5)
                #endif
            }
            .widgetAccentable()
        }
        .padding(strokeLineWidth * 1 / 2)
    }
}

// MARK: - TotalArc

struct TotalArc: Shape {
    let startAngle: Angle = .degrees(50)
    let endAngle: Angle = .degrees(130)

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path
    }
}

// MARK: - Arc

struct Arc: Shape {
    let percentage: Double

    func path(in rect: CGRect) -> Path {
        let startAngle: Angle = .degrees(50 - (1 - percentage) * 280)
        let endAngle: Angle = .degrees(130)
        var path = Path()
        let radius = max(rect.size.width, rect.size.height) / 2
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        return path
    }
}
