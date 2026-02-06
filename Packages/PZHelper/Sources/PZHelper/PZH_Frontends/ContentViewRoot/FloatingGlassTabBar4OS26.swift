// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - FloatingGlassTabBar

@available(iOS 26.0, macCatalyst 26.0, macOS 26.0, watchOS 26.0, *)
internal struct FloatingGlassTabBar: View {
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
                        .shadow(
                            color: labelTextShadowColor,
                            radius: getLabelTextShadowRadius(isChosen: isChosen)
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(
                            width: Swift.max(buttonBarWidth / Double(effectiveCases.count), 25),
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
            .background { highlightCapsule }
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
        .react(to: selection) { _, newValue in
            // 當外部改變 selection 時，同步視覺狀態
            guard visualSelection != newValue, !isDragging else { return }
            visualSelection = newValue
            if let frame = tabFrames[newValue] {
                highlightX = frame.midX
            }
        }
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme

    // MARK: Private

    private struct TabFramePreferenceKey: PreferenceKey {
        static let defaultValue: [AppRootPage: CGRect] = [:]

        static func reduce(value: inout [AppRootPage: CGRect], nextValue: () -> [AppRootPage: CGRect]) {
            value.merge(nextValue()) { $1 }
        }
    }

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

    private var buttonBarWidth: Double {
        screenVM.mainColumnCanvasSizeObserved.width - 70
    }

    private var labelTextShadowColor: Color {
        colorScheme == .dark ? .black : .black.opacity(0.33)
    }

    /// 高亮膠囊背景 - 統一使用 position 定位，確保動畫連續
    @ViewBuilder private var highlightCapsule: some View {
        if let referenceFrame = tabFrames[visualSelection] {
            Capsule()
                .glassEffect(.regular.interactive())
                .frame(width: referenceFrame.width, height: referenceFrame.height)
                .position(x: highlightX, y: referenceFrame.midY)
                .colorMultiply(
                    Color.primary.opacity(colorScheme == .dark ? 0.6 : 0.2)
                )
        }
    }

    private func getLabelTextShadowRadius(isChosen: Bool) -> Double {
        switch (colorScheme == .dark, isChosen) {
        case (false, false): 2
        case (false, true): 10
        case (true, false): 10
        case (true, true): 2
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
