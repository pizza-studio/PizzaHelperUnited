// This implementation is considered as copyleft from public domain.

import Foundation
import SwiftUI

#if !os(watchOS)

// MARK: - ToolbarContent Extension

extension ToolbarContent {
    /// Disable the visibility of the glass background effect on items
    /// in the toolbar. In certain contexts, such as the navigation bar
    /// on iOS and the window toolbar on macOS, toolbar items will be
    /// given a glass background effect that is shared with other items
    /// in the same logical grouping.
    ///
    /// This modifier removes the visibility of that effect, resulting
    /// in that the item will be placed in its own grouping.
    ///
    ///     ContentView()
    ///         .toolbar {
    ///             ToolbarItem(placement: principal) {
    ///                 BuildStatus()
    ///             }
    ///             .removeSharedBackgroundVisibility()
    ///         }
    ///
    /// - Note: On iOS 26+, this applies `.sharedBackgroundVisibility(.hidden)`.
    ///   On earlier versions, this returns `self` unchanged.
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, visionOS 1.0, tvOS 16.0, *)
    public func removeSharedBackgroundVisibility(
        bypassWhen bypass: Bool = false
    )
        -> _GlassRemovedToolbarContent<Self> {
        _GlassRemovedToolbarContent(base: self, bypass: bypass)
    }
}

// MARK: - _GlassRemovedToolbarContent

/// A wrapper that conditionally applies `sharedBackgroundVisibility(.hidden)` on iOS 26+.
@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, visionOS 1.0, tvOS 16.0, *)
public struct _GlassRemovedToolbarContent<Base: ToolbarContent>: ToolbarContent {
    // MARK: Lifecycle

    @inlinable
    init(base: Base, bypass: Bool) {
        self.base = base
        self.bypass = bypass
    }

    // MARK: Public

    public var body: some ToolbarContent {
        _GlassRemovedToolbarContentBody(base: base, bypass: bypass)
    }

    // MARK: Internal

    @usableFromInline let base: Base
    @usableFromInline let bypass: Bool
}

@available(iOS 16.0, macOS 13.0, macCatalyst 16.0, visionOS 1.0, tvOS 16.0, *)
private struct _GlassRemovedToolbarContentBody<Base: ToolbarContent>: ToolbarContent {
    let base: Base
    let bypass: Bool

    @available(iOS 26.0, macOS 26.0, macCatalyst 26.0, visionOS 26.0, tvOS 26.0, *)
    var modifiedBody: some ToolbarContent {
        base.sharedBackgroundVisibility(bypass ? .automatic : .hidden)
    }

    var body: some ToolbarContent {
        if #available(iOS 26.0, macOS 26.0, macCatalyst 26.0, visionOS 26.0, tvOS 26.0, *) {
            modifiedBody
        } else {
            base
        }
    }
}

#endif
