// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import SwiftUI

// MARK: - CustomSegmentedPicker

@available(iOS 15.0, macCatalyst 15.0, *)
public struct CustomSegmentedPicker<Item: Identifiable & Sendable, Content: View>: View {
    // MARK: Lifecycle

    public init(
        selection: Binding<Item>,
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.items = items
        self.content = content
        self._selection = selection
    }

    // MARK: Public

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                content(item)
                    .modifier(CustomSegmentedPickerItemModifier(item: item, selection: $selection))
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.gray.opacity(0.1))
        )
        .frame(minHeight: 44) // 确保足够触控区域
    }

    // MARK: Internal

    @Binding var selection: Item // 绑定到选中的 ID

    let items: [Item] // 选项数组，需符合 Identifiable
    let content: (Item) -> Content // 自定义选项内容的闭包
}

// MARK: - CustomSegmentedPickerItemModifier

@available(iOS 15.0, macCatalyst 15.0, *)
private struct CustomSegmentedPickerItemModifier<Item: Identifiable & Sendable>: ViewModifier {
    // MARK: Lifecycle

    public init(item: Item, selection: Binding<Item>) {
        self.item = item
        self._selection = selection
    }

    // MARK: Public

    @ViewBuilder
    public func body(content: Content) -> some View {
        let selected: Bool = selection.id == item.id
        content
            .fixedSize()
            .frame(maxWidth: .infinity)
            .font(.footnote)
            .foregroundColor(selected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(selection.id == item.id ? Color.accentColor : .clear)
            }
            .animation(.easeInOut(duration: 0.2), value: selection.id)
            .contentShape(Capsule()) // 确保整个区域可点击
            .onTapGesture {
                selection = item // 更新选中状态
                simpleTaptic(type: .medium)
            }
    }

    // MARK: Private

    @Binding private var selection: Item

    private let item: Item
}
