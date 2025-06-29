// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

public struct FlowLayout: Layout {
    // MARK: Lifecycle

    public init(spacing: CGFloat) {
        self.spacing = spacing
    }

    // MARK: Public

    public var spacing: CGFloat = 8

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    )
        -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        var totalHeight: CGFloat = 0
        var currentLineWidth: CGFloat = 0
        var currentLineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)

            if currentLineWidth + size.width + spacing > proposal.width! {
                // 换行
                totalHeight += currentLineHeight + spacing
                currentLineWidth = size.width
                currentLineHeight = size.height
            } else {
                // 继续当前行
                currentLineWidth += size.width + (currentLineWidth > 0 ? spacing : 0)
                currentLineHeight = max(currentLineHeight, size.height)
            }
        }

        totalHeight += currentLineHeight
        return CGSize(width: proposal.width!, height: totalHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }

        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentLineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)

            if currentX + size.width > bounds.maxX {
                // 换行
                currentY += currentLineHeight + spacing
                currentX = bounds.minX
                currentLineHeight = 0
            }

            view.place(
                at: CGPoint(x: currentX, y: currentY),
                anchor: .topLeading,
                proposal: .init(size)
            )

            currentX += size.width + spacing
            currentLineHeight = max(currentLineHeight, size.height)
        }
    }
}
