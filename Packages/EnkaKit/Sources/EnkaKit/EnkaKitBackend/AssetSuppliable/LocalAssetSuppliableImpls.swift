// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - LocalAssetSuppliable

public protocol LocalAssetSuppliable {
    var iconAssetName: String { get }
}

extension LocalAssetSuppliable {
    public var localIcon4SUI: Image {
        Image(iconAssetName, bundle: Bundle.module).resizable()
    }

    @ViewBuilder public var localFittingIcon4SUI: some View {
        localIcon4SUI.aspectRatio(contentMode: .fit)
    }
}

// MARK: - Enka.LifePath + LocalAssetSuppliable

extension Enka.LifePath: LocalAssetSuppliable {}

// MARK: - Enka.GameElement + LocalAssetSuppliable

extension Enka.GameElement: LocalAssetSuppliable {}

// MARK: - Enka.PropertyType + LocalAssetSuppliable

extension Enka.PropertyType: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.CharacterID + LocalAssetSuppliable

extension Enka.AvatarSummarized.CharacterID: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill + LocalAssetSuppliable

extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.WeaponPanel + LocalAssetSuppliable

extension Enka.AvatarSummarized.WeaponPanel: LocalAssetSuppliable {}

// MARK: - Enka.AvatarSummarized.ArtifactInfo + LocalAssetSuppliable

extension Enka.AvatarSummarized.ArtifactInfo: LocalAssetSuppliable {}
