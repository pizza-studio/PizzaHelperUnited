// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// 这个文件专门定义素材的线上 URL，也还定义了共用的 AsyncImage。

import PZBaseKit
import SwiftUI

// MARK: - OnlineAssetSuppliable

public protocol OnlineAssetSuppliable {
    var onlineAssetURLStr: String { get }
}

extension OnlineAssetSuppliable {
    @MainActor
    public func onlineIcon(imageHandler: ((Image) -> Image)? = nil) -> AsyncImage<some View> {
        AsyncImage(url: onlineAssetURLStr.asURL) { imgObj in
            if let imageHandler {
                imageHandler(imgObj)
            } else {
                imgObj.resizable()
            }
        } placeholder: {
            ProgressView()
        }
    }
}

// MARK: - Enka.AvatarSummarized.CharacterID + OnlineAssetSuppliable

// swiftlint:disable force_unwrapping
extension Enka.AvatarSummarized.CharacterID: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        let urlStr: String = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(avatarOnlineFileNameStem).webp"
        case .starRail:
            "https://api.hakush.in/hsr/UI/avatarshopicon/\(avatarOnlineFileNameStem).webp"
        }
        return urlStr
    }
}

// MARK: - Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill + OnlineAssetSuppliable

extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        let urlStr: String = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://api.yatta.top/hsr/assets/UI/skill/\(iconOnlineFileNameStem).png"
        }
        return urlStr
    }
}

// MARK: - Enka.AvatarSummarized.WeaponPanel + OnlineAssetSuppliable

extension Enka.AvatarSummarized.WeaponPanel: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        let urlStr: String = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://api.hakush.in/hsr/UI/lightconemediumicon/\(iconOnlineFileNameStem).webp"
        }
        return urlStr
    }
}

// MARK: - Enka.AvatarSummarized.ArtifactInfo + OnlineAssetSuppliable

extension Enka.AvatarSummarized.ArtifactInfo: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        let urlStr: String = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://api.hakush.in/hsr/UI/relicfigures/\(iconOnlineFileNameStem).webp"
        }
        return urlStr
    }
}
