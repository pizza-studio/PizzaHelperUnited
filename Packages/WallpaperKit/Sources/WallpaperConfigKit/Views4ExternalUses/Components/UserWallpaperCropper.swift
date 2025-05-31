// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import SFSafeSymbols
import SwiftUI
import WallpaperKit

#if !os(watchOS)

struct UserWallpaperCropper: View {
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
                    // TODO: Provide both filedialog and photopicker methods.
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
    }

    // MARK: Private

    private enum OperationStep {
        case chooseImage
        case crop4Horizontal(raw: CGImage)
        case crop4Squared(raw: CGImage, horizontal: CGImage)
    }

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var currentStep: OperationStep = .chooseImage

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
