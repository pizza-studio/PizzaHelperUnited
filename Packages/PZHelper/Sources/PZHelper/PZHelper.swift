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
            if #unavailable(iOS 17.0, macCatalyst 17.0) {
                ContentView4iOS14()
            } else {
                ContentView()
                    .initializeApp()
                    // .environment(\.horizontalSizeClass, .compact)
                    .defaultAppStorage(.baseSuite)
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
                    .onAppear {
                        if !isApplicationBooted {
                            startupTasks()
                        }
                        isApplicationBooted = true
                    }
                    .onAppBecomeActive {
                        Task {
                            await ASMetaSputnik.shared.updateMeta()
                        }
                    }
                    .trackScreenVMParameters()
                    .modelContainer(PZProfileActor.shared.modelContainer)
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension PZHelper {
    @MainActor
    static func startupTasks() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
        Task {
            await PZProfileActor.shared.syncAllDataToUserDefaults()
        }
        PZHelper.setupSpotlightSearch()
        GachaRootView.getFAQView = { AnyView(FAQView()) }
        Enka.Sputnik.migrateCachedProfilesFromUserDefaultsToFiles()
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }
}

// MARK: - AppInitializer

@available(iOS 17.0, macCatalyst 17.0, *)
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
            .hookEULACheckerOnOOBE()
            .hookPrivacyPolicyCheckerOnOOBE()
            .performEnkaDBSanityCheck()
            .handleHoYoBackgroundSessions()
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension View {
    @ViewBuilder
    func initializeApp() -> some View {
        modifier(AppInitializer())
    }
}
