// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PhotosUI
import SFSafeSymbols
import SwiftUI
import UniformTypeIdentifiers
import WallpaperKit

#if !os(watchOS)

struct UserWallpaperMakerView: View {
    // MARK: Lifecycle

    public init(
        completionHandler: @escaping (UserWallpaper) -> Void,
        failureHandler: @escaping () -> Void
    ) {
        self.completionHandler = completionHandler
        self.failureHandler = failureHandler
    }

    // MARK: Public

    public var body: some View {
        Form {
            switch $currentStep.animation().wrappedValue {
            case .chooseImage:
                Section {
                    PhotosPicker(
                        selection: $currentPhotoPickerItem.animation(),
                        matching: .any(of: [.images, .not(.livePhotos), .screenshots])
                    ) {
                        Label {
                            Text(
                                "userWPCropper.step1.button.pickImageUsingPhotoPicker",
                                bundle: .module
                            )
                        } icon: {
                            Image(systemSymbol: .photoStack)
                        }
                    }
                    .onChange(of: currentPhotoPickerItem) { _, newPickerItem in
                        guard let newPickerItem else { return }
                        Task {
                            let data = try? await newPickerItem.loadTransferable(type: Data.self)
                            guard let data else { return }
                            if let cgImg = CGImage.instantiate(data: data) {
                                currentStep = .crop4Horizontal(raw: cgImg)
                            } else {
                                presentationMode.wrappedValue.dismiss()
                                failureHandler()
                            }
                        }
                    }
                    Button {
                        isComDlg32Visible = true
                    } label: {
                        Label {
                            Text(
                                "userWPCropper.step1.button.pickImageUsingFileImporter",
                                bundle: .module
                            )
                        } icon: {
                            Image(systemSymbol: .doc)
                        }
                    }
                } footer: {
                    Text("userWPCropper.step1.footerDescription", bundle: .module)
                }
            case let .crop4Horizontal(cgImage):
                CGImageCropperView(
                    .init(width: 420, height: 200),
                    sourceImage: cgImage
                ) { cgImage4Horizontal in
                    currentStep = .crop4Squared(
                        raw: cgImage,
                        horizontal: cgImage4Horizontal
                    )
                }
            case let .crop4Squared(cgImage, cgImage4Horizontal):
                CGImageCropperView(
                    .init(width: 420, height: 420),
                    sourceImage: cgImage
                ) { cgImage4Squared in
                    let wallpaper = UserWallpaper(
                        imageHorizontal: cgImage4Horizontal,
                        imageSquared: cgImage4Squared
                    )
                    if let wallpaper {
                        presentationMode.wrappedValue.dismiss()
                        completionHandler(wallpaper)
                    } else {
                        presentationMode.wrappedValue.dismiss()
                        failureHandler()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(navTitle)
        .navBarTitleDisplayMode(.large)
        .apply { currentContent in
            currentContent
                .fileImporter(
                    isPresented: $isComDlg32Visible,
                    allowedContentTypes: [.jpeg, .gif, .heic, .bmp, .webP, .tiff],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case let .success(fetchedURLs):
                        defer {
                            fetchedURLs.first?.stopAccessingSecurityScopedResource()
                        }
                        if let url = fetchedURLs.first,
                           url.startAccessingSecurityScopedResource(),
                           let cgImg = CGImage.instantiate(url: url) {
                            currentStep = .crop4Horizontal(raw: cgImg)
                        } else {
                            fallthrough
                        }
                    case .failure:
                        presentationMode.wrappedValue.dismiss()
                        failureHandler()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("sys.cancel".i18nBaseKit) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                // 逼着用户改用自订的后退按钮。
                // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
                // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
                .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: Private

    private enum OperationStep {
        case chooseImage
        case crop4Horizontal(raw: CGImage)
        case crop4Squared(raw: CGImage, horizontal: CGImage)
    }

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var currentStep: OperationStep = .chooseImage
    @State private var isComDlg32Visible = false
    @State private var currentPhotoPickerItem: PhotosPickerItem?

    private let completionHandler: (UserWallpaper) -> Void
    private let failureHandler: () -> Void

    private var navTitle: Text {
        switch currentStep {
        case .chooseImage: Text("userWPCropper.navTitle.step1.chooseImage", bundle: .module)
        case .crop4Horizontal: Text("userWPCropper.navTitle.step2.cropHorizontal", bundle: .module)
        case .crop4Squared: Text("userWPCropper.navTitle.step3.cropSquared", bundle: .module)
        }
    }
}

#endif
