// This implementation is considered as copyleft from public domain.

import Foundation

extension Bundle {
    // - ⚠️ This API shalt not be defined as `public`.
    // Otherwise, it'll cause serious API name collisions.
    static var currentSPM: Bundle {
        #if compiler(>=6.0)
        if #available(iOS 15, macCatalyst 15, macOS 12, *) {
            #bundle
        } else {
            .module
        }
        #else
        .module
        #endif
    }
}
