// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import CoreTransferable
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

#if !os(watchOS)

@available(iOS 17.0, macCatalyst 17.0, *)
public struct HEICImage: Transferable, FileDocument {
    // MARK: Lifecycle

    public init(cgImage: CGImage, filename: String) {
        self.cgImage = cgImage
        self.filename = filename
    }

    public init(configuration: ReadConfiguration) throws {
        self.cgImage = nil
    }

    // MARK: Public

    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .heic) { item in
            let fileName = item.filename
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            if let cgImage = item.cgImage, let destination = CGImageDestinationCreateWithURL(
                fileURL as CFURL,
                UTType.heic.identifier as CFString,
                1,
                nil
            ) {
                CGImageDestinationAddImage(destination, cgImage, nil)
                CGImageDestinationFinalize(destination)
            }
            return SentTransferredFile(fileURL)
        }
    }

    public static var readableContentTypes: [UTType] { [.heic] }

    public var filename: String = "Image_\(Int(Date().timeIntervalSince1970)).heic"

    public var cgImage: CGImage?

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let cgImage = cgImage else {
            throw CocoaError(.fileWriteUnknown)
        }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.heic.identifier as CFString,
            1,
            nil
        ) else {
            throw CocoaError(.fileWriteUnknown)
        }

        CGImageDestinationAddImage(destination, cgImage, nil)
        CGImageDestinationFinalize(destination)

        let wrapper = FileWrapper(regularFileWithContents: data as Data)
        wrapper.preferredFilename = filename
        return wrapper
    }
}

#endif
