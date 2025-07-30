// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import SwiftUI

// MARK: - RedrawnImage

@available(iOS 16.0, macCatalyst 16.0, *)
public struct RedrawnImage {
    // MARK: Lifecycle

    public init(_ image: Image, width: CGFloat, height: CGFloat) {
        self.image = image
        self.targetSize = CGSize(width: width, height: height)
    }

    public init(_ image: Image, size: CGSize) {
        self.image = image
        self.targetSize = size
    }

    // MARK: Public

    public var redrawn: Image {
        Image(size: targetSize) { ctx in
            ctx.draw(image, in: CGRect(origin: .zero, size: targetSize))
        }
    }

    // MARK: Private

    private let image: Image
    private let targetSize: CGSize
}

@available(iOS 16.0, macCatalyst 16.0, *)
extension Image {
    public func redrawn(_ size: CGSize) -> Image {
        RedrawnImage(self, size: size).redrawn
    }

    public func redrawn(width: CGFloat, height: CGFloat) -> Image {
        RedrawnImage(self, width: width, height: height).redrawn
    }
}
