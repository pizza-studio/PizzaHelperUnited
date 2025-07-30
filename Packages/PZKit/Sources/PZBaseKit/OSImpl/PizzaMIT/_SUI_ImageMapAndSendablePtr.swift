// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

// MARK: - ImageMap

@MainActor
public final class ImageMap {
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

public final class SendableImagePtr: Sendable {
    // MARK: Lifecycle

    public init(img: Image) { self.img = img }

    // MARK: Public

    public let img: Image
}
