// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SwiftUI

// MARK: - CGImageCropperView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct CGImageCropperView: View {
    // MARK: Lifecycle

    public init(
        _ targetRect: CGSize,
        sourceImage: CGImage? = nil,
        cropCompletionHandler: ((CGImage) -> Void)? = nil
    ) {
        self.cropCompletionHandler = cropCompletionHandler
        self.targetDimension = targetRect
        if let sourceImage {
            self.currentState = .awaitingForCropConfiguration(cgImage: sourceImage)
        } else {
            self.currentState = .awaitingForFileDesignation
        }
    }

    // MARK: Public

    public var body: some View {
        mainView
    }

    @ViewBuilder public var imagePlaceholderRowContentBase: some View {
        Color.gray
            .aspectRatio(targetDimension.width / targetDimension.height, contentMode: .fill)
            .cornerRadius(8)
            .listRowInsets(.init())
            .contentShape(Rectangle()) // 确保整个区域都能接收手势
    }

    // MARK: Internal

    var safeScaleFactor: Binding<Double> {
        .init {
            max(0.0, scaleFactor)
        } set: { newValue in
            scaleFactor = max(0.0, newValue)
        }
    }

    // MARK: Private

    @State private var currentState: OperationState
    @State private var scaleFactor: Double = 0.1
    @State private var minimumScaleFactor: Double = 1.0
    @State private var originX: Double = 0
    @State private var originY: Double = 0
    @State private var sourceCGImageZoomedAndCroppedCache: CGImage?
    @State private var screenVM: ScreenVM = .shared
    @State private var lastDragTranslation: CGSize = .zero
    @State private var lastMagnification: Double = 1.0
    @State private var displayedImageSize: CGSize = .zero

    private let cropCompletionHandler: ((CGImage) -> Void)?
    private let targetDimension: CGSize

    private var needsToShrinkThePreviewViewport: Bool {
        targetDimension.height / targetDimension.width >= 0.7
    }

    /// 螢幕上每一點與圖片像素之間的比率（用於手勢計算）。
    private var screenToImageFactor: CGFloat {
        guard displayedImageSize.width > 0 else { return 1.0 }
        return targetDimension.width / displayedImageSize.width
    }

    /// 用於觸發 .task(id:) 重新渲染裁剪預覽的 key。
    /// 將座標四捨五入到整數以實現自然防抖——手勢期間的亞像素變化不會反覆觸發重算。
    private var cropTaskID: String {
        let x = Int(originX.rounded())
        let y = Int(originY.rounded())
        let z = Int(scaleFactor * 1000)
        return "\(z)-\(x)-\(y)"
    }

    private var currentMetrics: (x: String, y: String, zoom: String) {
        let x = Int(originX.rounded(.down)).description.prefix(4)
        let y = Int(originY.rounded(.down)).description.prefix(4)
        let zoom = scaleFactor.roundToPlaces(places: 1, round: .towardZero).description.prefix(4)
        return (x.description, y.description, zoom.description)
    }

    private var maxOrigin: CGPoint {
        guard let sourceCGImageRAW else { return .zero }

        // 计算缩放后的图片尺寸
        let scaledWidth = Double(sourceCGImageRAW.width) * scaleFactor
        let scaledHeight = Double(sourceCGImageRAW.height) * scaleFactor

        // 计算可用的最大原点位置
        // 确保裁剪区域不会超出缩放后的图片范围
        let maxX = max(0, scaledWidth.rounded(.down) - targetDimension.width)
        let maxY = max(0, scaledHeight.rounded(.down) - targetDimension.height)

        return CGPoint(x: maxX, y: maxY)
    }

    private var sourceCGImageRAW: CGImage? {
        switch currentState {
        case let .awaitingForCropConfiguration(thisCGImage):
            guard thisCGImage.width > 1, thisCGImage.height > 1 else { return nil }
            return thisCGImage
        default: return nil
        }
    }

    private var sourceCGImage: CGImage? {
        guard let sourceCGImageRAW else { return nil }
        updateScaleFactors(for: sourceCGImageRAW)
        return sourceCGImageRAW
    }

    private func getSourceCGImageZoomedAndCropped() async -> CGImage? {
        // 修正裁剪逻辑，确保不超出图片范围
        let zoomed: CGImage? = await Task(priority: .userInitiated) {
            sourceCGImage?.zoomedByCoreImage(scaleFactor)
        }.value
        guard let zoomed else { return nil }

        // 限制原点不超过最大值
        let maxOrigin = maxOrigin
        let safeOrigin = CGPoint(x: min(originX, maxOrigin.x), y: min(originY, maxOrigin.y))

        return await Task(priority: .userInitiated) {
            zoomed.crop(to: .init(origin: safeOrigin, size: targetDimension))
        }.value
    }

    private func updateScaleFactors(for image: CGImage) {
        Task { @MainActor in
            let widthRatio = Double(image.width) / targetDimension.width.rounded(.down)
            let heightRatio = Double(image.height) / targetDimension.height.rounded(.down)

            // 调整缩放因子计算，确保大图片可以缩小到目标尺寸
            if widthRatio > 1.0, heightRatio > 1.0 {
                // 如果图片比目标矩形大，允许缩小
                minimumScaleFactor = max(1.0 / widthRatio, 1.0 / heightRatio)
            } else {
                // 如果图片比目标矩形小，使用原来的计算方式确保放大
                minimumScaleFactor = max(1.0, 1.0 / min(widthRatio, heightRatio))
            }

            // 如果原始图片尺寸不足以覆盖目标矩形，更新 scaleFactor
            if !areMetricsMakingSense(against: image) {
                scaleFactor = minimumScaleFactor
            }

            fixOriginIfNeeded()
        }
    }

    private func fixOriginIfNeeded() {
        // 确保当缩放因子改变时，原点也在有效范围内（保留小数精度以实现平滑拖拽）
        originX = max(0, min(originX, maxOrigin.x))
        originY = max(0, min(originY, maxOrigin.y))
    }

    private func areMetricsMakingSense(against source: CGImage?) -> Bool {
        // 当 sourceCGImage 为 nil 的时候，不处理，直接甩 true。
        guard let source else { return true }
        let thisCGImageRect = CGRect(
            origin: .zero,
            size: CGSize(
                width: Double(source.width) * scaleFactor,
                height: Double(source.height) * scaleFactor
            )
        )
        let targetRect = CGRect(
            origin: .zero,
            size: CGSize(
                width: targetDimension.width.rounded(.down),
                height: targetDimension.height.rounded(.down)
            )
        )
        return thisCGImageRect.contains(targetRect)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension CGImageCropperView {
    fileprivate enum OperationState {
        case awaitingForFileDesignation
        case awaitingForCropConfiguration(cgImage: CGImage)
        case cropCompleted
        case exception(Error)
    }

    fileprivate enum ICException: Error, LocalizedError {
        case targetRectInvalid
        case scaleFactorInvalid
        case cgImageManipulationFailure
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension CGImageCropperView {
    @ViewBuilder fileprivate var mainView: some View {
        switch currentState {
        case .awaitingForFileDesignation:
            Text(verbatim: "please assign image")
        case let .awaitingForCropConfiguration(thisCGImage):
            croppedImagePreview
                .onAppear {
                    updateScaleFactors(for: thisCGImage)
                }
            Section {
                sliders4Origin
                slider4ScaleFactor
            }
            if let cropCompletionHandler, let sourceCGImageZoomedAndCroppedCache {
                Section {
                    Button {
                        cropCompletionHandler(sourceCGImageZoomedAndCroppedCache)
                    } label: {
                        Image(systemSymbol: .scissorsBadgeEllipsis)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(.init())
                    .listRowBackground(EmptyView())
                }
            }
        case .cropCompleted:
            Text(verbatim: "crop completed")
        case let .exception(theError):
            let errorText: String =
                (theError as? LocalizedError)?.errorDescription
                    ?? theError.localizedDescription
            Text(errorText)
        }
    }

    @ViewBuilder private var sliders4Origin: some View {
        LabeledContent {
            let maxOriginXGuarded = max(1, maxOrigin.x)
            let stepValue = 1.0
            Stepper(value: $originX, in: 0 ... maxOriginXGuarded, step: stepValue) {
                Slider(value: $originX, in: 0 ... maxOriginXGuarded)
            }
        } label: {
            Image(systemSymbol: .arrowLeftAndRightCircle)
        }
        .disabled(sourceCGImage == nil || maxOrigin.x <= 0)

        LabeledContent {
            let maxOriginYGuarded = max(1, maxOrigin.y)
            let stepValue = 1.0
            Stepper(value: $originY, in: 0 ... maxOriginYGuarded, step: stepValue) {
                Slider(value: $originY, in: 0 ... maxOriginYGuarded)
            }
        } label: {
            Image(systemSymbol: .arrowUpAndDownCircle)
        }
        .disabled(sourceCGImage == nil || maxOrigin.y <= 0)
    }

    @ViewBuilder private var slider4ScaleFactor: some View {
        let maxScaleFactor = minimumScaleFactor + 2.0
        LabeledContent {
            Stepper(value: $scaleFactor, in: minimumScaleFactor ... maxScaleFactor, step: 0.1) {
                Slider(value: $scaleFactor, in: minimumScaleFactor ... maxScaleFactor)
            }
        } label: {
            Image(systemSymbol: .magnifyingglass)
        }
        .react(to: scaleFactor) { _, _ in
            fixOriginIfNeeded()
        }
        .disabled(sourceCGImage == nil)
    }

    private var previewBlockWidth: CGFloat? {
        guard needsToShrinkThePreviewViewport else { return nil }
        let basicLength = screenVM.mainColumnCanvasSizeObserved.width - 64
        return basicLength * 0.6
    }

    @ViewBuilder private var croppedImagePreview: some View {
        Group {
            if let sourceCGImageZoomedAndCroppedCache {
                Section {
                    let metrics = currentMetrics
                    Image(
                        decorative: sourceCGImageZoomedAndCroppedCache,
                        scale: 1,
                        orientation: .up
                    )
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .frame(width: previewBlockWidth)
                    .background {
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear { displayedImageSize = geometry.size }
                                .onChange(of: geometry.size) { _, newSize in
                                    displayedImageSize = newSize
                                }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    // 以下修改阻止手势事件传递到父视图
                    .contentShape(Rectangle()) // 确保整个区域都能接收手势
                    .corneredTag(
                        verbatim: "x:\(metrics.x), y:\(metrics.y)",
                        alignment: .bottomLeading,
                        textSize: 14,
                        padding: 6
                    )
                    .corneredTag(
                        verbatim: "\(metrics.zoom)x",
                        alignment: .bottomTrailing,
                        textSize: 14,
                        padding: 6
                    )
                    .listRowInsets(.init())
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 1)
                            .onChanged { value in
                                // 計算自上次更新以來的增量移動
                                let delta = CGSize(
                                    width: value.translation.width - lastDragTranslation.width,
                                    height: value.translation.height - lastDragTranslation.height
                                )
                                lastDragTranslation = value.translation
                                let factor = screenToImageFactor
                                // 手指/滑鼠拖動方向與圖片內容移動方向一致（直接操作範式）
                                // 注意：crop() 內部對 Y 軸做了座標翻轉，因此 Y 方向需取反
                                originX -= delta.width * factor
                                originY += delta.height * factor
                                fixOriginIfNeeded()
                            }
                            .onEnded { _ in
                                lastDragTranslation = .zero
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let magnificationValue = Double(value)
                                let delta = magnificationValue / lastMagnification
                                lastMagnification = magnificationValue

                                let oldScale = scaleFactor
                                let maxScaleFactor = minimumScaleFactor + 2.0
                                let newScale = min(
                                    max(minimumScaleFactor, scaleFactor * delta),
                                    maxScaleFactor
                                )

                                if newScale != oldScale {
                                    // 以當前視窗中心為縮放錨點
                                    let viewportCenterX = originX + targetDimension.width / 2
                                    let viewportCenterY = originY + targetDimension.height / 2
                                    let ratio = newScale / oldScale
                                    originX = viewportCenterX * ratio - targetDimension.width / 2
                                    originY = viewportCenterY * ratio - targetDimension.height / 2
                                    scaleFactor = newScale
                                    fixOriginIfNeeded()
                                }
                            }
                            .onEnded { _ in
                                lastMagnification = 1.0
                            }
                    )
                    // 禁用父視圖的滾動行為，防止事件傳遞到父視圖
                    .onTapGesture {}
                } footer: {
                    if OS.type != .macOS {
                        Text("imageCropper.hint.fingerGestures", bundle: .currentSPM)
                            .fontWidth(.condensed)
                    } else if OS.isCatalyst {
                        Text("imageCropper.hint.mouseGesture", bundle: .currentSPM)
                            .fontWidth(.condensed)
                    }
                }
            } else {
                Section {
                    imagePlaceholderRowContentBase
                } footer: {
                    Text(verbatim: "imageCropper.hint.metricsMisconfigured")
                        .fontWidth(.condensed)
                }
            }
        }
        .task(id: cropTaskID) {
            sourceCGImageZoomedAndCroppedCache = await getSourceCGImageZoomedAndCropped()
        }
    }
}

#if DEBUG

import WallpaperKit

@available(iOS 17.0, macCatalyst 17.0, *)
extension CGImageCropperView {
    @ViewBuilder
    public static func makeTestView() -> some View {
        let cgImage = BundledWallpaper.queryImageAsset(for: "PZWP110000")!
        CGImageCropperView(
            .init(width: 420, height: 200),
            sourceImage: cgImage
        )
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    Form {
        CGImageCropperView.makeTestView()
    }
    .formStyle(.grouped).disableFocusable()
}
#endif

#endif
