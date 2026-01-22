// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - RootNavVM

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
final class RootNavVM {
    // MARK: Public

    public static let isAppKit = OS.type == .macOS && !OS.isCatalyst
    public static let shared = RootNavVM()

    public let screenVM: ScreenVM = .shared

    public var rootPageNav: AppRootPage = {
        let initSelection: Int = {
            guard Defaults[.restoreTabOnLaunching] else { return 1 }
            let allBaseID = AppRootPage.allCases.map(\.id)
            guard allBaseID.contains(Defaults[.appTabIndex]) else { return 1 }
            return Defaults[.appTabIndex]
        }()
        return .init(rootID: initSelection) ?? .today
    }() {
        willSet {
            guard rootPageNav != newValue else { return }
            Defaults[.appTabIndex] = newValue.rootID
            UserDefaults.baseSuite.synchronize()
            Broadcaster.shared.stopRootTabTasks()
            if newValue == .today {
                Broadcaster.shared.todayTabDidSwitchTo()
            }
        }
    }

    public var rootPageNavBindingNullable: Binding<AppRootPage?> {
        .init(
            get: {
                self.rootPageNav
            },
            set: { newValue in
                self.rootPageNav = newValue ?? .today
            }
        )
    }

    @ViewBuilder public var gotoSettingsButtonIfAppropriate: some View {
        if rootPageNav != .appSettings {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.rootPageNav = .appSettings
                }
            } label: {
                Text("app.dailynote.noCard.switchToSettingsPage".i18nPZHelper)
                    .fontWidth(.condensed)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(.green)
            .listRowMaterialBackground()
        }
    }

    @ToolbarContentBuilder
    public func sharedRootPageSwitcherAsToolbarContent() -> some ToolbarContent {
        let allCases = !screenVM.isSidebarVisible
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        let maxLabelLength = effectiveCases.map(\.labelNameTextRaw.count).max()
        let forceMenu: Bool? = (maxLabelLength ?? 0) > 8 ? true : nil
        let isOverCompact = screenVM.isPhonePortraitSituation
        let placeAtTop = OS.isBuggyOS25Build || !isOverCompact || OS.type == .macOS
        #if os(macOS)
        let actualPlacement: ToolbarItemPlacement = .cancellationAction
        #else
        let actualPlacement: ToolbarItemPlacement = !placeAtTop ? .bottomBar : .cancellationAction
        #endif
        if !isOverCompact {
            ToolbarItem(placement: actualPlacement) {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: forceMenu ?? false
                )
            }
            .removeSharedBackgroundVisibility(bypassWhen: forceMenu ?? false)
        } else if OS.isBuggyOS25Build {
            ToolbarItem(placement: actualPlacement) {
                sharedToolbarNavPicker(
                    allCases: !screenVM.isSidebarVisible,
                    isMenu: forceMenu ?? true
                )
            }
        } else {
            ToolbarItem(placement: actualPlacement) {
                bottomTabBarForCompactLayout(allCases: !screenVM.isSidebarVisible)
            }
        }
    }

    // MARK: Private

    @MainActor @ViewBuilder
    private func sharedToolbarNavPicker(allCases: Bool, isMenu: Bool = true) -> some View {
        @Bindable var this = self
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        Picker("".description, selection: $this.rootPageNav) {
            ForEach(effectiveCases) { navCase in
                if navCase.isExposed {
                    let isChosen: Bool = navCase == self.rootPageNav
                    switch isMenu {
                    case true:
                        VStack(alignment: .center) {
                            navCase.icon
                            navCase.labelNameText
                                .fontWidth(.compressed)
                                .fontWeight(isChosen ? .bold : .regular)
                                .textCase(.uppercase)
                        }
                        .tag(navCase)
                    case false:
                        navCase.label
                            .tag(navCase)
                    }
                }
            }
        }
        .labelsHidden()
        .apply { currentContent in
            switch isMenu {
            case true:
                currentContent
                    .pickerStyle(.menu)
                    .blurMaterialBackground(
                        enabled: !OS.liquidGlassThemeSuspected,
                        shape: .capsule,
                        interactive: true
                    )
            case false:
                currentContent
                    .pickerStyle(.segmented)
                    .labelStyle(.titleAndIcon)
            }
        }
        .fixedSize()
        .react(to: rootPageNav) {
            simpleTaptic(type: .medium)
        }
    }

    @ViewBuilder
    private func bottomTabBarForCompactLayout(allCases: Bool) -> some View {
        let effectiveCases = !allCases ? AppRootPage.enabledSubCases : AppRootPage.allCases
        if #available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *),
           OS.liquidGlassThemeSuspected {
            floatingTabBar(effectiveCases: effectiveCases)
        } else {
            classicTabBar(effectiveCases: effectiveCases)
                .react(to: rootPageNav) {
                    simpleTaptic(type: .medium)
                }
        }
    }

    /// iOS 26+ Liquid Glass Style 浮動膠囊 Tab Bar
    @available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *)
    @ViewBuilder
    private func floatingTabBar(effectiveCases: [AppRootPage]) -> some View {
        @Bindable var this = self
        FloatingGlassTabBar(
            effectiveCases: effectiveCases,
            selection: $this.rootPageNav
        )
    }

    /// 經典 Tab Bar 樣式（iOS 25 及更早）
    @ViewBuilder
    private func classicTabBar(effectiveCases: [AppRootPage]) -> some View {
        HStack(spacing: 0) {
            ForEach(effectiveCases, id: \.self) { navCase in
                let isChosen: Bool = navCase == self.rootPageNav
                if navCase.isExposed {
                    Button {
                        Task { @MainActor [weak self] in
                            self?.rootPageNav = navCase
                        }
                    } label: {
                        VStack(spacing: 0) {
                            navCase.icon.frame(width: 28, height: 28)
                            navCase.labelNameText
                                .font(.footnote)
                                .padding(.bottom, 4)
                        }
                        .padding(.vertical, 4)
                        .fixedSize()
                        .labelStyle(.titleAndIcon)
                        .fontWidth(.compressed)
                        .fontWeight(isChosen ? .bold : .regular)
                        .foregroundStyle(!isChosen ? Color.secondary : Color.accentColor)
                        .padding()
                        .contentShape(.rect)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .id(navCase)
                }
            }
        }
        .frame(minHeight: 50, maxHeight: 54)
        .shadow(radius: 4)
    }
}

// MARK: - FloatingGlassTabBar

@available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *)
private struct FloatingGlassTabBar: View {
    // MARK: Lifecycle

    public init(effectiveCases: [AppRootPage], selection: Binding<AppRootPage>) {
        self.effectiveCases = effectiveCases
        self._selection = selection
    }

    // MARK: Public

    public var body: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                ForEach(effectiveCases, id: \.self) { (navCase: AppRootPage) in
                    if navCase.isExposed {
                        let isChosen = isDragging
                            ? (findClosestTab(to: highlightX) == navCase)
                            : (visualSelection == navCase)
                        VStack(spacing: 2) {
                            navCase.icon
                                .imageScale(.medium)
                            navCase.labelNameText
                                .font(.caption2)
                                .fontWeight(isChosen ? .bold : .regular)
                                .fontWidth(.condensed)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .shadow(radius: isChosen ? 10 : 2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(
                            width: buttonWidth / Double(effectiveCases.count),
                            alignment: .center
                        )
                        .foregroundStyle(isChosen ? Color.primary : Color.secondary)
                        .contentShape(Capsule())
                        // 標記每個 Tab 的位置作為動畫源
                        .matchedGeometryEffect(id: navCase, in: namespace)
                        // 記錄每個 Tab 的 frame
                        .background {
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: TabFramePreferenceKey.self,
                                    value: [navCase: geo.frame(in: .named(coordinateSpaceName))]
                                )
                            }
                        }
                    }
                }
            }
            .background {
                highlightCapsule
            }
            .glassEffect(.identity, in: .capsule)
            .coordinateSpace(name: coordinateSpaceName)
            .onPreferenceChange(TabFramePreferenceKey.self) { frames in
                tabFrames = frames
                // 初始化 highlightX 到當前選中 Tab 的位置
                if !isDragging, let frame = frames[visualSelection] {
                    highlightX = frame.midX
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        // 記錄拖曳的總距離，用於區分 tap 和 drag
                        let distance = abs(value.translation.width) + abs(value.translation.height)
                        if distance > dragThreshold {
                            // 超過閾值才算真正的拖曳，高亮跟隨手指
                            isDragging = true
                            highlightX = clampedX(value.location.x)
                        }
                    }
                    .onEnded { value in
                        // 找到最近的 Tab 作為目標
                        let targetTab = findClosestTab(to: isDragging ? highlightX : value.location.x) ??
                            visualSelection
                        visualSelection = targetTab
                        // 用動畫將高亮區域移動到目標 Tab 的中心
                        if let targetFrame = tabFrames[targetTab] {
                            withAnimation(.spring(duration: animationDuration)) {
                                highlightX = targetFrame.midX
                            }
                        }
                        isDragging = false
                        // 等動畫完成後再更新實際的 selection
                        if selection != targetTab {
                            simpleTaptic(type: .medium)
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                                selection = targetTab
                            }
                        }
                    }
            )
        }
        .frame(minHeight: 50, maxHeight: 60)
        .onAppear {
            // 初始化視覺狀態與實際選擇同步
            visualSelection = selection
            if let frame = tabFrames[selection] {
                highlightX = frame.midX
            }
        }
        .onChange(of: selection) { _, newValue in
            // 當外部改變 selection 時，同步視覺狀態
            if visualSelection != newValue, !isDragging {
                visualSelection = newValue
                if let frame = tabFrames[newValue] {
                    highlightX = frame.midX
                }
            }
        }
    }

    // MARK: Private

    @Binding private var selection: AppRootPage

    @Namespace private var namespace

    @State private var screenVM = ScreenVM.shared

    /// 視覺選中狀態，用於控制背景動畫，先於實際 selection 更新
    @State private var visualSelection: AppRootPage = .today
    /// 記錄每個 Tab 的 frame，用於拖曳時判斷最近的 Tab
    @State private var tabFrames: [AppRootPage: CGRect] = [:]
    /// 是否正在拖曳中
    @State private var isDragging: Bool = false
    /// 高亮區域的 X 座標（手指拖曳時跟隨手指，鬆開時動畫到目標）
    @State private var highlightX: CGFloat = 0

    private let effectiveCases: [AppRootPage]

    /// 拖曳距離閾值，超過此值才算真正的拖曳（而非點擊）
    private let dragThreshold: CGFloat = 5
    /// 動畫持續時間
    private let animationDuration: Double = 0.3
    /// 座標區域命名空間
    private let coordinateSpaceName = "FloatingGlassTabBar"

    private var buttonWidth: Double {
        screenVM.mainColumnCanvasSizeObserved.width - 70
    }

    /// 高亮膠囊背景 - 統一使用 position 定位，確保動畫連續
    @ViewBuilder private var highlightCapsule: some View {
        if let referenceFrame = tabFrames[visualSelection] {
            Capsule()
                .fill(Color.primary.opacity(0.2))
                .glassEffect(.regular.interactive())
                .frame(width: referenceFrame.width, height: referenceFrame.height)
                .position(x: highlightX, y: referenceFrame.midY)
        }
    }

    /// 限制 X 座標在 Tab Bar 範圍內
    private func clampedX(_ x: CGFloat) -> CGFloat {
        guard !tabFrames.isEmpty else { return x }
        let minX = tabFrames.values.map(\.midX).min() ?? x
        let maxX = tabFrames.values.map(\.midX).max() ?? x
        return min(max(x, minX), maxX)
    }

    /// 根據 X 座標找到最近的 Tab
    private func findClosestTab(to x: CGFloat) -> AppRootPage? {
        var closestTab: AppRootPage?
        var closestDistance: CGFloat = .infinity

        for (tab, frame) in tabFrames {
            let tabCenterX = frame.midX
            let distance = abs(x - tabCenterX)
            if distance < closestDistance {
                closestDistance = distance
                closestTab = tab
            }
        }

        return closestTab
    }
}

// MARK: - TabFramePreferenceKey

@available(iOS 17.0, macCatalyst 17.0, *)
private struct TabFramePreferenceKey: PreferenceKey {
    static let defaultValue: [AppRootPage: CGRect] = [:]

    static func reduce(value: inout [AppRootPage: CGRect], nextValue: () -> [AppRootPage: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}
