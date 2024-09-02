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
        self.pid = pid
        self.coordinator = coordinator
        self.size = size
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
    }

    // MARK: Public

    @MainActor public var body: some View {
        coreBody.compositingGroup()
    }

    // MARK: Internal

    @Observable
    class Coordinator {
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
        case .asCard: return AnyView(cardView)
        default: return AnyView(circleIconView)
        }
    }

    var proposedSize: CGSize {
        switch iconType {
        case .asCard: return .init(width: size * 0.74, height: size)
        default: return .init(width: size, height: size)
        }
    }

    @MainActor @ViewBuilder var cardView: some View {
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

    @MainActor @ViewBuilder var circleIconView: some View {
        let ratio = 179.649 / 1024
        let cornerSize = CGSize(width: ratio * size, height: ratio * size)
        let roundCornerSize = CGSize(width: size / 2, height: size / 2)
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
            .clipShape(RoundedRectangle(cornerSize: roundRect ? cornerSize : roundCornerSize))
            .contentShape(RoundedRectangle(cornerSize: roundRect ? cornerSize : roundCornerSize))
    }

    @MainActor var imageObj: some View {
        imageHandler(coordinator.charAvatarImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    @MainActor @ViewBuilder var backgroundObj: some View {
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
    private let coordinator: Coordinator
}
