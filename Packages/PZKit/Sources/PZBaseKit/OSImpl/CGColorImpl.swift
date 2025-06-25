// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Foundation

import CoreGraphics

extension CGColor {
    public struct HSLData: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat) {
            self.hue = hue
            self.saturation = saturation
            self.lightness = lightness
        }

        // MARK: Public

        public let hue: CGFloat
        public let saturation: CGFloat
        public let lightness: CGFloat
    }

    public func normalized(forceOpposiveHue: Bool = false) -> CGColor? {
        // 步骤 1：获取 HSL 值（转换为整数）
        guard let hsl = toHSL() else { return nil }
        let hue = hsl.hue

        // 步骤 3：检查饱和度，如果过低（趋近灰度），返回 nil
        // 使用整数阈值，假设饱和度 < 10（即 0.1 * 100）为灰度
        guard hsl.saturation >= 10 else { return nil }

        // 步骤 2：保留 Hue，设置 Saturation 为 100（完全饱和），Lightness 为 50（中间值）
        let normalizedHSL = HSLData(
            hue: forceOpposiveHue ? (hue + 180.0).truncatingRemainder(dividingBy: 360.0) : hue,
            saturation: 100,
            lightness: 50
        )

        // 步骤 4：将 HSL 转换回 RGB 并创建 CGColor
        guard let rgb = Self.hslToRGB(normalizedHSL) else { return nil }

        // 创建 CGColor
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components = [
            CGFloat(rgb.r) / 255.0,
            CGFloat(rgb.g) / 255.0,
            CGFloat(rgb.b) / 255.0,
            1, // 完全不透明。
        ]
        return CGColor(colorSpace: colorSpace, components: components)
    }

    // 将 CGColor 转换为 HSL（返回整数值：Hue [0, 360], Saturation [0, 100], Lightness [0, 100]）
    public func toHSL() -> HSLData? {
        guard let components = components, numberOfComponents >= 3,
              let colorSpace = colorSpace, colorSpace.model == .rgb else {
            return nil
        }

        // 将 RGB 转换为 0-255 范围
        let r = CGFloat(components[0] * 255.0)
        let g = CGFloat(components[1] * 255.0)
        let b = CGFloat(components[2] * 255.0)

        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let delta = maxVal - minVal

        var hue: CGFloat = 0.0
        var saturation: CGFloat
        let lightness = (maxVal + minVal) / 2 // [0, 255]

        if delta == 0.0 {
            // 灰度色，hue 为 0，saturation 为 0
            saturation = 0.0
        } else {
            // 计算饱和度
            saturation = (delta * 100.0) / (255.0 - abs(2 * lightness - 255.0)) // [0, 100]

            // 计算色调
            if maxVal == r {
                hue = ((g - b) * 60.0) / delta // [0, 360]
                hue = hue < 0.0 ? hue + 360.0 : hue
            } else if maxVal == g {
                hue = ((b - r) * 60.0) / delta + 120.0
            } else {
                hue = ((r - g) * 60.0) / delta + 240.0
            }
        }

        // 确保值在范围内
        let clampedHue = hue.clamp(to: 0.0 ... 360.0)
        let clampedSaturation = saturation.clamp(to: 0.0 ... 100.0)
        let clampedLightness = (lightness * 100 / 255).clamp(to: 0.0 ... 100.0)
        return .init(
            hue: clampedHue,
            saturation: clampedSaturation,
            lightness: clampedLightness
        )
    }

    // 将 HSL（整数）转换为 RGB（返回 0-255 的整数值）
    public static func hslToRGB(_ hsl: HSLData) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        let h = hsl.hue
        let s = hsl.saturation
        let l = hsl.lightness

        // 将 HSL 转换为 0-255 范围
        let c = (100.0 - abs(2 * l - 100.0)) * s / 100.0 // Chroma
        let hPrime = h / 60.0 // [0, 6]
        let hMod120 = h.truncatingRemainder(dividingBy: 120.0) // 计算 h % 120.0
        let absResult = abs(hMod120 - 60.0) // 计算 abs((h % 120.0) - 60.0)
        let term2 = absResult * 100.0 / 60.0 // 计算 abs(...) * 100.0 / 60.0
        let term1 = 100.0 - term2 // 计算 100.0 - abs(...) * 100.0 / 60.0
        let x = c * term1 / 100.0 // 最终计算
        let m = l - c / 2

        var r = 0.0
        var g = 0.0
        var b = 0.0

        switch Int(hPrime.rounded(.down)) {
        case 0:
            r = c
            g = x
            b = 0.0
        case 1:
            r = x
            g = c
            b = 0.0
        case 2:
            r = 0.0
            g = c
            b = x
        case 3:
            r = 0.0
            g = x
            b = c
        case 4:
            r = x
            g = 0.0
            b = c
        case 5:
            r = c
            g = 0.0
            b = x
        default:
            return nil
        }

        return (
            r: (r + m).clamp(to: 0.0 ... 255.0),
            g: (g + m).clamp(to: 0.0 ... 255.0),
            b: (b + m).clamp(to: 0.0 ... 255.0)
        )
    }
}

// 辅助扩展：限制 CGFloat 到指定范围
extension CGFloat {
    fileprivate func clamp(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
