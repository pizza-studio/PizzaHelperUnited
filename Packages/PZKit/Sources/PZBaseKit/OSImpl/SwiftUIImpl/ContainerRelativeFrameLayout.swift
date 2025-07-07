import SwiftUI

// MARK: - ContainerRelativeFrameLayout

@available(iOS 16.0, macCatalyst 16.0, watchOS 9.0, *)
private struct ContainerRelativeFrameLayout: Layout {
    // MARK: Lifecycle

    public init(
        _ axes: Axis.Set,
        alignment: Alignment = .center,
        length: @escaping @Sendable (CGFloat, Axis) -> CGFloat // 确保闭包为 Sendable
    ) {
        self.axes = axes
        self.alignment = alignment
        self.length = length
    }

    // MARK: Public

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    )
        -> CGSize {
        guard let subview = subviews.first else {
            return proposal.replacingUnspecifiedDimensions(by: .zero)
        }

        // 获取容器尺寸，处理未指定情况
        let intrinsicSize = subview.sizeThatFits(.unspecified)
        let containerWidth = proposal.width ?? intrinsicSize.width
        let containerHeight = proposal.height ?? intrinsicSize.height

        // 根据轴和 length 闭包计算尺寸
        let width = axes.contains(.horizontal) ? max(0, length(containerWidth, .horizontal)) : intrinsicSize.width
        let height = axes.contains(.vertical) ? max(0, length(containerHeight, .vertical)) : intrinsicSize.height

        // 验证子视图是否能适应计算尺寸
        let proposedSize = ProposedViewSize(width: width, height: height)
        let childSize = subview.sizeThatFits(proposedSize)

        return CGSize(
            width: axes.contains(.horizontal) ? width : childSize.width,
            height: axes.contains(.vertical) ? height : childSize.height
        )
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard let subview = subviews.first else { return }

        // 获取容器尺寸
        let intrinsicSize = subview.sizeThatFits(.unspecified)
        let containerWidth = bounds.width
        let containerHeight = bounds.height

        // 计算子视图尺寸
        let width = axes.contains(.horizontal) ? max(0, length(containerWidth, .horizontal)) : intrinsicSize.width
        let height = axes.contains(.vertical) ? max(0, length(containerHeight, .vertical)) : intrinsicSize.height

        // 转换为 UnitPoint 以处理对齐
        let unitPoint = alignmentToUnitPoint(alignment)

        // 计算位置
        let x = bounds.minX + (containerWidth - width) * unitPoint.x
        let y = bounds.minY + (containerHeight - height) * unitPoint.y

        subview.place(
            at: CGPoint(x: x, y: y),
            anchor: .topLeading,
            proposal: ProposedViewSize(width: width, height: height)
        )
    }

    // MARK: Private

    private let axes: Axis.Set
    private let alignment: Alignment
    private let length: @Sendable (CGFloat, Axis) -> CGFloat // 标记为 @Sendable

    // 将 Alignment 转换为 UnitPoint（iOS 16 兼容）
    private func alignmentToUnitPoint(_ alignment: Alignment) -> UnitPoint {
        // iOS 16 及以下，手动映射常见对齐方式
        switch alignment {
        case .center:
            return .center // (0.5, 0.5)
        case .leading:
            return .leading // (0, 0.5)
        case .trailing:
            return .trailing // (1, 0.5)
        case .top:
            return .top // (0.5, 0)
        case .bottom:
            return .bottom // (0.5, 1)
        case .topLeading:
            return .topLeading // (0, 0)
        case .topTrailing:
            return .topTrailing // (1, 0)
        case .bottomLeading:
            return .bottomLeading // (0, 1)
        case .bottomTrailing:
            return .bottomTrailing // (1, 1)
        default:
            // 自定义对齐或未知情况，默认居中
            return .center
        }
    }
}

// View 扩展
@available(iOS 16.0, macCatalyst 16.0, watchOS 9.0, *)
extension View {
    @MainActor
    public func containerRelativeFrameEX(
        _ axes: Axis.Set,
        alignment: Alignment = .center,
        _ length: @escaping @Sendable (CGFloat, Axis) -> CGFloat
    )
        -> some View {
        ContainerRelativeFrameLayout(axes, alignment: alignment, length: length) {
            self
        }
    }
}
