// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)
import Foundation
import Observation
import SwiftUI

/// AppTabBar 的前端实现不在此，而在于 PZHelper 这个 Swift Package 内。

// MARK: - AppTabBarVM

@Observable @MainActor
public final class AppTabBarVM: ObservableObject, Sendable {
    // MARK: Public

    public static let shared = AppTabBarVM()

    public var latestVisibility: SwiftUI.Visibility = .automatic

    public func clearAll() {
        visibilityMap.removeAll()
        latestVisibility = .automatic
    }

    public func findLatestVisibility() -> SwiftUI.Visibility {
        let mostRecentEntry = visibilityMap.max {
            $0.key.timeIntervalSince1970 < $1.key.timeIntervalSince1970
        }
        return mostRecentEntry?.value ?? .automatic
    }

    public func addOneLevel(_ visibility: SwiftUI.Visibility, timestampID: Date) {
        visibilityMap[timestampID] = visibility
        latestVisibility = findLatestVisibility()
        print("AppTabBarVisibility +1 at \(timestampID.timeIntervalSince1970), now: \(latestVisibility)")
    }

    public func dropOneLevel(timestampID: Date) {
        visibilityMap[timestampID] = nil
        latestVisibility = findLatestVisibility()
        print("AppTabBarVisibility -1 at \(timestampID.timeIntervalSince1970), now: \(latestVisibility)")
    }

    // MARK: Private

    private var visibilityMap: [Date: SwiftUI.Visibility] = [:]
}

private struct AppTabBarVisibilityModifier: ViewModifier {
    // MARK: Lifecycle

    public init(_ visibility: SwiftUI.Visibility) {
        self.visibility = visibility
    }

    // MARK: Internal

    @ViewBuilder
    func body(content: Content) -> some View {
        content
            .onAppear {
                appTabBarVM.addOneLevel(visibility, timestampID: timestamp)
            }
            .onDisappear {
                appTabBarVM.dropOneLevel(timestampID: timestamp)
            }
    }

    // MARK: Private

    @StateObject private var appTabBarVM: AppTabBarVM = .shared
    @State private var timestamp: Date = .init()
    @State private var visibility: SwiftUI.Visibility
}

extension View {
    @ViewBuilder
    public func appTabBarVisibility(_ visibility: SwiftUI.Visibility) -> some View {
        modifier(AppTabBarVisibilityModifier(visibility))
        #if targetEnvironment(macCatalyst)
            .toolbar(.hidden, for: .tabBar)
        #else
            .toolbar(visibility, for: .tabBar)
        #endif
    }
}

#endif
