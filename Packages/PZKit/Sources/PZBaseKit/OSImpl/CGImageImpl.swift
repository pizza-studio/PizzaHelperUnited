// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import ImageIO
#if !os(watchOS)
import CoreImage
#endif
import UniformTypeIdentifiers

// MARK: - Image Constructor from path.

extension CGImage {
    public static func instantiate(data: Data) -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData) else { return nil }
        let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil)
        guard let imageSource else { return nil }
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }

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

        // 检查尺寸有效性
        guard width > 0, height > 0 else { return nil }

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

    /// CoreImage 支援硬件加速。
    @preconcurrency
    public func zoomedByCoreImage(
        _ factor: CGFloat
    )
        -> CGImage? {
        guard factor > 0 else { return nil }
        #if os(watchOS)
        return zoomed(factor, quality: .high)
        #else
        let width = Int(floor(CGFloat(width) * factor))
        let height = Int(floor(CGFloat(height) * factor))
        guard width > 0, height > 0 else { return nil }

        let ciImage = CIImage(cgImage: self)
        let scaleX = Double(width) / Double(self.width)
        let scaleY = Double(height) / Double(self.height)
        let scaled: CIImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // CIContext 默认就会用 Metal/GPU 或高效 CPU 路径
        let context = CIContext(options: [CIContextOption.highQualityDownsample: true])
        return context.createCGImage(scaled, from: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        #endif
    }
}

extension CGImage {
    public func crop(to rect: CGRect) -> CGImage? {
        // 检查宽高有效性
        guard rect.width > 0, rect.height > 0,
              rect.origin.x.isFinite, rect.origin.y.isFinite,
              rect.width.isFinite, rect.height.isFinite
        else { return nil }

        // 与图片像素坐标系对齐（CoreGraphics 坐标，左上为 (0,0)）
        let imgWidth = CGFloat(width)
        let imgHeight = CGFloat(height)
        var cropRect = CGRect(
            x: rect.origin.x,
            y: imgHeight - rect.origin.y - rect.size.height,
            width: rect.size.width,
            height: rect.size.height
        )

        // 裁剪区域与图片没有交集
        guard cropRect.intersects(CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)) else {
            return nil
        }

        // 裁剪区域修正到图片内
        cropRect = cropRect.intersection(CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight))
        guard cropRect.width > 0, cropRect.height > 0 else { return nil }

        // 最终裁剪
        return cropping(to: cropRect)
    }
}

// MARK: - CGImage.CGImageExportFormat

extension CGImage {
    public enum CGImageExportFormat: Sendable, Hashable {
        case jpeg(quality: CGFloat)
        case png
        case heic(quality: CGFloat)

        // MARK: Fileprivate

        fileprivate var uti: CFString {
            switch self {
            case .jpeg: return UTType.jpeg.identifier as CFString
            case .png: return UTType.png.identifier as CFString
            case .heic: return UTType.heic.identifier as CFString
            }
        }

        fileprivate var options: [CFString: Any] {
            switch self {
            case let .jpeg(quality):
                return [kCGImageDestinationLossyCompressionQuality: quality]
            case .png:
                return [:]
            case let .heic(quality):
                return [kCGImageDestinationLossyCompressionQuality: quality]
            }
        }
    }

    /// 将 CGImage 导出为指定格式的 Data
    /// - Parameter format: 导出格式和参数
    /// - Returns: 图片 Data，失败返回 nil
    public func encodeToFileData(as format: CGImageExportFormat) -> Data? {
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data, format.uti, 1, nil) else {
            return nil
        }
        CGImageDestinationAddImage(dest, self, format.options as CFDictionary)
        guard CGImageDestinationFinalize(dest) else {
            return nil
        }
        return data as Data
    }
}
