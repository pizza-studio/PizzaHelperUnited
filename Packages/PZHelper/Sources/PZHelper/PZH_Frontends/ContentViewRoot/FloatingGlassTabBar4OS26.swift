// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.
//
// Design notes (clean-room, derived from the observable behavior of the
// platform-native iOS 26+ tab switcher and from this app's product needs):
//
//   1. Touch-down on a tab must give instant feedback: the selection
//      indicator springs toward the tab under the finger, without requiring
//      any movement threshold.
//   2. While the finger drags horizontally, the indicator follows the finger's
//      *displacement* from where the touch began (it is anchored to the
//      pressed tab rather than snapping to the absolute finger position), and
//      the candidate tab updates whenever the finger enters another tab.
//   3. Releasing the finger commits the candidate. Because this app's tab
//      pages are expensive to build, committing immediately would let the
//      page transition steal the main thread during the indicator's landing
//      animation; the page switch is therefore deferred until the indicator
//      has settled (product decision, matches the app's previous behavior).
//   4. While the finger is down the indicator gently grows (a "lift" cue);
//      it returns to its resting size when the finger lifts.
//   5. The indicator must never blur the glyphs under it. It therefore uses a
//      plain translucent tint instead of a glass material, and the glyphs are
//      always composited above the tint layer.
//   6. Emphasis inside the indicator region is rendered by a second,
//      emphasized copy of the tab content that is revealed through a window
//      mask; the plain copy is punched out in the same region so that no
//      ghosting shows through the translucent tint.

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
            barCanvas
        }
        .frame(minHeight: 50, maxHeight: 60)
        .onAppear {
            selectedPage = selection
        }
        .react(to: selection) { _, newValue in
            // Selection changes coming from outside (deep links, the toolbar
            // picker, …) move the indicator to the new page with a spring.
            guard selectedPage != newValue, trackingState == nil else { return }
            withAnimation(indicatorSpring) {
                selectedPage = newValue
            }
        }
        .onDisappear {
            deferredCommit?.cancel()
        }
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme

    // MARK: Private

    // MARK: - Touch tracking model

    /// Everything the bar needs to remember about the touch in progress.
    /// The indicator's left edge is anchored to the tab that was pressed and
    /// then follows the finger's horizontal displacement.
    private struct TrackingState {
        /// Finger x where the touch began (bar-local coordinates).
        let startFingerX: CGFloat
        /// Indicator left edge at the moment the touch began.
        let startIndicatorMinX: CGFloat
        /// Current finger x (bar-local coordinates).
        var fingerX: CGFloat
        /// The candidate page (the tab the finger is currently over).
        var candidatePage: AppRootPage
    }

    // MARK: - State

    /// The page the indicator currently rests on (committed page).
    @State private var selectedPage: AppRootPage = .today
    /// Non-nil while the finger is touching the bar (see `TrackingState`).
    @State private var trackingState: TrackingState?
    /// Measured bounds of the bar; the origin of all geometry math.
    @State private var measuredSize: CGSize = .zero
    /// Work item for the deferred page-switch commit.
    @State private var deferredCommit: DispatchWorkItem?

    @Binding private var selection: AppRootPage
    @State private var screenVM = ScreenVM.shared

    /// How much the indicator grows around its own center while touched.
    private let pressedGrowthScale: CGFloat = 1.12
    /// Horizontal breathing room the indicator keeps on each side of a cell.
    private let horizontalInset: CGFloat = 4
    /// The indicator's plain tint (dark mode: rest / pressed).
    private let darkTintOpacity: (rest: Double, pressed: Double) = (0.10, 0.16)
    /// The indicator's plain tint (light mode: rest / pressed).
    private let lightTintOpacity: (rest: Double, pressed: Double) = (0.06, 0.10)
    /// Delay between finger-up and the page-switch commit (see design note 3).
    private let commitDelay: Double = 0.4

    private let effectiveCases: [AppRootPage]

    // MARK: - Tunables

    /// Spring used when the indicator is retargeted or settles.
    private var indicatorSpring: Animation {
        .spring(response: 0.4, dampingFraction: 0.86, blendDuration: 0.1)
    }

    /// Width of one equally-divided tab cell.
    private var cellWidth: CGFloat {
        guard measuredSize.width > 0, !effectiveCases.isEmpty else { return 0 }
        return measuredSize.width / CGFloat(effectiveCases.count)
    }

    /// Resting width of the indicator: one cell plus the horizontal insets.
    private var indicatorWidth: CGFloat {
        guard cellWidth > 0 else { return 0 }
        return cellWidth + horizontalInset * 2
    }

    /// Resting height of the indicator.
    private var indicatorHeight: CGFloat {
        max(0, measuredSize.height - horizontalInset * 2)
    }

    private var buttonBarWidth: Double {
        screenVM.mainColumnCanvasSizeObserved.width - 70
    }

    private var labelTextShadowColor: Color {
        colorScheme == .dark ? .black : .black.opacity(0.33)
    }

    /// Left edge of the indicator when no touch is in progress.
    private var restingIndicatorMinX: CGFloat {
        guard let frame = cellFrame(of: selectedPage) else { return 0 }
        return clampedIndicatorMinX(frame.minX - horizontalInset)
    }

    /// Left edge of the indicator in the current phase.
    private var indicatorMinX: CGFloat {
        guard let trackingState else { return restingIndicatorMinX }
        let displacement = trackingState.fingerX - trackingState.startFingerX
        return clampedIndicatorMinX(trackingState.startIndicatorMinX + displacement)
    }

    /// The indicator's actual frame, grown around its center while touched.
    private var indicatorFrame: CGRect {
        guard measuredSize.width > 0, indicatorWidth > 0, indicatorHeight > 0 else {
            return .zero
        }
        let growth = trackingState == nil ? 1 : pressedGrowthScale
        let width = min(indicatorWidth * growth, measuredSize.width)
        let height = min(indicatorHeight * growth, max(0, measuredSize.height - 2))
        let centerX = indicatorMinX + indicatorWidth / 2
        let minX = min(max(centerX - width / 2, 0), max(0, measuredSize.width - width))
        let minY = (measuredSize.height - height) / 2
        return CGRect(x: minX, y: minY, width: width, height: height)
    }

    private var isTouched: Bool { trackingState != nil }

    // MARK: - Gesture

    private var barDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard measuredSize.width > 0 else { return }
                if var trackingState {
                    trackingState.fingerX = value.location.x
                    if let page = page(atXPosition: value.location.x) {
                        trackingState.candidatePage = page
                    }
                    self.trackingState = trackingState
                } else {
                    // Touch-down: cancel any pending commit, then spring the
                    // indicator toward the tab under the finger.
                    deferredCommit?.cancel()
                    deferredCommit = nil
                    guard let pressedPage = page(atXPosition: value.location.x),
                          let frame = cellFrame(of: pressedPage) else { return }
                    let startMinX = clampedIndicatorMinX(frame.minX - horizontalInset)
                    withAnimation(indicatorSpring) {
                        trackingState = TrackingState(
                            startFingerX: value.location.x,
                            startIndicatorMinX: startMinX,
                            fingerX: value.location.x,
                            candidatePage: pressedPage
                        )
                    }
                }
            }
            .onEnded { _ in
                guard let trackingState else { return }
                let targetPage = trackingState.candidatePage
                let didChange = targetPage != selection
                withAnimation(indicatorSpring) {
                    self.trackingState = nil
                    selectedPage = targetPage
                }
                guard didChange else { return }
                // Let the indicator land before swapping the page content.
                simpleTaptic(type: .medium)
                let previousSelection = selection
                deferredCommit?.cancel()
                let workItem = DispatchWorkItem {
                    guard selection == previousSelection else { return }
                    selection = targetPage
                }
                deferredCommit = workItem
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + commitDelay, execute: workItem
                )
            }
    }

    /// Tint of the indicator capsule (no blur; brighter while touched).
    private var indicatorTint: Color {
        let (rest, pressed) = colorScheme == .dark ? darkTintOpacity : lightTintOpacity
        return Color.primary.opacity(isTouched ? pressed : rest)
    }

    @ViewBuilder private var barCanvas: some View {
        ZStack(alignment: .topLeading) {
            // 1) Plain copy of every tab. The indicator region is erased so
            //    that no dimmed glyphs show through the translucent tint.
            tabContentLayer(emphasized: false)
                .mask {
                    ZStack {
                        Capsule()
                        indicatorWindow(in: measuredSize)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                }
            // 2) The indicator: a non-blurring tint capsule (design note 5).
            if indicatorFrame.width > 0, indicatorFrame.height > 0 {
                Capsule()
                    .fill(indicatorTint)
                    .frame(width: indicatorFrame.width, height: indicatorFrame.height)
                    .offset(x: indicatorFrame.minX, y: indicatorFrame.minY)
            }
            // 3) Emphasized copy of every tab, revealed only inside the window.
            tabContentLayer(emphasized: true)
                .mask {
                    indicatorWindow(in: measuredSize)
                }
        }
        .contentShape(Rectangle())
        .gesture(barDragGesture)
        .overlay {
            // Measures the actual bar bounds without taking part in layout.
            GeometryReader { geo in
                Color.clear
                    .onAppear { measuredSize = geo.size }
                    .onChange(of: geo.size) { _, newSize in
                        measuredSize = newSize
                    }
            }
            .allowsHitTesting(false)
        }
    }

    // MARK: - Rendering

    /// Capsule-shaped indicator window used by the masks (bar-local coords).
    private func indicatorWindow(in size: CGSize) -> some View {
        Capsule()
            .frame(width: indicatorFrame.width, height: indicatorFrame.height)
            .offset(x: indicatorFrame.minX, y: indicatorFrame.minY)
            .frame(width: size.width, height: size.height, alignment: .topLeading)
    }

    /// One full copy of the tab row (plain or emphasized). Both copies share
    /// the same frames so the emphasized glyphs align exactly with the plain
    /// ones underneath.
    @ViewBuilder
    private func tabContentLayer(emphasized: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(effectiveCases, id: \.self) { page in
                if page.isExposed {
                    tabCell(page, emphasized: emphasized)
                }
            }
        }
        .frame(width: buttonBarWidth, alignment: .center)
    }

    @ViewBuilder
    private func tabCell(_ page: AppRootPage, emphasized: Bool) -> some View {
        VStack(spacing: 2) {
            page.icon
                .imageScale(.medium)
            page.labelNameText
                .font(.caption2)
                .fontWeight(emphasized ? .bold : .regular)
                .fontWidth(.condensed)
                .fixedSize(horizontal: true, vertical: false)
        }
        .shadow(
            color: labelTextShadowColor,
            radius: labelShadowRadius(emphasized: emphasized)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(
            width: Swift.max(buttonBarWidth / Double(effectiveCases.count), 25),
            alignment: .center
        )
        .foregroundStyle(emphasized ? Color.primary : Color.secondary)
    }

    /// Frame of one tab cell.
    private func cellFrame(of page: AppRootPage) -> CGRect? {
        guard measuredSize.width > 0, let index = effectiveCases.firstIndex(of: page) else {
            return nil
        }
        return CGRect(
            x: CGFloat(index) * cellWidth, y: 0,
            width: cellWidth, height: measuredSize.height
        )
    }

    /// Page whose cell contains the given x coordinate.
    private func page(atXPosition xPosition: CGFloat) -> AppRootPage? {
        guard cellWidth > 0, !effectiveCases.isEmpty, xPosition >= 0 else { return nil }
        let index = Int(xPosition / cellWidth)
        guard index < effectiveCases.count else { return nil }
        return effectiveCases[index]
    }

    /// Keeps the indicator inside the bar.
    private func clampedIndicatorMinX(_ minX: CGFloat) -> CGFloat {
        guard indicatorWidth > 0, measuredSize.width > 0 else { return 0 }
        return min(max(minX, 0), max(0, measuredSize.width - indicatorWidth))
    }

    private func labelShadowRadius(emphasized: Bool) -> Double {
        switch (colorScheme == .dark, emphasized) {
        case (false, false): 2
        case (false, true): 10
        case (true, false): 10
        case (true, true): 2
        }
    }
}
