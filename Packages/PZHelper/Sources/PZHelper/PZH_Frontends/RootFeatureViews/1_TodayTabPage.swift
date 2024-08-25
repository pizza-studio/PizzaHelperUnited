// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import SwiftUI

struct TodayTabPage: View {
    @MainActor var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(verbatim: "该页面用以陈列所有已联网的本地帐号的树脂/开拓力倒计时状态。")
                        Text(verbatim: "在点击某个帐号的状态树脂卡片之后，会直接进入该帐号的详情页面。之前的详情页面设计就不再需要了。")
                        Text(verbatim: "该页面右上角会有一个开关、来切换所有状态卡片的排版（是紧凑显示、还是展开显示），借此满足不同使用者的不同偏好。")
                        Text(
                            verbatim: "如果有本地帐号出现了联网问题的话，会留有文字、提请使用者手动前往 App 设定页面检查联网状态。此处不再直接跳转，但仍提供下拉刷新（且对 macOS 系统提供单独的刷新按钮）。"
                        )
                    }
                    .multilineTextAlignment(.leading)
                    .font(.caption)
                } header: {
                    Text(verbatim: "该页面待施工")
                }
                .listRowMaterialBackground()
            }.formStyle(.grouped)
                .navigationTitle("tab.today.fullTitle".i18nPZHelper)
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .listContainerBackground()
        }
    }
}
