// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - NetworkImage

/// 加载完图片后才会显示，专用于 Widgets。
struct NetworkImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                //         .aspectRatio(contentMode: .fill)
            } else {
                Image("NetworkImagePlaceholder", bundle: .main)
                    .resizable()
                    .clipShape(.circle)
            }
        }
    }
}
