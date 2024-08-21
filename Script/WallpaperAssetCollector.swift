#!/usr/bin/env swift

import AppKit
import AVFoundation
import Foundation

// 该脚本专门用来整理星穹铁道的手机壁纸、以及原神的名片。
// 出于某些原因，现阶段仅处理原神的名片素材。

// MARK: - NSImage Extensions

extension NSImage {
    @MainActor
    func asPNGData() throws -> Data {
        guard let tiffData = tiffRepresentation, let imageRep = NSBitmapImageRep(data: tiffData) else {
            throw NSError(domain: "ImageConversionError", code: -1, userInfo: nil)
        }
        guard let newData = CFDataCreateMutable(kCFAllocatorDefault, 0) else {
            throw NSError(domain: "CFDataAllocationError", code: -1, userInfo: nil)
        }

        guard let destination = CGImageDestinationCreateWithData(newData, "public.png" as CFString, 1, nil),
              let cgImage = imageRep.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw NSError(domain: "HEICConversionError", code: -1, userInfo: nil)
        }

        let options = [kCGImageDestinationLossyCompressionQuality: 1.0] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)

        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "HEICEncodingError", code: -1, userInfo: nil)
        }
        return newData as Data
    }

    func saveRaw(to url: URL) throws {
        try tiffRepresentation?.write(to: url, options: .atomic)
    }
}

// MARK: - Extract Filename Stem

extension String {
    func extractFileNameStem() -> String {
        split(separator: "/").last?.split(separator: ".").dropLast().joined(separator: ".").description ?? self
    }
}

