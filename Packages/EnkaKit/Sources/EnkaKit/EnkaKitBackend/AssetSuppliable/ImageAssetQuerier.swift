// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
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

    public static func queryImageAssetSUI(for assetName: String) -> Image? {
        #if os(macOS)
        let instance = Bundle.module.image(forResource: assetName)
        guard instance != nil else { return nil }
        return Image(assetName, bundle: Bundle.module)
        #elseif os(iOS)
        let instance = UIImage(named: assetName, in: Bundle.module, compatibleWith: nil)
        guard instance != nil else { return nil }
        return Image(assetName, bundle: Bundle.module)
        #else
        return nil
        #endif
    }
}
