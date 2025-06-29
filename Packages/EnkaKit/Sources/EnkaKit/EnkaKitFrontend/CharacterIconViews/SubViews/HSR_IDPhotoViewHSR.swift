// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import SwiftUI

// MARK: - IDPhotoView

public struct IDPhotoView4HSR: View {
    // MARK: Lifecycle

    public init?(
        pid: String,
        _ size: CGFloat,
        _ type: IconType,
        forceRender: Bool = false,
        energySavingMode: Bool = false,
        imageHandler: ((Image) -> Image)? = nil
    ) {
        guard Defaults[.useGenshinStyleCharacterPhotos] || forceRender else { return nil }
        guard let coordinator = Self.Coordinator(pid: pid) else { return nil }
        self._coordinator = .init(wrappedValue: coordinator)
        self.pid = pid
        let lifePathStr = Enka.Sputnik.shared.db4HSR.characters[pid]?.avatarBaseType
        guard let lifePathStr, let lifePath = Enka.LifePath(rawValue: lifePathStr) else { return nil }
        self.size = size
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
        self.lifePath = lifePath
        self.pathTotemVisible = type.pathTotemVisible
        self.energySavingMode = energySavingMode
        let maybeElementStr = Enka.Sputnik.shared.db4HSR.characters[pid]?.element ?? ""
        self.element = .init(rawValueGuarded: maybeElementStr)
    }

    // MARK: Public

    public enum IconType: CGFloat {
        case asCard = 1.1
        case cutShoulder = 1.15
        case cutHead = 1.5
        case cutFace = 2
        case cutHeadRoundRect = 1.6

        // MARK: Internal

        var pathTotemVisible: Bool {
            ![.cutFace].contains(self)
        }

        func shiftedAmount(containerSize size: CGFloat) -> CGFloat {
            let fixedRawValue = min(2, max(1, rawValue))
            switch self {
            case .asCard: return size / (20 * fixedRawValue)
            case .cutShoulder: return size / (15 * fixedRawValue)
            default: return size / (4 * fixedRawValue)
            }
        }
    }

    public var body: some View {
        coreBody.compositingGroup()
    }

    // MARK: Internal

    @Observable
    final class Coordinator: ObservableObject {
        // MARK: Lifecycle

        public init?(pid: String) {
            guard let cidObj = Enka.AvatarSummarized.CharacterID(id: pid) else { return nil }
            self.cid = cidObj
            let fallbackPID = Enka.CharacterName.convertPIDForHSRProtagonist(pid)
            guard let charAvatarImage = Enka.queryImageAssetSUI(for: "idp\(pid)")
                ?? Enka.queryImageAssetSUI(for: "idp\(fallbackPID)")
            else { return nil }
            let lifePathStr = Enka.Sputnik.shared.db4HSR.characters[pid]?.avatarBaseType
            guard let lifePathStr, let lifePath = Enka.LifePath(rawValue: lifePathStr) else { return nil }
            self.lifePathImage = lifePath.localIcon4SUI
            self.backgroundImage = cidObj.localIcon4SUI
            self.charAvatarImage = charAvatarImage
        }

        // MARK: Internal

        let cid: Enka.AvatarSummarized.CharacterID
        var lifePathImage: Image
        var backgroundImage: Image
        var charAvatarImage: Image

        var pid: String { cid.id }
    }

    @Environment(\.colorScheme) var colorScheme

    var proposedSize: CGSize {
        switch iconType {
        case .asCard: .init(width: size * 0.74, height: size)
        default: .init(width: size, height: size)
        }
    }

    var elementColor: Color {
        var opacity: Double = 1
        switch lifePath {
        case .abundance: opacity = 0.4
        case .hunt: opacity = 0.35
        default: break
        }
        return element.themeColor.suiColor.opacity(opacity)
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

    @ViewBuilder var coreBody: some View {
        switch iconType {
        case .asCard: AnyView(cardView)
        default: AnyView(circleIconView)
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
        let roundRect = iconType == .cutHeadRoundRect
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

    @ViewBuilder var imageObj: some View {
        imageHandler(coordinator.charAvatarImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    @ViewBuilder var backgroundObj: some View {
        Group {
            if energySavingMode {
                element.linearGradientAsBackground
            } else {
                coordinator.backgroundImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(2)
                    .rotationEffect(.degrees(180))
                    .blur(radius: 12)
            }
        }
        .overlay {
            if pathTotemVisible {
                coordinator.lifePathImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1)
                    .colorMultiply(elementColor)
                    .saturation(0.5)
                    .brightness(0.5)
                    .opacity(0.7)
            }
        }
        .background(baseWindowBGColor)
    }

    // MARK: Private

    @StateObject private var coordinator: Coordinator

    private let pid: String
    private let imageHandler: (Image) -> Image
    private let size: CGFloat
    private let iconType: IconType
    private let pathTotemVisible: Bool
    private let lifePath: Enka.LifePath
    private let energySavingMode: Bool
    private let element: Enka.GameElement
}
