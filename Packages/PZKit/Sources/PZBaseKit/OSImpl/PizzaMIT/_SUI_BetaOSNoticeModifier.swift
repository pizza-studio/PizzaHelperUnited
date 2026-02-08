// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import SwiftUI

extension View {
    @ViewBuilder
    public func hookingBetaOSNoticeModifier() -> some View {
        modifier(BetaOSNoticeModifier())
    }
}

// MARK: - BetaOSNoticeModifier

private struct BetaOSNoticeModifier: ViewModifier {
    // MARK: Lifecycle

    public init() {
        self.isNoticeBypassed = !OS.isBetaOSBeforeFirstMajorPublicRelease
    }

    // MARK: Public

    public func body(content: Content) -> some View {
        if isNoticeBypassed {
            content
        } else {
            NavigationView {
                List {
                    Section {
                        Label {
                            VStack(alignment: .leading) {
                                Text("pizza.notice.prematureBetaOSDetected.title", bundle: .currentSPM)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("pizza.notice.prematureBetaOSDetected.description", bundle: .currentSPM)
                                    .asInlineTextDescription()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } icon: {
                            Image(systemSymbol: .exclamationmarkTriangleFill)
                                .foregroundColor(.red)
                        }
                        Button {
                            isNoticeBypassed.toggle()
                        } label: {
                            ZStack {
                                Capsule()
                                    .fill(Color.accentColor)
                                Text("sys.agree", bundle: .currentSPM)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BrighteningPressButtonStyle())
                    } header: {
                        if let buildString = OSBuild.getSystemBuildString() {
                            HStack {
                                Text(verbatim: "OSBuild: \(buildString)")
                            }
                        }
                    }
                }
                .navigationTitle(Pizza.appTitleLocalizedFull)
            }
            .navigationViewStyle(.stack)
        }
    }

    // MARK: Private

    @State private var isNoticeBypassed: Bool
}

// MARK: - BrighteningPressButtonStyle

private struct BrighteningPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.5 : 0)
    }
}

#Preview {
    NavigationView {
        List {
            Text(verbatim: "114514")
        }
    }
    .navigationViewStyle(.stack)
    .hookingBetaOSNoticeModifier()
}
