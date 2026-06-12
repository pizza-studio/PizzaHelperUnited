// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import SwiftUI

// MARK: - MacSafeSlider

/// A cross-platform slider built with plain SwiftUI primitives
/// (`DragGesture` + `GeometryReader`), avoiding the native `Slider`
/// whose underlying `_UIFluidSliderFeedbackConfiguration` crashes on
/// macOS 27 beta.
///
/// Intended as a drop-in replacement for `Slider` on macOS; on iOS
/// the system `Slider` is preferred for its native look and feel.
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct MacSafeSlider: View {
    // MARK: Lifecycle

    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        step: Double? = nil
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
    }

    // MARK: Public

    public var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbDiameter = thumbDiameterProposal
            let usableWidth = max(0, trackWidth - thumbDiameter)
            let fraction = usableWidth > 0
                ? CGFloat((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
                : 0
            let clampedFraction = min(1, max(0, fraction))
            let thumbCenterX = usableWidth * clampedFraction + thumbDiameter / 2

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.quaternary)
                    .frame(height: 4)

                Circle()
                    .fill(.primary)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .offset(x: thumbCenterX - thumbDiameter / 2)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { drag in
                                let rawFraction = max(0, min(1, drag.location.x / usableWidth))
                                let raw = bounds.lowerBound + Double(rawFraction)
                                    * (bounds.upperBound - bounds.lowerBound)
                                value = applyStep(raw)
                            }
                    )
                    .onTapGesture {} // 吞掉 tap 避免穿透，讓 drag 獨佔。
            }
            .frame(height: thumbDiameter * 2)
            .contentShape(Rectangle()) // 讓整個 track 區域都能接收 drag
        }
        .frame(height: 24)
    }

    // MARK: Private

    @Binding private var value: Double

    private let bounds: ClosedRange<Double>
    private let step: Double?

    private var thumbDiameterProposal: CGFloat { 12 }

    private func applyStep(_ raw: Double) -> Double {
        guard let step, step > 0 else { return raw }
        return (raw / step).rounded() * step
    }
}
