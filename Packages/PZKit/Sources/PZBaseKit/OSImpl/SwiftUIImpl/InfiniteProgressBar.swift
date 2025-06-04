// Ref: https://swiftuirecipes.com/blog/material-indefinite-loading-bar-in-swiftui

import Foundation
import SwiftUI

// MARK: - InfiniteProgressBar

public struct InfiniteProgressBar: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        Rectangle()
            .foregroundColor(.gray) // change the color as you see fit
            .frame(height: Self.height)
            .overlay(GeometryReader { geo in
                overlayRect(in: geo.frame(in: .local))
            })
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: Private

    // the height of the bar
    private static let height: CGFloat = 4
    // how much does the blue part cover the gray part (40%)
    private static let coverPercentage: CGFloat = 0.4
    private static let minOffset: CGFloat = -2
    private static let maxOffset = 1 / coverPercentage * abs(minOffset)

    @State private var offset = Self.minOffset

    @ViewBuilder
    private func overlayRect(in rect: CGRect) -> some View {
        let width = rect.width * Self.coverPercentage
        Rectangle()
            .foregroundColor(.blue)
            .frame(width: width)
            .offset(x: width * offset)
            .onAppear {
                withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    offset = Self.maxOffset
                }
            }
    }
}
