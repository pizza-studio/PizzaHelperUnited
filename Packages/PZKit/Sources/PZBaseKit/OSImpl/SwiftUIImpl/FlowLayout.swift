// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - FlowLayout

public struct FlowLayout: Layout {
    // MARK: Lifecycle

    public init(spacing: CGFloat) {
        self.spacing = Swift.max(0.0, spacing)
    }

    // MARK: Public

    public var spacing: CGFloat

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    )
        -> CGSize {
        guard !subviews.isEmpty, let width = proposal.width, width > 0 else { return .zero }

        var totalHeight: CGFloat = 0
        var currentLineWidth: CGFloat = 0
        var currentLineHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            guard size.width.isFinite, size.height.isFinite, size.width >= 0, size.height >= 0 else { continue }

            if currentLineWidth + size.width + spacing > width {
                totalHeight += currentLineHeight + spacing
                currentLineWidth = size.width
                currentLineHeight = size.height
            } else {
                currentLineWidth += size.width + (currentLineWidth > 0 ? spacing : 0)
                currentLineHeight = max(currentLineHeight, size.height)
            }
        }

        totalHeight += currentLineHeight
        if let maxHeight = proposal.height, maxHeight > 0 {
            totalHeight = min(totalHeight, maxHeight)
        }
        return CGSize(width: width, height: totalHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !subviews.isEmpty, let width = proposal.width, width > 0 else { return }

        var currentX = bounds.minX
        var currentY = bounds.minY
        var currentLineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            guard size.width.isFinite, size.height.isFinite, size.width >= 0, size.height >= 0 else { continue }

            if currentX + size.width > bounds.maxX {
                totalHeight += currentLineHeight + spacing
                if let maxHeight = proposal.height, totalHeight >= maxHeight { break }
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

// MARK: - FlowLayoutView

public struct FlowLayoutView<T: View, Element: Hashable>: View {
    // MARK: Lifecycle

    public init(
        spacing: CGFloat,
        items: [Element],
        @ViewBuilder itemView: @MainActor @escaping (Element) -> T
    ) {
        self.items = items
        self.spacing = Swift.max(0.0, spacing)
        self.itemView = itemView
    }

    // MARK: Public

    public var body: some View {
        FlowLayout(spacing: spacing) {
            ForEach(items, id: \.self) { item in
                itemView(item)
            }
        }
        .frame(width: containerSize.width)
        .trackCanvasSize(debounceDelay: 0.1) { size in
            containerSize = size
        }
    }

    // MARK: Private

    @State private var containerSize: CGSize = .zero

    private let items: [Element]
    private let spacing: CGFloat
    private let itemView: (Element) -> T
}
