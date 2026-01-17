// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import SwiftUI

// MARK: - LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol LocalAssetSuppliable {
    var iconAssetName: String { get }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension LocalAssetSuppliable {
    public var localIcon4SUI: Image {
        Image(iconAssetName, bundle: .currentSPM).resizable()
    }

    @ViewBuilder public var localFittingIcon4SUI: some View {
        localIcon4SUI.aspectRatio(contentMode: .fit)
    }
}

// MARK: - Enka.LifePath + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.LifePath: LocalAssetSuppliable {}

// MARK: - Enka.GameElement + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.GameElement: LocalAssetSuppliable {}

// MARK: - Enka.PropertyType + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.PropertyType: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.CharacterID + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.CharacterID: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.WeaponPanel + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.WeaponPanel: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.ArtifactInfo + LocalAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.AvatarSummarized.ArtifactInfo: LocalAssetSuppliable {}
