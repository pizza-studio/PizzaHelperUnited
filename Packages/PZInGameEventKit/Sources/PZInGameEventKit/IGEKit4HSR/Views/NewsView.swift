// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZBaseKit
import SwiftUI

// MARK: - NewsKitHSR.NewsView

extension NewsKitHSR {
    @available(watchOS, unavailable)
    public struct NewsView: View {
        // MARK: Lifecycle

        public init(_ aggregated: NewsKitHSR.AggregatedResult) {
            coordinator.data = aggregated
        }

        public init() {
            coordinator.updateData()
        }

        // MARK: Public

        @Observable @MainActor
        @available(watchOS, unavailable)
        public class Coordinator: ObservableObject, Sendable {
            // MARK: Lifecycle

            public init(data: NewsKitHSR.AggregatedResult) {
                self.data = data
            }

            public init() {
                self.data = .init()
            }

            // MARK: Public

            public func updateData() {
                Task { @MainActor in
                    withAnimation {
                        isLoading = true
                    }
                    let newData = await (try? NewsKitHSR.fetchAndAggregate()) ?? .init()
                    withAnimation {
                        data = newData
                        isLoading = false
                    }
                }
            }

            // MARK: Internal

            var data: NewsKitHSR.AggregatedResult

            var isLoading: Bool = false
        }

        public static let navEntryName = "igev.hsr.news.navEntryName".i18nIGEV

        public var data: NewsKitHSR.AggregatedResult { coordinator.data }

        // swiftlint:disable sf_safe_symbol
        public var body: some View {
            NavigationStack {
                currentTabContent
                    .overlay {
                        if coordinator.isLoading {
                            Color.clear
                                .frame(width: 128, height: 128)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay { ProgressView().frame(width: 100, height: 100) }
                        }
                    }
                    .toolbar {
                        #if os(macOS) || targetEnvironment(macCatalyst)
                        ToolbarItem(placement: .confirmationAction) {
                            Button("".description, systemImage: "arrow.clockwise") {
                                coordinator.updateData()
                            }
                        }
                        #endif
                        ToolbarItem(placement: .confirmationAction) {
                            Picker("".description, selection: $currentTab.animation()) {
                                Label("igev.hsr.news.Notices".i18nIGEV, systemImage: "info.circle")
                                    .tag(NewsKitHSR.NewsType.notices)
                                Label("igev.hsr.news.Events".i18nIGEV, systemImage: "calendar.badge.clock")
                                    .tag(NewsKitHSR.NewsType.events)
                                Label("igev.hsr.news.Intels".i18nIGEV, systemImage: "newspaper")
                                    .tag(NewsKitHSR.NewsType.intels)
                            }
                            .padding(4)
                            .pickerStyle(.segmented)
                        }
                    }
            }
            .navigationTitle(currentPageTitle)
            .navBarTitleDisplayMode(.large)
            .refreshable {
                coordinator.updateData()
            }
            .onChange(of: defaultServer) {
                coordinator.updateData()
            }
        }

        // swiftlint:enable sf_safe_symbol

        // MARK: Private

        @ObservedObject private var coordinator: Coordinator = .init()
        @State private var currentTab: NewsKitHSR.NewsType = .notices

        @Default(.defaultServer) private var defaultServer: String

        private var currentPageTitle: String {
            switch currentTab {
            case .events: "igev.hsr.news.Events".i18nIGEV
            case .intels: "igev.hsr.news.Intels".i18nIGEV
            case .notices: "igev.hsr.news.Notices".i18nIGEV
            }
        }

        @MainActor private var currentTabContent: some View {
            switch currentTab {
            case .events: AnyView(data.events)
            case .intels: AnyView(data.intels)
            case .notices: AnyView(data.notices)
            }
        }
    }
}

#if !os(watchOS)
#Preview {
    let sampleEventData = """
    [
      {
        "id": "28551245",
        "createdAt": 1715603528,
        "description": "参与分享必得2.2角色永久评论装扮×4，还有机会获得星琼奖励~",
        "endAt": 1717948799,
        "startAt": 1715529600,
        "title": "【星琼奖励】参与2.2版本讨论活动，赢取星琼和永久评论装扮奖励！",
        "url": "https://www.hoyolab.com/article/28551245"
      }
    ]
    """

    let sampleIntelData = """
    [
      {
        "id": "28846635",
        "createdAt": 1716177609,
        "description": "影业大亨「钟表匠」神秘失踪，克劳克影业群龙无首，
    激烈的市场竞争中屡屡受挫……钟表小子究竟何去何从？
    这次帕姆变身大影视家，参与《美梦往事》系列影片剪辑与拍摄，尝试梦境动画的制作技法！
    诚邀开拓者品鉴由大影视家帕姆参与制作拍摄的《美梦往事》系列动画！",
        "title": "大影视家帕姆｜美梦往事篇",
        "url": "https://www.hoyolab.com/article/28846635"
      }
    ]
    """
    let sampleNoticeData = """
    [
      {
        "id": "28802787",
        "createdAt": 1716096992,
        "description": "您好，开拓者： 列车组将于近期进行PC启动器版本升级，升级完成后，PC启动器将更新至2.33.7版本。
    ▌更新时间 2024/05/20 14:00（UTC+8) 开始
    ▌更新方式 收到启动器更新通知后，开拓者点击【更新】按钮即可进行更新操作。
    ▌设备要求
    ■PC端推荐配置如下：
    设备：i7/8G内存/独立显卡、GTX1060及以上配置
    系统：win10 64位或以上系统
    ■PC端支持配置如下：
    设备：i3/6G内存/独立显卡、GTX650及以上配置
    系统：win7 64位或以上系统",
        "title": "《崩坏：星穹铁道》PC启动器更新预告",
        "url": "https://www.hoyolab.com/article/28802787"
      }
    ]
    """
    // swiftlint:disable force_try
    let aggregated = NewsKitHSR.AggregatedResult(
        events: try! NewsKitHSR.EventElement.decodeArrayFrom(string: sampleEventData),
        intels: try! NewsKitHSR.IntelElement.decodeArrayFrom(string: sampleIntelData),
        notices: try! NewsKitHSR.NoticeElement.decodeArrayFrom(string: sampleNoticeData)
    )
    // swiftlint:enable force_try

    return NewsKitHSR.NewsView(aggregated)
}
#endif
