// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - LiveActivityBackgroundValueParser

public struct LiveActivityBackgroundValueParser: Sendable {
    // MARK: Lifecycle

    public init(_ liveActivityWallpaperIDs: Binding<Set<String>>) {
        self.ids = liveActivityWallpaperIDs
    }

    // MARK: Public

    public var liveActivityWallpaperIDsReal: Binding<Set<String>> {
        .init {
            ids.wrappedValue.filter { $0 != Wallpaper.nullLiveActivityWallpaperIdentifier }
        } set: { newValue in
            if ids.wrappedValue.contains(nullFlag) {
                ids.wrappedValue = newValue.union([nullFlag])
            } else {
                ids.wrappedValue = newValue.subtracting([nullFlag])
            }
        }
    }

    public var useRandomBackground: Binding<Bool> {
        .init {
            liveActivityWallpaperIDsReal.wrappedValue.isEmpty
        } set: { newValue in
            switch newValue {
            case true:
                if liveActivityWallpaperIDsReal.wrappedValue.count >= 0 {
                    Defaults[.liveActivityWallpaperIDsBackup] = liveActivityWallpaperIDsReal.wrappedValue
                    liveActivityWallpaperIDsReal.wrappedValue.removeAll()
                }
            case false:
                var fetchedBackup = Defaults[.liveActivityWallpaperIDsBackup]
                if fetchedBackup.isEmpty {
                    fetchedBackup = [BundledWallpaper.defaultValue(for: appGame).id]
                }
                liveActivityWallpaperIDsReal.wrappedValue = fetchedBackup
            }
        }
    }

    public var useEmptyBackground: Binding<Bool> {
        .init {
            ids.wrappedValue.contains(Wallpaper.nullLiveActivityWallpaperIdentifier)
        } set: { newValue in
            switch newValue {
            case true:
                ids.wrappedValue.insert(Wallpaper.nullLiveActivityWallpaperIdentifier)
            case false:
                ids.wrappedValue.remove(Wallpaper.nullLiveActivityWallpaperIdentifier)
            }
        }
    }

    // MARK: Private

    private let ids: Binding<Set<String>>
    private let nullFlag = Wallpaper.nullLiveActivityWallpaperIdentifier
}
