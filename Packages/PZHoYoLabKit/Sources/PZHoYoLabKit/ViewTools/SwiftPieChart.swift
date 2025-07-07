// (c) 2021 and onwards Nazar Ilamanov (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)

// Ref: https://github.com/ilamanov/SwiftPieChart
// --------------------
// This SPM is heavily modded by Pizza Studio,
// hence not being imported as an SPM package but direct inclusion.

import Foundation
import SwiftUI

// MARK: - PieChartView

@available(iOS 15.0, macCatalyst 15.0, *)
public struct PieChartView: View {
    // MARK: Lifecycle

    public init(
        values: [Double],
        names: [String],
        formatter: @escaping (Double) -> String,
        colors: [Color] = [Color.blue, Color.green, Color.orange],
        backgroundColor: Color = Color(
            red: 21 / 255,
            green: 24 / 255,
            blue: 30 / 255,
            opacity: 1.0
        ),
        widthFraction: CGFloat = 0.75,
        innerRadiusFraction: CGFloat = 0.60
    ) {
        self.values = values
        self.names = names
        self.formatter = formatter

        self.colors = colors
        self.backgroundColor = backgroundColor
        self.widthFraction = widthFraction
        self.innerRadiusFraction = innerRadiusFraction
    }

    // MARK: Public

    public let values: [Double]
    public let names: [String]
    public let formatter: (Double) -> String

    public var colors: [Color]
    public var backgroundColor: Color

    public var widthFraction: CGFloat
    public var innerRadiusFraction: CGFloat

    public var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    ForEach(0 ..< values.count, id: \.self) { i in
                        PieSlice(pieSliceData: slices[i])
                            .scaleEffect(activeIndex == i ? 1.03 : 1)
                            // iOS 16 开始需要提供 value，这里一律塞 UUID()。
                            .animation(Animation.spring(), value: UUID())
                    }
                    .frame(
                        width: widthFraction * geometry.size.width,
                        height: widthFraction * geometry.size.width
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let radius = 0.5 * widthFraction * geometry.size
                                    .width
                                let diff = CGPoint(
                                    x: value.location.x - radius,
                                    y: radius - value.location.y
                                )
                                let dist = pow(
                                    pow(diff.x, 2.0) + pow(diff.y, 2.0),
                                    0.5
                                )
                                if dist > radius || dist < radius *
                                    innerRadiusFraction {
                                    activeIndex = -1
                                    return
                                }
                                var radians = Double(atan2(diff.x, diff.y))
                                if radians < 0 {
                                    radians = 2 * Double.pi + radians
                                }

                                for (i, slice) in slices.enumerated() {
                                    if radians < slice.endAngle.radians {
                                        activeIndex = i
                                        break
                                    }
                                }
                            }
                            .onEnded { _ in
                                activeIndex = -1
                            }
                    )
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(
                            width: widthFraction * geometry.size
                                .width * innerRadiusFraction,
                            height: widthFraction * geometry.size
                                .width * innerRadiusFraction
                        )

                    VStack {
                        Text(
                            activeIndex == -1 ?
                                String(format: NSLocalizedString(
                                    "pieChart.total",
                                    bundle: .module,
                                    comment: "total"
                                )) : names[activeIndex]
                        )
                        .font(.headline)
                        #if os(iOS) || targetEnvironment(macCatalyst)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .shadow(color: .init(uiColor: .systemBackground), radius: 3)
                        #else
                            .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                            .shadow(color: .init(nsColor: NSColor.controlBackgroundColor), radius: 3)
                        #endif
                        Text(
                            formatter(
                                activeIndex == -1 ? values
                                    .reduce(0, +) : values[activeIndex]
                            )
                        )
                        .font(.title)
                        #if os(iOS) || targetEnvironment(macCatalyst)
                            .shadow(color: .init(uiColor: .systemBackground), radius: 3)
                        #else
                            .shadow(color: .init(nsColor: NSColor.controlBackgroundColor), radius: 3)
                        #endif
                    }
                }
                PieChartRows(
                    colors: colors,
                    names: names,
                    values: values.map { formatter($0) },
                    percents: values
                        .map {
                            String(
                                format: "%.0f%%",
                                $0 * 100 / values.reduce(0, +)
                            )
                        }
                )
            }
            .background(backgroundColor)
            .foregroundColor(Color.primary)
        }
    }

    // MARK: Internal

    var slices: [PieSliceData] {
        let sum = values.reduce(0, +)
        var endDeg: Double = 0
        var tempSlices: [PieSliceData] = []

        for (i, value) in values.enumerated() {
            let degrees: Double = value * 360 / sum
            if degrees < 18 {
                tempSlices.append(PieSliceData(
                    startAngle: Angle(degrees: endDeg),
                    endAngle: Angle(degrees: endDeg + degrees),
                    text: String(format: "%.0f%%", value * 100 / sum),
                    color: colors[i],
                    isIgnored: true
                ))
            } else {
                tempSlices.append(PieSliceData(
                    startAngle: Angle(degrees: endDeg),
                    endAngle: Angle(degrees: endDeg + degrees),
                    text: String(format: "%.0f%%", value * 100 / sum),
                    color: colors[i]
                ))
            }
            endDeg += degrees
        }
        return tempSlices
    }

    // MARK: Private

    @State private var activeIndex: Int = -1
}

// MARK: - PieChartRows

@available(iOS 15.0, macCatalyst 15.0, *)
struct PieChartRows: View {
    // MARK: Lifecycle

    init?(colors: [Color], names: [String], values: [String], percents: [String]) {
        self.names = names
        self.values = values
        guard names.count == values.count else { return nil }
        guard names.count <= colors.count else { return nil }
        self.colors = Array(colors[0 ..< names.count])
        self.percents = percents
        guard percents.count == values.count else { return nil }
    }

    // MARK: Internal

    struct DataSet: Hashable, Identifiable {
        let color: Color
        let name: String
        let value: String
        let percent: String

        var id: Int { hashValue }
    }

    var colors: [Color]
    var names: [String]
    var values: [String]
    var percents: [String]

    var dataSets: [DataSet] {
        var result = [DataSet]()
        for (i, color) in colors.enumerated() {
            result.append(.init(color: color, name: names[i], value: values[i], percent: percents[i]))
        }
        return result
    }

    var body: some View {
        VStack {
            ForEach(dataSets, id: \.self) { valueSet in
                HStack {
                    valueSet.color
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                        .frame(width: 20, height: 20)
                    Text(valueSet.name)
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(valueSet.value)
                        Text(valueSet.percent)
                        #if os(iOS) || targetEnvironment(macCatalyst)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                        #else
                            .foregroundColor(Color(nsColor: NSColor.secondaryLabelColor))
                        #endif
                    }
                }
            }
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        .shadow(color: .init(uiColor: .systemBackground), radius: 3)
        #else
        .shadow(color: .init(nsColor: NSColor.controlBackgroundColor), radius: 3)
        #endif
    }
}

// MARK: - PieChartView_Previews

@available(iOS 15.0, macCatalyst 15.0, *)
struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        PieChartView(
            values: [1300, 500, 300],
            names: ["Rent", "Transport", "Education"],
            formatter: { value in String(format: "$%.2f", value) }
        )
    }
}

// MARK: - PieSlice

struct PieSlice: View {
    var pieSliceData: PieSliceData

    var midRadians: Double {
        Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle)
            .radians / 2.0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(
                        geometry.size.width,
                        geometry.size.height
                    )
                    let height = width
                    path.move(
                        to: CGPoint(
                            x: width * 0.5,
                            y: height * 0.5
                        )
                    )

                    path.addArc(
                        center: CGPoint(x: width * 0.5, y: height * 0.5),
                        radius: width * 0.5,
                        startAngle: Angle(degrees: -90.0) + pieSliceData
                            .startAngle,
                        endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                        clockwise: false
                    )
                }
                .fill(pieSliceData.color)

                if !pieSliceData.isIgnored {
                    Text(pieSliceData.text)
                        .position(
                            x: geometry.size
                                .width * 0.5 *
                                CGFloat(1.0 + 0.78 * cos(midRadians)),
                            y: geometry.size
                                .height * 0.5 *
                                CGFloat(1.0 - 0.78 * sin(midRadians))
                        )
                        .foregroundColor(Color.white)
                        .shadow(color: .black, radius: 3)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - PieSliceData

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var text: String
    var color: Color
    var isIgnored: Bool = false
}

// MARK: - PieSlice_Previews

struct PieSlice_Previews: PreviewProvider {
    static var previews: some View {
        PieSlice(pieSliceData: PieSliceData(
            startAngle: Angle(degrees: 0.0),
            endAngle: Angle(degrees: 120.0),
            text: "30%",
            color: Color.black
        ))
    }
}
