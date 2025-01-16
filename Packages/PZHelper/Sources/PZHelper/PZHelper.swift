// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaKit
import PZAboutKit
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - PZHelper

public enum PZHelper {}

extension PZHelper {
    @MainActor @SceneBuilder
    public static func makeMainScene(modelContainer: ModelContainer) -> some Scene {
        WindowGroup {
            ContentView()
                .initializeApp()
                .environment(\.horizontalSizeClass, .compact)
                .defaultAppStorage(.baseSuite)
            #if targetEnvironment(macCatalyst)
                .frame(minWidth: 600, minHeight: 800)
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
        }
        .windowResizability(.contentMinSize)
        .modelContainer(modelContainer)
    }

    public static func getSharedModelContainer() -> ModelContainer {
        PZProfileActor.shared.modelContainer
    }

    @MainActor public private(set) static var isApplicationBooted = false
}

extension PZHelper {
    @MainActor
    private static func startupTasks() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
        Task {
            await PZProfileActor.shared.syncAllDataToUserDefaults()
        }
        PZHelper.setupSpotlightSearch()
        GachaRootView.getFAQView = { AnyView(FAQView()) }
    }
}

// MARK: - AppInitializer

private struct AppInitializer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .syncProfilesToUserDefaults()
            .cleanApplicationIconBadgeNumber()
            .checkAndReloadWidgetTimeline()
            .hookEULACheckerOnOOBE()
            .hookPrivacyPolicyCheckerOnOOBE()
            .performEnkaDBSanityCheck()
    }
}

extension View {
    func initializeApp() -> some View {
        modifier(AppInitializer())
    }
}
