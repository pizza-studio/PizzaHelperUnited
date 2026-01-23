// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

// MARK: - WinUI3ProgressRing

/// A circular progress indicator inspired by Windows 11 / WinUI 3 ProgressRing.
/// Features a rotating arc that expands and contracts smoothly.
public struct WinUI3ProgressRing: View {
    // MARK: Lifecycle

    public init(
        size: CGFloat = 24,
        lineWidth: CGFloat = 3,
        color: Color = .accentColor,
        trackColor: Color? = .secondary
    ) {
        self.size = Swift.max(8, size)
        self.lineWidth = Swift.max(0.5, lineWidth)
        self.color = color
        self.trackColor = trackColor
    }

    // MARK: Public

    public var body: some View {
        ZStack {
            // Optional background track
            if let trackColor {
                Circle()
                    .stroke(trackColor.opacity(0.2), lineWidth: lineWidth)
            }

            // Animated arc
            Circle()
                .trim(from: trimStart, to: trimEnd)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation - 90))
        }
        .padding(lineWidth / 2)
        .frame(width: size, height: size)
        .onAppear {
            startAnimation()
        }
    }

    // MARK: Private

    @State private var trimStart: CGFloat = 0.0
    @State private var trimEnd: CGFloat = 0.05
    @State private var rotation: Double = 0

    private let size: CGFloat
    private let lineWidth: CGFloat
    private let color: Color
    private let trackColor: Color?

    private func startAnimation() {
        // Arc expansion/contraction animation
        withAnimation(
            .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            trimEnd = 0.7
        }

        // Continuous rotation
        withAnimation(
            .linear(duration: 2.0)
                .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        WinUI3ProgressRing()

        WinUI3ProgressRing(size: 48, lineWidth: 4, color: .blue)

        WinUI3ProgressRing(size: 24, lineWidth: 2, color: .secondary, trackColor: .gray)

        HStack(spacing: 20) {
            WinUI3ProgressRing(size: 20, lineWidth: 2)
            Text("Loading...")
        }
    }
    .padding()
}
