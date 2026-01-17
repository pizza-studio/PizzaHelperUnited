// This implementation is considered as copyleft from public domain.

import Foundation

extension Bundle {
    // - ⚠️ This API shalt not be defined as `public`.
    // Otherwise, it'll cause serious API name collisions.
    static var currentSPM: Bundle {
        if #available(iOS 15, *) {
            #bundle
        } else {
            .module
        }
    }
}
