// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

#if !os(watchOS)

import SwiftUI
import UniformTypeIdentifiers

@available(iOS 17.0, macCatalyst 17.0, *)
public struct TakeViewShotButton<Content: View, SubLabelContent: View>: View {
    // MARK: Lifecycle

    public init(content: @escaping () -> Content, subLabel: @escaping () -> SubLabelContent) {
        self.content = content
        self.subLabel = subLabel
    }

    // MARK: Public

    public var body: some View {
        Button {
            taskVM.takeShot(content())
        } label: {
            LabeledContent {
                subLabel()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Color.accentColor)
            } label: {
                taskVM.statusIconView
                    .id(taskVM.taskState)
            }
        }
        .disabled(taskVM.taskState == .busy)
        .saturation(taskVM.taskState == .busy ? 0 : 1)
        .confirmationDialog(
            Text("takeViewShotButton.imageShotPreparationComplete.instruction", bundle: .currentSPM),
            isPresented: taskVM.isConfirmationDialogVisible,
            titleVisibility: .visible
        ) {
            if let heicImage = taskVM.finishedHEICImage {
                ShareLink(
                    item: heicImage,
                    preview: SharePreview(
                        Text("takeViewShotButton.preview.imageToShare", bundle: .currentSPM)
                    )
                ) {
                    Text("takeViewShotButton.button.tapHereToShare", bundle: .currentSPM)
                }
            }
            Button(role: .cancel) {} label: {
                Text("sys.close".i18nBaseKit)
            }
        }
        .fileExporter(
            isPresented: taskVM.isFileExporterVisible,
            document: taskVM.finishedHEICImage,
            contentType: .heic,
            defaultFilename: "Image_\(Int(Date().timeIntervalSince1970))"
        ) { _ in
        }
    }

    // MARK: Private

    @State private var taskVM = TakeViewShotButtonVM()

    private let content: () -> Content
    private let subLabel: () -> SubLabelContent
}

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
private final class TakeViewShotButtonVM: TaskManagedVM {
    public var finishedHEICImage: HEICImage?

    public var isConfirmationDialogVisible: Binding<Bool> {
        .init(get: { [weak self] in
            self?.finishedHEICImage != nil && OS.type != .macOS
        }, set: { [weak self] newValue in
            if !newValue {
                self?.finishedHEICImage = nil
            }
        })
    }

    public var isFileExporterVisible: Binding<Bool> {
        .init(get: { [weak self] in
            self?.finishedHEICImage != nil && OS.type == .macOS
        }, set: { [weak self] newValue in
            if !newValue {
                self?.finishedHEICImage = nil
            }
        })
    }

    @ViewBuilder public var statusIconView: some View {
        if taskState == .busy {
            WinUI3ProgressRing()
                .frame(width: 24, height: 24, alignment: .center)
        } else {
            Image(systemSymbol: .cameraAperture)
                .frame(width: 24, height: 24, alignment: .center)
        }
    }

    public func takeShot<T: View>(_ content: T) {
        fireTask {
            let renderedCGImage: CGImage? = await MainActor.run {
                let renderer = ImageRenderer(content: content)
                renderer.scale = 2
                return renderer.cgImage
            }
            if let renderedCGImage {
                return HEICImage(
                    cgImage: renderedCGImage,
                    filename: "Image_\(Int(Date().timeIntervalSince1970)).heic"
                )
            }
            return nil
        } completionHandler: { [weak self] maybeHEIC in
            self?.finishedHEICImage = maybeHEIC
        }
    }
}

#endif
