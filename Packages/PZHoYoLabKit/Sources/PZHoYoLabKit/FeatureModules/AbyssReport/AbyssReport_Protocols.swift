// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportSet

public protocol AbyssReportSet: AbleToCodeSendHash {
    associatedtype Report: AbyssReport
    var current: Report { get }
    var previous: Report? { get set }
    var costumeMap: [String: String] { get set }
}

// MARK: - AbyssReport

public protocol AbyssReport: AbleToCodeSendHash {
    associatedtype ViewType: AbyssReportView where Self == ViewType.AbyssReportData
}

extension AbyssReport {
    @MainActor @ViewBuilder
    public func asView(profile: PZProfileSendable?) -> some View {
        ViewType(data: self, profile: profile)
    }
}

// MARK: - AbyssReportView

@MainActor
public protocol AbyssReportView: View {
    associatedtype AbyssReportData: AbyssReport where Self == AbyssReportData.ViewType
    init(data: AbyssReportData, profile: PZProfileSendable?)
    var data: AbyssReportData { get }
    static var navTitle: String { get }
    static var abyssIcon: Image { get }
    @ViewBuilder var body: Self.Body { get }
}

extension AbyssReportView {
    public static var abyssStarIcon: Image { Image("abyssStar", bundle: .module) }

    @ViewBuilder
    public static func drawAbyssStarIcon(size: CGFloat = 20) -> some View {
        Image("abyssStar", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(
                Color(cgColor: .init(red: 0.99, green: 0.92, blue: 0.65, alpha: 1.00))
            )
            .shadow(color: .black, radius: 1)
    }
}

// MARK: - Debug

extension AbyssReportView {
    @ViewBuilder public var debugBody: some View {
        VStack {
            Text(verbatim: "Abyss Report Loaded Successfully.")
            Button {
                copyEncoded()
            } label: {
                Text(verbatim: "Dump JSON to clipboard.")
            }
            .buttonStyle(.bordered)
            ScrollView {
                ZStack(alignment: .topLeading) {
                    Color.primary.colorInvert()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text(textRaw)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var textRaw: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(data) else { return "" }
        guard let dataText = String(data: data, encoding: .utf8) else { return "" }
        return dataText
    }

    func copyEncoded() {
        guard !textRaw.isEmpty else { return }
        Clipboard.currentString = textRaw
    }

    var decoratedIconSize: CGFloat {
        (ThisDevice.isSmallestSlideOverWindowWidth || ThisDevice.isSmallestHDScreenPhone) ? 45 : 55
    }
}
