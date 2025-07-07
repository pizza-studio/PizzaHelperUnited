// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - AnonymousIconView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct AnonymousIconView: View {
    // MARK: Lifecycle

    public init(_ size: CGFloat, cutType: CutType) {
        self.cutType = cutType
        self.size = size
        self.roundRectCornerRadius = size * Self.roundedRectRatio
    }

    // MARK: Public

    public var body: some View {
        switch cutType {
        case .card: Self.rawImage4SUI
            .aspectRatio(contentMode: .fill)
            .frame(width: size * 0.74, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
        case .circleClipped: Self.rawImage4SUI
            .frame(width: size, height: size)
            .clipShape(.circle)
            .contentShape(.circle)
        case .roundRectangle: Self.rawImage4SUI
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: roundRectCornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: roundRectCornerRadius))
        }
    }

    // MARK: Private

    private static let roundedRectRatio = 179.649 / 1024

    private let size: CGFloat
    private let cutType: CutType
    private let roundRectCornerRadius: CGFloat
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension AnonymousIconView {
    nonisolated public static let nullPhotoAssetName = "avatar_anonymous_yjsnpi"

    public enum CutType {
        case card
        case circleClipped
        case roundRectangle
    }

    @ViewBuilder public static var rawImage4SUI: some View {
        Image(nullPhotoAssetName, bundle: Bundle.module)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
