// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import ImageIO

// MARK: - Image Constructor from path.

extension CGImage {
    public static func instantiate(filePath path: String) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(
            URL(fileURLWithPath: path) as CFURL,
            nil
        ) else { return nil }
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }

    public static func instantiate(url: URL) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }

    public func zoomed(_ factor: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage? {
        guard factor > 0 else { return nil }
        let size: CGSize = .init(width: CGFloat(width) * factor, height: CGFloat(height) * factor)
        return directResized(size: size, quality: quality)
    }

    public func directResized(size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
        // Ref: https://rockyshikoku.medium.com/resize-cgimage-baf23a0f58ab
        let width = Int(floor(size.width))
        let height = Int(floor(size.height))

        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = colorSpace else { return nil }
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: alphaInfo.rawValue
        ) else { return nil }

        context.interpolationQuality = quality
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}
