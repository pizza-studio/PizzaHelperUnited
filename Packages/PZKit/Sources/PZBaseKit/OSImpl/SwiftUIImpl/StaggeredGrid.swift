// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - StaggeredGrid

@available(iOS 17.0, macCatalyst 17.0, *)
public struct StaggeredGrid<Content: View, T: Identifiable & Equatable & Sendable>: View {
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
        self._vm = .init(wrappedValue: StaggeredGridVM(list: list, columns: columns))
    }

    // MARK: Public

    // MARK: - Body

    public var body: some View {
        Group {
            let axisSet = scrollAxis.isEmpty ? Axis.Set([.vertical]) : scrollAxis
            ScrollView(axisSet, showsIndicators: showsIndicators && !scrollAxis.isEmpty) {
                innerContent
            }
            .scrollDisabled(scrollAxis.isEmpty)
        }
        .onChange(of: list) { _, newList in
            vm.updateGridArray(list: newList, columns: columns)
        }
        .onChange(of: columns) { _, newColumns in
            guard newColumns > 0 else { return }
            vm.updateGridArray(list: list, columns: newColumns)
        }
        .onAppear {
            if vm.gridArray.isEmpty, !list.isEmpty {
                vm.updateGridArray(list: list, columns: columns)
            }
        }
    }

    // MARK: Private

    @State private var vm: StaggeredGridVM<T>

    private let columns: Int
    private let scrollAxis: Axis.Set
    private let showsIndicators: Bool
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let padding: EdgeInsets
    private let alignment: VerticalAlignment
    private let content: (T) -> Content
    private let list: [T]

    private var scroll: Bool { scrollAxis.isEmpty }

    @ViewBuilder private var innerContent: some View {
        HStack(alignment: alignment, spacing: horizontalSpacing) {
            ForEach(Array(vm.gridArray.enumerated()), id: \.offset) { _, columnsData in
                LazyVStack(spacing: verticalSpacing) {
                    ForEach(columnsData) { object in
                        content(object)
                    }
                }
            }
        }
        .padding(padding)
    }
}

// MARK: - StaggeredGridVM

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
final class StaggeredGridVM<T: Identifiable & Equatable & Sendable> {
    // MARK: Lifecycle

    // MARK: - Initialization

    init(list: [T] = [], columns: Int = 1) {
        if !list.isEmpty, columns > 0 {
            self.gridArray = computeGridArray(list: list, columns: columns)
        }
    }

    // MARK: Internal

    var gridArray: [[T]] = []

    // MARK: - Methods

    func updateGridArray(list: [T], columns: Int) {
        let oldTask = updateTask
        // 异步计算
        // let threshold = 100 // 可调整的阈值
        let newTask = Task.detached(priority: .userInitiated) {
            _ = await oldTask?.value
            let newGridArray: [[T]] = await self.computeGridArray(
                list: list, columns: columns
            )
            await MainActor.run {
                if !Task.isCancelled {
                    withAnimation {
                        self.gridArray = newGridArray
                    }
                }
            }
        }
        updateTask = newTask
    }

    // MARK: Private

    private var updateTask: Task<Void, Never>?

    // 异步计算方法，会彻底打碎排序。慎用。
    private func computeGridArrayAsync(list: [T], columns: Int) async -> [[T]] {
        await withTaskGroup(of: [T].self) { group in
            let chunkSize = max(1, list.count / columns)
            for i in 0 ..< columns {
                let start = i * chunkSize
                let end = min((i + 1) * chunkSize, list.count)
                group.addTask {
                    Array(list[start ..< end])
                }
            }
            var gridArray: [[T]] = Array(repeating: [], count: columns)
            for await chunk in group {
                if let index = gridArray.firstIndex(where: { $0.isEmpty }) {
                    gridArray[index] = chunk
                }
            }
            return gridArray
        }
    }

    // 同步计算方法
    private func computeGridArray(list: [T], columns: Int) -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        var currentIndex = 0
        for object in list {
            gridArray[currentIndex].append(object)
            currentIndex = currentIndex == (columns - 1) ? 0 : currentIndex + 1
        }
        return gridArray
    }
}

// MARK: - API Compatibility

@available(iOS 17.0, macCatalyst 17.0, *)
extension StaggeredGrid {
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
            scrollAxis: [],
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
