// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit

extension Defaults.Keys {
    /// Background wallpaper identifiers for live activity view.
    /// 空阵列代指随机原厂背景图，有内容的话根据内容是否是 UUIDString 来判定是否是用户背景。
    /// 如果阵列内有 null identifier 的话，则会触发透明玻璃显示效果（此时不显示背景图）。
    public static let liveActivityWallpaperIDs = Key<Set<String>>(
        "liveActivityWallpaperIDs",
        default: [],
        suite: .baseSuite
    )
    /// Background wallpaper identifiers for live activity view (Backup).
    /// 这里用来备份 `liveActivityWallpaperIDs` 的资料值。
    /// 该参数是设计给 `LiveActivityBackgroundValueParser` 使用的。
    public static let liveActivityWallpaperIDsBackup = Key<Set<String>>(
        "liveActivityWallpaperIDs",
        default: [],
        suite: .baseSuite
    )
    /// Background wallpaper identifier for app view.
    public static let appWallpaperID = Key<String>(
        "appWallpaperID",
        default: BundledWallpaper.defaultValue(for: appGame).id,
        suite: .baseSuite
    )
}
