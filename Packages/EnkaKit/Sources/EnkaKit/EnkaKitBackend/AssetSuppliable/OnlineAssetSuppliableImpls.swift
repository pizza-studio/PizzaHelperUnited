// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// 这个文件专门定义素材的线上 URL，也还定义了共用的 AsyncImage。

import PZBaseKit
import SwiftUI

// MARK: - OnlineAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public protocol OnlineAssetSuppliable {
    var onlineAssetURLStr: String { get }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.AvatarSummarized.CharacterID: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        guard !iconOnlineFileNameStem.hasPrefix("https://") else {
            return iconOnlineFileNameStem
        }
        let urlStr = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://api.hakush.in/hsr/UI/avatarshopicon/\(iconOnlineFileNameStem).webp"
        case .zenlessZone:
            "114514" // 临时设定。
        }
        return urlStr
    }
}

// MARK: - Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill + OnlineAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        guard !iconOnlineFileNameStem.hasPrefix("https://") else {
            return iconOnlineFileNameStem
        }
        let urlStr = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://sr.yatta.moe/hsr/assets/UI/skill/\(iconOnlineFileNameStem).png"
        case .zenlessZone:
            "114514" // 临时设定。
        }
        return urlStr
    }
}

// MARK: - Enka.AvatarSummarized.WeaponPanel + OnlineAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.AvatarSummarized.WeaponPanel: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        guard !iconOnlineFileNameStem.hasPrefix("https://") else {
            return iconOnlineFileNameStem
        }
        let urlStr = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://api.hakush.in/hsr/UI/lightconemediumicon/\(iconOnlineFileNameStem).webp"
        case .zenlessZone: "114514" // 临时设定。
        }
        return urlStr
    }
}

// MARK: - Enka.AvatarSummarized.ArtifactInfo + OnlineAssetSuppliable

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka.AvatarSummarized.ArtifactInfo: OnlineAssetSuppliable {
    public var onlineAssetURLStr: String {
        guard !iconOnlineFileNameStem.hasPrefix("https://") else {
            return iconOnlineFileNameStem
        }
        let urlStr = switch game {
        case .genshinImpact:
            "https://api.hakush.in/gi/UI/\(iconOnlineFileNameStem).webp"
        case .starRail:
            "https://api.hakush.in/hsr/UI/relicfigures/\(iconOnlineFileNameStem).webp"
        case .zenlessZone: "114514" // 临时设定。
        }
        return urlStr
    }
}
