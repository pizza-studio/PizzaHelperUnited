// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import ImageIO
#if !os(watchOS)
import CoreImage
#endif
import UniformTypeIdentifiers

// MARK: - Constructors.

extension CGImage {
    /// 从Data建立副本
    public static func instantiate(data: Data, forceJPEG: Bool = false) -> CGImage? {
        guard let dataProvider = CGDataProvider(data: data as CFData) else { return nil }
        guard let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil) else { return nil }
        return loadImage(from: imageSource, forceJPEG: forceJPEG)
    }

    /// 从路径建立副本
    public static func instantiate(filePath path: String, forceJPEG: Bool = false) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(
            URL(fileURLWithPath: path) as CFURL,
            nil
        ) else { return nil }
        return loadImage(from: imageSource, forceJPEG: forceJPEG)
    }

    /// 从URL建立副本
    public static func instantiate(url: URL, forceJPEG: Bool = false) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return loadImage(from: imageSource, forceJPEG: forceJPEG)
    }

    /// 不带JPEG类型提示的共享选项
    private static var sharedCGImageOptions: CFDictionary {
        [
            kCGImageSourceShouldCache: true,
            kCGImageSourceShouldAllowFloat: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        ] as CFDictionary
    }

    /// 带JPEG类型提示的共享选项
    private static var sharedCGImageOptionsJPEG: CFDictionary {
        [
            kCGImageSourceShouldCache: true,
            kCGImageSourceShouldAllowFloat: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceTypeIdentifierHint: UTType.jpeg.identifier as CFString,
        ] as CFDictionary
    }

    /// 共享的重新编码选项
    private static var sharedCGImageDestinationOptions: CFDictionary {
        [
            kCGImageDestinationLossyCompressionQuality: 1.0,
            kCGImageDestinationEmbedThumbnail: false,
            kCGImagePropertyColorModel: kCGImagePropertyColorModelRGB,
            kCGImageDestinationMetadata: [] as CFArray, // Strip all metadata, including color profile
        ] as CFDictionary
    }

    /// 通过CGContext进行替代解码。
    /// 有些表情包的图片是用 URGB 色彩空间编码的，必须手动解码，否则只能解出一张白色噪点图。
    private static func decodeImageManually(_ sourceImage: CGImage, width: Int, height: Int) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // 修正 bitmapInfo，保留 alpha channel
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            print("Failed to create CGContext for manual decoding")
            return nil
        }

        context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }

    /// 处理通用图像加载和重新编码逻辑的私有方法
    private static func loadImage(from source: CGImageSource, forceJPEG: Bool) -> CGImage? {
        // Debug: 诊断 Image 中继资料
        var width = 0
        var height = 0
        if let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] {
            print("Image Properties: \(properties)")
            if let jfif = properties[kCGImagePropertyJFIFDictionary as String] as? [String: Any],
               let isProgressive = jfif[kCGImagePropertyJFIFIsProgressive as String] as? Bool {
                print("Progressive JPEG: \(isProgressive)")
            }
            if let profile = properties[kCGImagePropertyProfileName as String] {
                print("Color Profile: \(profile)")
            }
            if let exif = properties[kCGImagePropertyExifDictionary as String] as? [String: Any] {
                print("EXIF Data: \(exif)")
            }
            if let pixelWidth = properties[kCGImagePropertyPixelWidth as String] as? Int,
               let pixelHeight = properties[kCGImagePropertyPixelHeight as String] as? Int {
                width = pixelWidth
                height = pixelHeight
                print("Dimensions: \(width)x\(height)")
            }
        }

        // 针对是否启用 forceJPEG 的情况启用不同的 options
        let options = forceJPEG ? sharedCGImageOptionsJPEG : sharedCGImageOptions

        // 尝试直接读取
        if let cgImage = CGImageSourceCreateImageAtIndex(source, 0, options) {
            print("Direct loading successful")
            // 尝试手动解码，以求绕过有故障的色彩空间配置
            if width > 0, height > 0, let decodedImage = decodeImageManually(cgImage, width: width, height: height) {
                print("Manual decoding successful")
                return decodedImage
            }
            print("Manual decoding skipped or failed, returning direct-loaded image")
            return cgImage
        }

        print("Direct loading failed, attempting re-encoding...")

        // 回退：重新编码，将色彩空间标准化
        guard let destinationData = CFDataCreateMutable(nil, 0) else {
            print("Failed to create mutable data for re-encoding")
            return nil
        }
        guard let destination = CGImageDestinationCreateWithData(
            destinationData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            print("Failed to create image destination")
            return nil
        }

        CGImageDestinationAddImageFromSource(destination, source, 0, sharedCGImageDestinationOptions)
        guard CGImageDestinationFinalize(destination) else {
            print("Failed to finalize re-encoding")
            return nil
        }

        guard let newDataProvider = CGDataProvider(data: destinationData) else {
            print("Failed to create data provider for re-encoded image")
            return nil
        }
        guard let newImageSource = CGImageSourceCreateWithDataProvider(newDataProvider, nil) else {
            print("Failed to create image source for re-encoded image")
            return nil
        }

        // 检查重新编码的 Image 的属性是否合理
        if let reencodedProperties = CGImageSourceCopyPropertiesAtIndex(newImageSource, 0, nil) as? [String: Any] {
            print("Re-encoded Image Properties: \(reencodedProperties)")
            if let profile = reencodedProperties[kCGImagePropertyProfileName as String] {
                print("Re-encoded Color Profile: \(profile)")
            } else {
                print("Re-encoded image has no color profile")
            }
        }

        if let reencodedImage = CGImageSourceCreateImageAtIndex(newImageSource, 0, options) {
            print("Re-encoding successful")
            // 尝试将重新编码过的 Image 手动解码
            if width > 0, height > 0, let decodedImage = decodeImageManually(
                reencodedImage,
                width: width,
                height: height
            ) {
                print("Manual decoding of re-encoded image successful")
                return decodedImage
            }
            print("Manual decoding of re-encoded image skipped or failed, returning re-encoded image")
            return reencodedImage
        } else {
            print("Re-encoding failed to produce a valid image")
            return nil
        }
    }
}

// MARK: - Common Manipulators.

extension CGImage {
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

// MARK: - Genshin-Specific Manipulators

extension CGImage {
    /// 将矩形图像裁剪为圆形，圆形直径为 min(width, height) 的 70%，底边对齐图像底边中心
    /// - Returns: 裁剪后的圆形 CGImage，失败时返回 nil
    @preconcurrency
    public func croppedPilotPhoto4Genshin(debugMsgHandler: ((String) -> Void)? = nil) -> CGImage? {
        let width = CGFloat(width)
        let height = CGFloat(height)

        // 诊断：检查图像尺寸
        guard width > 0, height > 0 else {
            debugMsgHandler?("Invalid image dimensions: width = \(width), height = \(height)")
            return nil
        }

        // 计算最大可能圆形的直径（取宽度和高度中的较小值）
        let maxDiameter = min(width, height)
        // 圆形直径为最大直径的 70%
        let circleDiameter = maxDiameter * 0.7

        // 诊断：检查圆形直径
        guard circleDiameter > 0 else {
            debugMsgHandler?("Invalid circle diameter: \(circleDiameter)")
            return nil
        }

        // 计算圆心位置
        // x: 图像宽度中心（底边正中心）
        let centerX = width / 2
        // y: 使圆形底边贴紧图像底边（圆形最低点 y = height）
        let centerY = height - circleDiameter + 7 // 这里 +7 是手动篇移数值。

        // 创建圆形裁剪区域
        let circleRect = CGRect(
            x: centerX - circleDiameter / 2,
            y: centerY - circleDiameter / 2,
            width: circleDiameter,
            height: circleDiameter
        )

        // 诊断：检查裁剪区域
        debugMsgHandler?(
            "circleRect: \(circleRect), minX: \(circleRect.minX), maxX: \(circleRect.maxX), minY: \(circleRect.minY)"
        )

        // 验证裁剪区域是否在图像范围内（仅检查左右边界）
        guard circleRect.minX >= 0, circleRect.maxX <= width else {
            debugMsgHandler?(
                "Boundary check failed: minX = \(circleRect.minX), maxX = \(circleRect.maxX), width = \(width)"
            )
            return nil
        }

        // 创建新的图像上下文
        guard let context = CGContext(
            data: nil,
            width: Int(circleDiameter),
            height: Int(circleDiameter),
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo.rawValue
        ) else {
            debugMsgHandler?(
                "Failed to create CGContext. Color space: \(String(describing: colorSpace)), bitsPerComponent: \(bitsPerComponent), bitmapInfo: \(bitmapInfo.rawValue)"
            )
            return nil
        }

        // 设置裁剪路径为圆形
        context.addEllipse(in: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
        context.clip()

        // 绘制原始图像，调整位置使底边对齐
        let drawRect = CGRect(
            x: -circleRect.origin.x,
            y: -circleRect.origin.y,
            width: width,
            height: height
        )
        context.draw(self, in: drawRect)

        // 获取裁剪后的图像
        return context.makeImage()
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

// #if DEBUG
//
// import SwiftUI
//
// @MainActor var debugMsg = ""
//
// #Preview() {
//    let url =
//        URL(
//            string: "https://act-webstatic.mihoyo.com/hk4e/e20200928calculate/item_avatar_side_icon_u96d7e/8c08c93d61e4f4da591d56dd8dab8287.png"
//        )!
//    let cgImage = CGImage.instantiate(url: url)
//    let processed = cgImage?.croppedPilotPhoto4Genshin { msg in
//        debugMsg.append("\(msg)\n")
//    }
//    if let processed {
//        Text(verbatim: "Succeeded.")
//        Image(decorative: processed, scale: 1, orientation: .up)
//            .resizable()
//            .scaledToFit()
//            .frame(width: 90, height: 90)
//            .background(.red, in: .circle)
//            .fixedSize()
//    } else if let cgImage {
//        Text(verbatim: "Image is there.")
//        Text(verbatim: debugMsg)
//        Image(decorative: cgImage, scale: 1, orientation: .up)
//            .resizable()
//            .scaledToFit()
//            .frame(width: 90)
//            .background(.red, in: .circle)
//            .fixedSize()
//    } else {
//        Text(verbatim: "Phuqued up.")
//    }
// }
//
// #endif
