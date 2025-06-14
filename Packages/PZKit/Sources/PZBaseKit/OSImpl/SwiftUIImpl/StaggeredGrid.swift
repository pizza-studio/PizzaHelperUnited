//  StaggeredGrid for SwiftUI.
//
//  Written by 李宇鸿 on 2022/8/13; Refactored by Shiki Suen on 2025/06/15.
//  Original version: https://blog.csdn.net/qq_42816425/article/details/126325803

import SwiftUI

// MARK: - StaggeredGrid

// 自定义视图构建器…… Content 外界传递的视图

// T -> 是用来保存可识别的数据集合… 外界传递的列表模型数据

public struct StaggeredGrid<Content: View, T: Identifiable & Equatable>: View {
    // MARK: Lifecycle

    // MARK: - Initialization

    public init(
        columns: Int,
        scrollAxis: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        horizontalSpacing: CGFloat = 10,
        verticalSpacing: CGFloat = 10,
        padding: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10),
        alignment: VerticalAlignment = .top,
        list: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        // 验证 columns 参数
        guard columns > 0 else {
            fatalError("Columns must be greater than 0")
        }
        self.columns = columns
        self.scrollAxis = scrollAxis
        self.showsIndicators = showsIndicators
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.padding = padding
        self.alignment = alignment
        self.content = content
        self.list = list
        // 初始化网格数据
        self._gridArray = State(initialValue: Self.computeGridArray(list: list, columns: columns))
    }

    // MARK: Public

    // MARK: - Body

    public var body: some View {
        Group {
            if scrollAxis != [] {
                ScrollView(scrollAxis, showsIndicators: showsIndicators) {
                    innerContent
                }
            } else {
                innerContent
            }
        }
        // 监听 list 和 columns 变化，更新网格数据
        .onChange(of: list) { _, newList in
            gridArray = Self.computeGridArray(list: newList, columns: columns)
        }
        .onChange(of: columns) { _, newColumns in
            guard newColumns > 0 else { return }
            gridArray = Self.computeGridArray(list: list, columns: newColumns)
        }
    }

    // MARK: Private

    // 缓存网格数据，优化性能
    @State private var gridArray: [[T]] = []

    private let columns: Int
    private let scrollAxis: Axis.Set
    private let showsIndicators: Bool
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let padding: EdgeInsets
    private let alignment: VerticalAlignment
    private let content: (T) -> Content
    private let list: [T]

    private var innerContent: some View {
        HStack(alignment: alignment, spacing: horizontalSpacing) {
            ForEach(Array(gridArray.enumerated()), id: \.offset) { _, columnsData in
                LazyVStack(spacing: verticalSpacing) {
                    ForEach(columnsData) { object in
                        content(object)
                    }
                }
            }
        }
        .padding(padding)
    }

    // 计算网格数据，将列表分配到列中
    private static func computeGridArray(list: [T], columns: Int) -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex = 0
        for object in list {
            gridArray[currentIndex].append(object)
            currentIndex = currentIndex == (columns - 1) ? 0 : currentIndex + 1
        }
        return gridArray
    }
}

extension StaggeredGrid {
    // 提供构造函数的闭包
    public init(
        columns: Int,
        showsIndicators: Bool = false,
        outerPadding: Bool = true,
        scroll: Bool = true,
        spacing: CGFloat = 10,
        list: [T],
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        self.init(
            columns: columns,
            scrollAxis: .vertical,
            showsIndicators: showsIndicators,
            horizontalSpacing: spacing,
            verticalSpacing: spacing,
            padding: outerPadding
                ? .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
                : .init(top: 0, leading: 0, bottom: 0, trailing: 0),
            alignment: .top,
            list: list,
            content: content
        )
    }
}
