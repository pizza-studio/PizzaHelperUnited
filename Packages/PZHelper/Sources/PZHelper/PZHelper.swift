// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import GachaKit
import PZAboutKit
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI
import WallpaperKit

// MARK: - PZHelper

public enum PZHelper {}

extension PZHelper {
    @MainActor
    public static func makeMainScene() -> some Scene {
        let windowToReturn = WindowGroup {
            Group {
                if #available(iOS 17.0, macCatalyst 17.0, *) {
                    ContentView()
                        .trackScreenVMParameters()
                } else {
                    ContentView4iOS14()
                }
            }
            .initializeApp()
            // .environment(\.horizontalSizeClass, .compact)
            .defaultAppStorage(.baseSuite)
            // Auto-Correction must be disabled to prevent a memory leak issue on OS24+.
            // Refs: https://kyleye.top/posts/swiftui-textfield-memory-leak/
            .autocorrectionDisabled(true)
            #if targetEnvironment(macCatalyst)
                .frame(
                    minWidth: OS.liquidGlassThemeSuspected ? 832 : 800,
                    minHeight: 800
                )
            #elseif os(macOS) && !targetEnvironment(macCatalyst)
                .frame(
                    minWidth: OS.liquidGlassThemeSuspected ? 800 : 768,
                    minHeight: 646
                )
            #endif
                .apply { mainContents in
                    if #available(iOS 16.2, macCatalyst 16.2, *) {
                        mainContents
                            .onAppear {
                                startupTasks()
                            }
                            .onAppBecomeActive(debounceOnMac: false) {
                                Task {
                                    await ASMetaSputnik.shared.updateMeta()
                                }
                            }
                    } else {
                        mainContents
                    }
                }
        }
        #if os(macOS) && !targetEnvironment(macCatalyst)
        .windowToolbarStyle(.expanded)
        #endif

        if #available(iOS 17.0, macCatalyst 17.0, *) {
            return windowToReturn
                .windowResizability(.contentMinSize)
        } else {
            return windowToReturn
        }
    }

    @MainActor static var isApplicationBooted = false
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension PZHelper {
    @MainActor
    static func startupTasks() {
        Task { @MainActor in
            await ProfileManagerVM.shared
                .profileActor?
                .tryAutoInheritOldLocalAccounts(resetNotifications: true)
        }
        PZHelper.setupSpotlightSearch()
        if #available(iOS 17.0, *) {
            GachaRootView.getFAQView = { AnyView(FAQView()) }
            Enka.Sputnik.migrateCachedProfilesFromUserDefaultsToFiles()
        } else {
            // Fallback on earlier versions
        }
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }
}

// MARK: - AppInitializer

@available(iOS 16.2, macCatalyst 16.2, *)
private struct AppInitializer: ViewModifier {
    // MARK: Lifecycle

    init() {
        if !PZHelper.isApplicationBooted {
            PZHelper.startupTasks()
        }
        PZHelper.isApplicationBooted = true
    }

    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .syncProfilesToUserDefaults()
            .cleanApplicationIconBadgeNumber()
            .checkAndReloadWidgetTimeline()
            .hookOOBESheet()
            .handleHoYoBackgroundSessions()
            .performEnkaDBSanityCheck()
    }
}

extension View {
    @ViewBuilder
    func initializeApp() -> some View {
        if #available(iOS 16.2, *) {
            modifier(AppInitializer())
        } else {
            self
        }
    }
}
