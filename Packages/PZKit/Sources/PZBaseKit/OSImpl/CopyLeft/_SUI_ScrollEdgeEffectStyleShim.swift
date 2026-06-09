// This implementation is considered as copyleft from public domain.

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    public func scrollEdgeSoftened() -> some View {
        if #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, tvOS 26.0, watchOS 26.0, *) {
            scrollEdgeEffectStyle(.soft, for: .all)
        } else {
            self
        }
    }
}
