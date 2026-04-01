// This implementation is considered as copyleft from public domain.

import SwiftUI

extension View {
    @ViewBuilder @inlinable
    nonisolated public func foregroundTint(
        _ color: Color?,
        fallbackColor: Color = .primary
    )
        -> some View {
        if #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, watchOS 26.0, *) {
            foregroundStyle(color ?? fallbackColor)
        } else {
            // This API gets marked as deprecated since OS 26.4.
            foregroundColor(color)
        }
    }
}
