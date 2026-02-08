// This implementation is considered as copyleft from public domain.

import Foundation
import SwiftUI

// MARK: - Optional Modifier Wrappers

extension View {
    @ViewBuilder
    public func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> some View {
        block(self)
    }
}
