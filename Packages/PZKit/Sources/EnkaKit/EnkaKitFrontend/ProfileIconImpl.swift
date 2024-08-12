// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

extension EKQueriedProfileProtocol {
    @MainActor
    public func onlineIcon(imageHandler: ((Image) -> Image)? = nil) -> AsyncImage<some View> {
        AsyncImage(url: onlineAssetURLStr.asURL) { imgObj in
            if let imageHandler {
                imageHandler(imgObj)
            } else {
                imgObj.resizable()
            }
        } placeholder: {
            Image(Self.nullPhotoAssetName, bundle: Bundle.module).resizable().aspectRatio(contentMode: .fit)
        }
    }

    @ViewBuilder @MainActor public var localFittingIcon4SUI: some View {
        Group {
            if let local = Enka.queryImageAssetSUI(for: iconAssetName) {
                local.resizable().aspectRatio(contentMode: .fit)
            } else {
                onlineIcon().aspectRatio(contentMode: .fit)
            }
        }.background {
            Color.black.opacity(0.15)
            /// 拿 Anonymous 的橙黄色当背景也不赖。
            Image(Self.nullPhotoAssetName, bundle: Bundle.module).resizable().aspectRatio(contentMode: .fit)
        }
        .clipShape(.circle)
    }
}

#if DEBUG

private let profileHSR: Enka.QueriedProfileHSR = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4HSR(locTag: "zh-cn")
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileHSR.json"
    let dataURL = URL(fileURLWithPath: filePath)
    let profile = try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultHSR.self).detailInfo!
    return profile
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

private let profileGI: Enka.QueriedProfileGI = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4GI(locTag: "zh-cn")
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileGI.json"
    let dataURL = URL(fileURLWithPath: filePath)
    let profile = try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultGI.self).detailInfo!
    return profile
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

#Preview {
    VStack {
        profileHSR.localFittingIcon4SUI
        profileGI.localFittingIcon4SUI
    }
}

#endif
