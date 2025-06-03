// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if DEBUG

#if os(macOS)
import CoreImage
#endif
import Foundation
import SwiftUI

extension BundledWallpaper {
    public static func queryImageAsset(for assetName: String) -> CGImage? {
        #if os(macOS)
        guard let image = Bundle.module.image(forResource: assetName) else { return nil }
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        return imageRef
        #elseif os(iOS)
        return UIImage(named: assetName, in: Bundle.module, compatibleWith: nil)?.cgImage
        #else
        return nil
        #endif
    }
}

#endif
