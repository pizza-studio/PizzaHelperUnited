// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - HoYoAPIErrorView

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct HoYoAPIErrorView: View {
    let profile: PZProfileSendable
    let apiPath: String
    let error: Error
    let completion: () -> Void

    var body: some View {
        if case .verificationNeeded = error as? MiHoYoAPIError {
            VerificationNeededView(profile: profile, challengePath: apiPath) {
                completion()
            }
        } else {
            Button {
                completion()
            } label: {
                Label {
                    VStack {
                        HStack {
                            Text(error.localizedDescription)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemSymbol: .arrowClockwiseCircle)
                        }
                        let detailedError = Text(verbatim: "\(error)")
                            .foregroundStyle(.primary)
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if case let MiHoYoAPIError.other(retcode: retcode, message: _) = error {
                            switch retcode {
                            case -114514: EmptyView()
                            default: detailedError
                            }
                        }
                    }
                } icon: {
                    Image(systemSymbol: .exclamationmarkCircle)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

// MARK: HoYoAPIErrorView.VerificationNeededView

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HoYoAPIErrorView {
    struct VerificationNeededView: View {
        // MARK: Internal

        let profile: PZProfileSendable
        let challengePath: String
        let completion: () -> Void

        var disableButton: Bool {
            if case .progressing = status {
                true
            } else if case .gotVerification = status {
                true
            } else {
                false
            }
        }

        var body: some View {
            VStack {
                Button {
                    status = .progressing
                    popVerificationWebSheet()
                } label: {
                    Label {
                        Text("profileMgr.test.verify.button".i18nPZHelper)
                    } icon: {
                        Image(systemSymbol: .exclamationmarkTriangle)
                            .foregroundStyle(.yellow)
                    }
                }
                .disabled(disableButton)
                .sheet(item: $sheetItem, content: { item in
                    switch item {
                    case let .gotVerification(verification):
                        NavigationStack {
                            GeetestValidateView(
                                challenge: verification.challenge,
                                gt: verification.gt,
                                completion: { validate in
                                    Task.detached { @MainActor in
                                        status = .pending
                                        verifyValidate(challenge: verification.challenge, validate: validate)
                                        sheetItem = nil
                                    }
                                }
                            )
                            .listContainerBackground()
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("sys.cancel".i18nBaseKit) {
                                        status = .pending
                                        sheetItem = nil
                                    }
                                }
                            }
                            .navigationTitle("profileMgr.test.verify.web_sheet.title".i18nPZHelper)
                        }
                    }
                })
                if case let .fail(error) = status {
                    Text("Error: \(error.localizedDescription)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipShape(Rectangle())
        }

        func popVerificationWebSheet() {
            Task(priority: .userInitiated) {
                do {
                    let verification = try await HoYo.createVerification(
                        region: profile.server.region,
                        cookie: profile.cookie,
                        deviceID: profile.deviceID,
                        deviceFingerPrint: profile.deviceFingerPrint
                    )
                    Task.detached { @MainActor in
                        status = .gotVerification(verification)
                        sheetItem = .gotVerification(verification)
                    }
                } catch {
                    status = .fail(error)
                }
            }
        }

        func verifyValidate(challenge: String, validate: String) {
            Task { @MainActor in
                do {
                    try await HoYo.verifyVerification(
                        region: profile.server.region,
                        challenge: challenge,
                        validate: validate,
                        cookie: profile.cookie,
                        deviceFingerPrint: profile.deviceFingerPrint
                    )
                    completion()
                } catch {
                    status = .fail(error)
                }
            }
        }

        // MARK: Private

        private enum Status: CustomStringConvertible {
            case pending
            case progressing
            case gotVerification(Verification)
            case fail(Error)

            // MARK: Internal

            var description: String {
                switch self {
                case let .fail(error): "ERROR: \(error.localizedDescription)"
                case .progressing: "gettingVerification"
                case let .gotVerification(verification): "Challenge: \(verification.challenge)"
                case .pending: "PENDING"
                }
            }
        }

        private enum SheetItem: Identifiable {
            case gotVerification(Verification)

            // MARK: Internal

            var id: Int {
                switch self {
                case let .gotVerification(verification):
                    verification.challenge.hashValue
                }
            }
        }

        @State private var status: Status = .pending

        @State private var sheetItem: SheetItem?
    }
}
