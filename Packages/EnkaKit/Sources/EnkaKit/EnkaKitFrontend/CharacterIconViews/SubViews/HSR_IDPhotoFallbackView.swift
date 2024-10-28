// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - IDPhotoFallbackView

/// 仅用于 EnkaDB 还没更新的场合。
struct IDPhotoFallbackView4HSR: View {
    // MARK: Lifecycle

    @MainActor
    public init?(
        pid: String,
        _ size: CGFloat,
        _ type: IDPhotoView4HSR.IconType,
        imageHandler: ((Image) -> Image)? = nil
    ) {
        let coordinator = Self.Coordinator(pid: pid)
        guard let coordinator = coordinator else { return nil }
        self._coordinator = .init(wrappedValue: coordinator)
        self.pid = pid
        self.size = size
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
    }

    // MARK: Public

    public var body: some View {
        coreBody.compositingGroup()
    }

    // MARK: Internal

    @Observable
    final class Coordinator: ObservableObject {
        // MARK: Lifecycle

        @MainActor
        public init?(pid: String) {
            self.pid = pid
            let fallbackPID = Enka.CharacterName.convertPIDForHSRProtagonist(pid)
            guard let charAvatarImage = Enka.queryImageAssetSUI(for: "idp\(pid)")
                ?? Enka.queryImageAssetSUI(for: "idp\(fallbackPID)")
            else { return nil }
            let backgroundImage = Enka.queryImageAssetSUI(for: "hsr_character_\(pid)")
            guard let backgroundImage = backgroundImage else { return nil }
            self.backgroundImage = backgroundImage
            self.charAvatarImage = charAvatarImage
        }

        // MARK: Internal

        var backgroundImage: Image
        var charAvatarImage: Image
        var pid: String
    }

    @Environment(\.colorScheme) var colorScheme

    @MainActor var coreBody: some View {
        switch iconType {
        case .asCard: AnyView(cardView)
        default: AnyView(circleIconView)
        }
    }

    var proposedSize: CGSize {
        switch iconType {
        case .asCard: .init(width: size * 0.74, height: size)
        default: .init(width: size, height: size)
        }
    }

    @ViewBuilder var cardView: some View {
        imageObj
            .scaledToFill()
            .frame(width: size * iconType.rawValue, height: size * iconType.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: iconType.shiftedAmount(containerSize: size))
            .background {
                backgroundObj
            }
            .frame(width: size * 0.74, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
    }

    @ViewBuilder var circleIconView: some View {
        let ratio = 179.649 / 1024
        let cornerRadius = ratio * size
        let roundCornerRadius = size / 2
        let roundRect = iconType == .cutFaceRoundedRect
        imageObj
            .scaledToFill()
            .frame(width: size * iconType.rawValue, height: size * iconType.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: iconType.shiftedAmount(containerSize: size))
            .background {
                backgroundObj
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: roundRect ? cornerRadius : roundCornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: roundRect ? cornerRadius : roundCornerRadius))
    }

    @MainActor var imageObj: some View {
        imageHandler(coordinator.charAvatarImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    @ViewBuilder var backgroundObj: some View {
        Group {
            coordinator.backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(2)
                .rotationEffect(.degrees(180))
                .blur(radius: 12)
        }
        .background(baseWindowBGColor)
    }

    var baseWindowBGColor: Color {
        switch colorScheme {
        case .dark:
            return .init(cgColor: .init(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00))
        case .light:
            return .init(cgColor: .init(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00))
        @unknown default:
            return .gray
        }
    }

    // MARK: Private

    private let pid: String
    private let imageHandler: (Image) -> Image
    private let size: CGFloat
    private let iconType: IDPhotoView4HSR.IconType
    @StateObject private var coordinator: Coordinator
}
