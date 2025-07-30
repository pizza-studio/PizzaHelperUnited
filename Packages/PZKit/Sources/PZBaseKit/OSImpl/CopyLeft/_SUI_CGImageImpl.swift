// This implementation is considered as copyleft from public domain.

import Foundation
import SwiftUI

extension Image {
    public static func from(path: String) -> Image? {
        guard let cgImage = CGImage.instantiate(filePath: path) else { return nil }
        return Image(decorative: cgImage, scale: 1)
    }
}
