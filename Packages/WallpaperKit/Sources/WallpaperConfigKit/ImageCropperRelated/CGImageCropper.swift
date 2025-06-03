// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftUI

#if !os(watchOS)

// MARK: - CGImageCropperView

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
            scaleFactor = max(0.0, scaleFactor)
        }
    }

    // MARK: Private

    @State private var currentState: OperationState
    @State private var scaleFactor: Double = 0.1
    @State private var minimumScaleFactor: Double = 1.0
    @State private var originX: Double = 0
    @State private var originY: Double = 0
    @State private var sourceCGImageZoomedAndCroppedCache: CGImage?

    private let cropCompletionHandler: ((CGImage) -> Void)?
    private let targetDimension: CGSize

    private var needsToShrinkThePreviewViewport: Bool {
        targetDimension.height / targetDimension.width >= 0.7
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
        // 确保当缩放因子改变时，原点也在有效范围内
        originX = max(0, min(originX.rounded(.down), maxOrigin.x))
        originY = max(0, min(originY.rounded(.down), maxOrigin.y))
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
                if OS.type == .macOS, !OS.isCatalyst {
                    Slider(value: $originX, in: 0 ... maxOriginXGuarded)
                } else {
                    Slider(value: $originX, in: 0 ... maxOriginXGuarded, step: stepValue)
                }
            }
        } label: {
            Image(systemSymbol: .arrowLeftAndRightCircle)
        }
        .disabled(sourceCGImage == nil || maxOrigin.x <= 0)

        LabeledContent {
            let maxOriginYGuarded = max(1, maxOrigin.y)
            let stepValue = 1.0
            Stepper(value: $originY, in: 0 ... maxOriginYGuarded, step: stepValue) {
                if OS.type == .macOS, !OS.isCatalyst {
                    Slider(value: $originY, in: 0 ... maxOriginYGuarded)
                } else {
                    Slider(value: $originY, in: 0 ... maxOriginYGuarded, step: stepValue)
                }
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
                Slider(value: $scaleFactor, in: minimumScaleFactor ... maxScaleFactor, step: 0.1)
            }
        } label: {
            Image(systemSymbol: .magnifyingglass)
        }
        .onChange(of: scaleFactor) { _, _ in
            fixOriginIfNeeded()
        }
        .disabled(sourceCGImage == nil)
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
                    .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in
                        length * (needsToShrinkThePreviewViewport ? 0.6 : 1)
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
                        DragGesture()
                            .onChanged { value in
                                // 计算拖动距离
                                let translation = value.translation

                                // 计算水平和垂直方向上的拖动量
                                let dragSensitivity: CGFloat = 0.15 // 调整拖动灵敏度
                                let dragX = -1 * translation.width * dragSensitivity
                                let dragY = translation.height * dragSensitivity

                                // 计算新的原点位置，并确保在有效范围内
                                let newOriginX = min(max(0, originX + dragX), maxOrigin.x)
                                let newOriginY = min(max(0, originY + dragY), maxOrigin.y)

                                // 更新原点位置
                                originX = newOriginX
                                originY = newOriginY
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                // 计算新的缩放因子
                                let delta = Double(value - 1.0)
                                let zoomSensitivity = 0.15 // 调整缩放灵敏度
                                let newScaleFactor = scaleFactor * (1.0 + delta * zoomSensitivity)

                                // 确保缩放因子在有效范围内
                                let maxScaleFactor = max(2.0, minimumScaleFactor)
                                scaleFactor = min(max(minimumScaleFactor, newScaleFactor), maxScaleFactor)

                                // 更新缩放后需要调整原点
                                fixOriginIfNeeded()
                            }
                    )
                    // 禁用父视图的滚动行为，防止事件传递到父视图
                    .onTapGesture {}
                } footer: {
                    if OS.type != .macOS {
                        Text("imageCropper.hint.fingerGestures", bundle: .module)
                            .fontWidth(.condensed)
                    } else if OS.isCatalyst {
                        Text("imageCropper.hint.mouseGesture", bundle: .module)
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
        .task {
            sourceCGImageZoomedAndCroppedCache = await getSourceCGImageZoomedAndCropped()
        }
        .id("\(scaleFactor)-\(originX)-\(originY)")
    }
}

#if DEBUG

import WallpaperKit

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

#Preview {
    Form {
        CGImageCropperView.makeTestView()
    }
    .formStyle(.grouped)
}
#endif

#endif
