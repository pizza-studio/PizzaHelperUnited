// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import SFSafeSymbols
import SwiftUI
import WallpaperKit

#if !os(watchOS)

public struct UserWallpaperMgrViewContent: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "userWallpaperMgr.navTitle".i18nWPConfKit
    public static let navDescription: String = "userWallpaperMgr.navDescription".i18nWPConfKit
    public static let navTitleTiny: String = "userWallpaperMgr.navTitle.tiny".i18nWPConfKit

    public var body: some View {
        coreBody
    }

    // MARK: Private

    #if os(iOS) || targetEnvironment(macCatalyst)
    @State private var isEditMode: EditMode = .inactive
    #endif

    @Default(.userWallpapers) private var userWallpapers: Set<UserWallpaper>

    private var userWallpaperSorted: [UserWallpaper] {
        userWallpapers.sorted {
            $0.timestamp > $1.timestamp
        }
    }

    private var isEditing: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return isEditMode.isEditing
        #else
        return false
        #endif
    }
}

extension UserWallpaperMgrViewContent {
    @ViewBuilder var coreBody: some View {
        List {
            Section {
                ForEach(userWallpaperSorted) { userWallpaper in
                    let cgImage = userWallpaper.imageSquared
                    let iconImage: Image = {
                        if let cgImage { return Image(decorative: cgImage, scale: 1, orientation: .up) }
                        return Image(systemSymbol: .trashSlashFill)
                    }()
                    Label {
                        Text(verbatim: userWallpaper.name)
                    } icon: {
                        iconImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(.circle)
                    }
                }
                .onDelete(perform: deleteItems)
                if userWallpapers.isEmpty {
                    Text("userWallpaperMgr.emptyContentsNotice", bundle: .module)
                }
            }
        }
        .navigationTitle(Self.navTitleTiny)
        .navBarTitleDisplayMode(.large)
        .apply { content in
            content
                .toolbar {
                    #if os(iOS) || targetEnvironment(macCatalyst)
                    if !userWallpapers.isEmpty {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(isEditMode.isEditing ? "sys.done".i18nBaseKit : "sys.edit".i18nBaseKit) {
                                withAnimation {
                                    isEditMode = (isEditMode.isEditing) ? .inactive : .active
                                }
                            }
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            withAnimation {
                                // Add contents
                            }
                        } label: {
                            Image(systemSymbol: .plusCircle)
                        }
                    }
                    #endif
                }
            #if os(iOS) || targetEnvironment(macCatalyst)
                .environment(\.editMode, $isEditMode)
            #endif
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var wallpapersTemp = userWallpaperSorted
            wallpapersTemp.remove(atOffsets: offsets)
            userWallpapers = .init(wallpapersTemp)
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        UserWallpaperMgrViewContent()
    }
}

#endif

#endif
