// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Alamofire
import Foundation
import SwiftUI

// SwiftUI 视图封装
@available(iOS 15.0, macCatalyst 15.0, *)
public struct AsyncCGImage<Content: View, Placeholder: View>: View {
    // MARK: Lifecycle

    public init(
        url: URL,
        forceJPEG: Bool = false,
        dataHandler: ((CGImage) async throws -> CGImage)? = nil,
        @ViewBuilder content: @escaping (CGImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.forceJPEG = forceJPEG
        self.dataHandler = dataHandler
        self.content = content
        self.placeholder = placeholder
    }

    // MARK: Public

    public var body: some View {
        Group {
            if let cgImage = cgImage {
                content(cgImage)
            } else if error != nil {
                placeholder()
            } else {
                placeholder()
                    .task {
                        do {
                            cgImage = try await load(
                                from: url,
                                forceJPEG: forceJPEG,
                                dataHandler: dataHandler
                            )
                        } catch {
                            self.error = error
                        }
                    }
            }
        }
    }

    // MARK: Internal

    /// 错误类型
    enum ImageLoadingError: Error {
        case noData
        case invalidImageData
    }

    // MARK: Private

    @State private var cgImage: CGImage?
    @State private var error: Error?

    private let url: URL
    private let forceJPEG: Bool
    private let dataHandler: ((CGImage) async throws -> CGImage)?
    private let content: (CGImage) -> Content
    private let placeholder: () -> Placeholder

    /// 异步加载图片并返回 CGImage
    /// - Parameters:
    ///   - url: 图片的 URL
    ///   - forceJPEG: 是否强制作为 JPEG 处理
    ///   - dataHandler: 可选的自定义数据处理器
    /// - Returns: 处理后的 CGImage
    private func load(
        from url: URL,
        forceJPEG: Bool = false,
        dataHandler: ((CGImage) async throws -> CGImage)? = nil
    ) async throws
        -> CGImage {
        // 使用 Alamofire 下载数据
        let data = try await AF.request(url).serializingData().value

        // 使用提供的 CGImage.instantiate 创建图片
        guard let cgImage = CGImage.instantiate(data: data, forceJPEG: forceJPEG) else {
            throw ImageLoadingError.invalidImageData
        }

        // 处理数据
        return try await dataHandler?(cgImage) ?? cgImage
    }
}
