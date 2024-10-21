// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import StoreKit
import SwiftUI

public struct DonationView: View {
    // MARK: Public

    public static let navTitle = "aboutKit.donation.navTitle".i18nAboutKit

    @MainActor public var body: some View {
        List {
            Section {
                Text("aboutKit.donation.msg", bundle: .module)
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }
            Section {
                NavigationLink(
                    destination: WebBrowserView(
                        url: "https://gi.pizzastudio.org/static/thanks.html"
                    )
                    .navigationTitle("aboutKit.donation.specialThanks".i18nAboutKit)
                ) {
                    Text("aboutKit.donation.specialThanks", bundle: .module)
                }
            }

            Section(header: Text("aboutKit.donation.item.header", bundle: .module)) {
                if iapManager.myProducts.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                ForEach(iapManager.myProducts, id: \.self) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.localizedTitle)
                                .font(.headline)
                            Text(product.localizedDescription)
                                .font(.caption2)
                        }
                        Spacer()
                        Button {
                            iapManager.purchaseProduct(product: product)
                        } label: {
                            Text("aboutKit.donation.item.pay", bundle: .module)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.inline)
    }

    @MainActor @ViewBuilder
    public static func makeNav() -> some View {
        NavigationLink {
            DonationView(iapManager: .shared)
        } label: {
            Label(navTitle, systemSymbol: .dollarsignSquare)
        }
    }

    // MARK: Internal

    @StateObject var iapManager: IAPManager
    let locale = Locale.current

    // MARK: Private

    private func priceLocalized(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price) ?? "Price Error"
    }
}
