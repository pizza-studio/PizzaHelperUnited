// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import PZAccountKit
import PZBaseKit
import SwiftUI

struct TestAccountSectionView: View {
    // MARK: Internal

    @State var profile: PZProfileMO

    var body: some View {
        Section {
            Button {
                doTest()
            } label: {
                HStack {
                    Text("profile.accountConnectivity.buttonTitle".i18nPZHelper)
                    Spacer()
                    buttonIcon()
                }
            }
            .disabled(status == .testing)
            if case let .failure(error) = status {
                FailureView(error: error)
            } else if status == .verificationNeeded {
                VerificationNeededView(profile: profile) {
                    doTest()
                }
            }
        } footer: {
            if verificationErrorHasOccurred {
                Text("profile.accountConnectivity.footer.recommend_device_fp".i18nPZHelper)
            }
        }
        .onAppear {
            doTest()
        }
        .onChange(of: profile.cookie) {
            doTest()
        }
    }

    func doTest() {
        withAnimation {
            status = .testing
        }
        Task {
            do {
                switch profile.game {
                case .genshinImpact:
                    _ = try await HoYo.note4GI(
                        server: profile.server,
                        uid: profile.uid,
                        cookie: profile.cookie,
                        sTokenV2: profile.sTokenV2,
                        deviceFingerPrint: profile.deviceFingerPrint,
                        deviceId: ThisDevice.identifier4Vendor
                    )
                case .starRail:
                    _ = try await HoYo.note4HSR(
                        server: profile.server,
                        uid: profile.uid,
                        cookie: profile.cookie,
                        deviceFingerPrint: profile.deviceFingerPrint
                    )
                }
                withAnimation {
                    status = .succeeded
                }
            } catch MiHoYoAPIError.verificationNeeded {
                withAnimation {
                    status = .verificationNeeded
                    verificationErrorHasOccurred = true
                }
            } catch {
                withAnimation {
                    status = .failure(error)
                }
            }
        }
    }

    @ViewBuilder
    func buttonIcon() -> some View {
        Group {
            switch status {
            case .succeeded:
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            case .failure:
                Image(systemSymbol: .xmarkCircle)
                    .foregroundColor(.red)
            case .testing:
                ProgressView()
            case .verificationNeeded:
                Image(systemSymbol: .questionmarkCircle)
                    .foregroundColor(.yellow)
            default:
                EmptyView()
            }
        }
    }

    // MARK: Private

    private enum TestStatus: Identifiable, Equatable {
        case pending
        case testing
        case succeeded
        case failure(Error)
        case verificationNeeded

        // MARK: Internal

        var id: Int {
            switch self {
            case .pending:
                return 0
            case .testing:
                return 1
            case .succeeded:
                return 2
            case let .failure(error):
                return error.localizedDescription.hashValue
            case .verificationNeeded:
                return 4
            }
        }

        static func == (lhs: TestAccountSectionView.TestStatus, rhs: TestAccountSectionView.TestStatus) -> Bool {
            lhs.id == rhs.id
        }
    }

    private struct FailureView: View {
        let error: Error

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(error.localizedDescription)
                Text("\(error)").font(.caption2)
            }.multilineTextAlignment(.leading)
            if let error = error as? LocalizedError {
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                }
            }
        }
    }

    private struct VerificationNeededView: View {
        // MARK: Internal

        let profile: PZProfileMO
        @State var shouldRefreshAccount: () -> Void

        var body: some View {
            Button {
                status = .progressing
                popVerificationWebSheet()
            } label: {
                Text("profile.accountConnectivity.verify.button".i18nPZHelper)
            }
            .onAppear {
                popVerificationWebSheet()
            }
            .sheet(item: $sheetItem, content: { item in
                switch item {
                case let .gotVerification(verification):
                    NavigationStack {
                        GeetestValidateView(
                            challenge: verification.challenge,
                            gt: verification.gt,
                            completion: { validate in
                                status = .pending
                                verifyValidate(challenge: verification.challenge, validate: validate)
                                sheetItem = nil
                            }
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("sys.cancel".i18nBaseKit) {
                                    sheetItem = nil
                                }
                            }
                        }
                        .navigationTitle("profile.accountConnectivity.verify.web_sheet.title".i18nPZHelper)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            })
            if case let .fail(error) = status {
                Text("Error: \(error.localizedDescription)")
            }
        }

        func popVerificationWebSheet() {
            Task(priority: .userInitiated) {
                do {
                    let verification = try await HoYo.createVerification(
                        region: profile.server.region,
                        cookie: profile.cookie,
                        deviceFingerPrint: profile.deviceFingerPrint
                    )
                    status = .gotVerification(verification)
                    sheetItem = .gotVerification(verification)
                } catch {
                    status = .fail(error)
                }
            }
        }

        func verifyValidate(challenge: String, validate: String) {
            Task {
                do {
                    _ = try await HoYo.verifyVerification(
                        region: profile.server.region,
                        challenge: challenge,
                        validate: validate,
                        cookie: profile.cookie,
                        deviceFingerPrint: profile.deviceFingerPrint
                    )
                    withAnimation {
                        shouldRefreshAccount()
                    }
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
                case let .fail(error):
                    return "ERROR: \(error.localizedDescription)"
                case .progressing:
                    return "gettingVerification"
                case let .gotVerification(verification):
                    return "Challenge: \(verification.challenge)"
                case .pending:
                    return "PENDING"
                }
            }
        }

        private enum SheetItem: Identifiable {
            case gotVerification(Verification)

            // MARK: Internal

            var id: Int {
                switch self {
                case let .gotVerification(verification):
                    return verification.challenge.hashValue
                }
            }
        }

        @State private var status: Status = .progressing

        @State private var sheetItem: SheetItem?
    }

    @State private var status: TestStatus = .pending

    @State private var verificationErrorHasOccurred: Bool = false
}
