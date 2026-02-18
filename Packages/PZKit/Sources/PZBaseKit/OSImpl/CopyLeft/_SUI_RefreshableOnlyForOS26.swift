// This implementation is considered as copyleft from public domain.

import SwiftUI

extension View {
    @ViewBuilder
    nonisolated public func refreshableIfOS26(
        action: @escaping @Sendable () async -> Void
    )
        -> some View {
        if #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, watchOS 26.0, *) {
            self.refreshable(action: action)
        } else {
            self
        }
    }
}
