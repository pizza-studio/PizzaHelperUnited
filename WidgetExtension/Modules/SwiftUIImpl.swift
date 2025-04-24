// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - ImageMap

@MainActor
final class ImageMap {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let shared = ImageMap()

    public var assetMap: [URL: SendableImagePtr] = [:]

    public func insertValue(url: URL, image: SendableImagePtr) {
        assetMap[url] = image
    }
}

// MARK: - SendableImagePtr

final class SendableImagePtr: Sendable {
    // MARK: Lifecycle

    public init(img: Image) { self.img = img }

    // MARK: Public

    public let img: Image
}
