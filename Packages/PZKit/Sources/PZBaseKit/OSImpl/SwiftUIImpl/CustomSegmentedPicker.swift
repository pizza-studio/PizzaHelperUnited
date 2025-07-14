// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(iOS 15.0, macCatalyst 15.0, *)
public struct CustomSegmentedPicker<Item: Identifiable, Content: View>: View {
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
                let selected: Bool = selection.id == item.id
                // 选项内容
                content(item)
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
