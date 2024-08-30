// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - ProfileManagerPageContent.CreateProfileSheetView

extension ProfileManagerPageContent {
    struct CreateProfileSheetView: View {
        // MARK: Lifecycle

        init(profile: PZProfileMO, isShown: Binding<Bool>) {
            self._isShown = isShown
            self._profile = State(wrappedValue: profile)
        }

        // MARK: Internal

        var body: some View {
            NavigationStack {
                Form {
                    switch status {
                    case .pending:
                        pendingView()
                    case .gotCookie:
                        gotCookieView()
                    case .gotProfile:
                        gotProfileView()
                    }
                }
                .formStyle(.grouped)
                .navigationTitle("profileMgr.new".i18nPZHelper)
                .toolbar {
                    if status != .pending {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("sys.done".i18nBaseKit) {
                                saveProfile()
                                // globalDailyNoteCardRefreshSubject.send(())
                                alertToastEventStatus.isDoneButtonTapped.toggle()
                            }
                            .disabled(status != .gotProfile)
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            menuForManagingHoYoLabProfiles()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("sys.cancel".i18nBaseKit) {
                            modelContext.rollback()
                            isShown.toggle()
                        }
                    }
                }
                .alert(isPresented: $isSaveProfileFailAlertShown, error: saveProfileError) {
                    Button("sys.ok".i18nBaseKit) {
                        isSaveProfileFailAlertShown.toggle()
                    }
                }
                .alert(isPresented: $isGetAccountFailAlertShown, error: getAccountError) {
                    Button("sys.ok".i18nBaseKit) {
                        isGetAccountFailAlertShown.toggle()
                    }
                }
                .onChange(of: status) { _, newValue in
                    switch newValue {
                    case .gotCookie:
                        if importAllUIDs {
                            getAllAccountsFetched()
                        } else {
                            getAccountForSelected()
                        }
                    default:
                        return
                    }
                }
            }
        }

        func saveProfile() {
            guard profile.isValid else {
                saveProfileError = .missingFieldError("UID / Name")
                isSaveProfileFailAlertShown.toggle()
                return
            }
            do {
                modelContext.insert(profile)
                try modelContext.save()
                isShown.toggle()
                Broadcaster.shared.requireOSNotificationCenterAuthorization()
                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
            } catch {
                saveProfileError = .saveDataError(error)
                isSaveProfileFailAlertShown.toggle()
            }
        }

        /// Add all accounts at once.
        func getAllAccountsFetched() {
            Task(priority: .userInitiated) {
                if !profile.cookie.isEmpty {
                    do {
                        @MainActor func handleFetched(_ account: FetchedAccount, game: Pizza.SupportedGame) {
                            guard let server = HoYo.Server(uid: account.gameUid, game: game) else { return }
                            let newProfile = PZProfileMO(server: server, uid: account.gameUid)
                            newProfile.name = account.nickname
                            newProfile.cookie = profile.cookie // 很重要
                            newProfile.deviceID = profile.deviceID
                            newProfile.deviceFingerPrint = profile.deviceFingerPrint
                            newProfile.game = game
                            newProfile.server = server

                            // Check duplications
                            let firstDuplicate = profiles.first {
                                $0.uid == newProfile.uid && $0.game == newProfile.game
                            }
                            if let firstDuplicate {
                                firstDuplicate.cookie = profile.cookie // 很重要
                                firstDuplicate.deviceID = profile.deviceID
                                firstDuplicate.deviceFingerPrint = profile.deviceFingerPrint
                            } else {
                                modelContext.insert(newProfile)
                            }
                            status = .gotProfile
                        }

                        try await HoYo.getUserGameRolesByCookie(
                            region: region.withGame(.genshinImpact),
                            cookie: profile.cookie
                        ).forEach {
                            handleFetched($0, game: .genshinImpact)
                        }

                        try await HoYo.getUserGameRolesByCookie(
                            region: region.withGame(.starRail),
                            cookie: profile.cookie
                        ).forEach {
                            handleFetched($0, game: .starRail)
                        }

                        try await HoYo.getUserGameRolesByCookie(
                            region: region.withGame(.zenlessZone),
                            cookie: profile.cookie
                        ).forEach {
                            handleFetched($0, game: .zenlessZone)
                        }

                        alertToastEventStatus.isDoneButtonTapped.toggle()
                        try modelContext.save()
                        isShown.toggle()
                    } catch {
                        getAccountError = .source(error)
                        isGetAccountFailAlertShown.toggle()
                        status = .pending
                    }
                }
            }
        }

        func getAccountForSelected() {
            Task(priority: .userInitiated) {
                if !profile.cookie.isEmpty {
                    do {
                        fetchedAccounts = try await HoYo.getUserGameRolesByCookie(
                            region: region,
                            cookie: profile.cookie
                        )
                        if let account = fetchedAccounts.first,
                           let server = HoYo.Server(uid: account.gameUid, game: region.game) {
                            profile.name = account.nickname
                            profile.uid = account.gameUid
                            profile.game = server.game
                            profile.server = server
                        } else {
                            getAccountError = .customize("profileMgr.loginError.noGameUIDFound".i18nPZHelper)
                        }
                        // Device fingerPrint for MiYouShe profiles are already fetched in GetCookieQRCodeView.
                        status = .gotProfile
                    } catch {
                        getAccountError = .source(error)
                        isGetAccountFailAlertShown.toggle()
                        status = .pending
                    }
                }
            }
        }

        @ViewBuilder
        func menuForManagingHoYoLabProfiles() -> some View {
            Menu {
                HoYoPassWithdrawView.linksForManagingHoYoLabAccounts
            } label: {
                Text("profileMgr.manageHoYoAccounts.shortened".i18nPZHelper)
            }
        }

        @ViewBuilder
        func pendingView() -> some View {
            Group {
                Section {
                    RequireLoginView(
                        unsavedCookie: $profile.cookie,
                        unsavedFP: $profile.deviceFingerPrint,
                        region: $region,
                        importAllUIDs: $importAllUIDs
                    )
                } header: {
                    Text("profile.login.sectionHeader".i18nPZHelper).textCase(.none)
                } footer: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("profile.login.manual.1".i18nPZHelper)
                            NavigationLink {
                                ProfileConfigEditorView(unsavedProfile: profile)
                            } label: {
                                Text("profile.login.manual.2".i18nPZHelper)
                                    .font(.footnote)
                            }
                        }
                        Divider().padding(.vertical)
                        ExplanationView()
                    }
                }
            }
            .onChange(of: profile.cookie) { _, newValue in
                if !newValue.isEmpty {
                    status = .gotCookie
                }
            }
            .interactiveDismissDisabled()
        }

        @ViewBuilder
        func gotCookieView() -> some View {
            ProgressView()
        }

        @ViewBuilder
        func gotProfileView() -> some View {
            ProfileConfigViewContents(profile: profile, fetchedAccounts: fetchedAccounts)
        }

        // MARK: Private

        @State private var importAllUIDs: Bool = true
        @State private var isGetAccountFailAlertShown: Bool = false
        @State private var getAccountError: GetAccountError?
        @State private var status: AddProfileStatus = .pending
        @State private var fetchedAccounts: [FetchedAccount] = []
        @State private var region: HoYo.AccountRegion = .miyoushe(.genshinImpact)
        @State private var profile: PZProfileMO
        @State private var isSaveProfileFailAlertShown: Bool = false
        @State private var saveProfileError: SaveProfileError?
        @Binding private var isShown: Bool
        @Environment(\.modelContext) private var modelContext
        @Environment(AlertToastEventStatus.self) private var alertToastEventStatus
        @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]
    }
}

// MARK: - RequireLoginView

private struct RequireLoginView: View {
    // MARK: Lifecycle

    public init(
        unsavedCookie: Binding<String>,
        unsavedFP: Binding<String>,
        region: Binding<HoYo.AccountRegion>,
        importAllUIDs: Binding<Bool>
    ) {
        self._unsavedCookie = unsavedCookie
        self._unsavedFP = unsavedFP
        self._region = region
        self._importAllUIDs = importAllUIDs
    }

    // MARK: Internal

    var body: some View {
        VStack {
            Text("settings.profile.pleaseSelectGame".i18nPZHelper).frame(maxWidth: .infinity, alignment: .leading)
            Picker("".description, selection: $region) {
                switch region {
                case .hoyoLab:
                    Text(Pizza.SupportedGame.genshinImpact.localizedDescriptionTrimmed)
                        .tag(HoYo.AccountRegion.hoyoLab(.genshinImpact))
                    Text(Pizza.SupportedGame.starRail.localizedDescriptionTrimmed)
                        .tag(HoYo.AccountRegion.hoyoLab(.starRail))
                    Text(Pizza.SupportedGame.zenlessZone.localizedDescriptionTrimmed)
                        .tag(HoYo.AccountRegion.hoyoLab(.zenlessZone))
                case .miyoushe:
                    Text(Pizza.SupportedGame.genshinImpact.localizedDescriptionTrimmed)
                        .tag(HoYo.AccountRegion.miyoushe(.genshinImpact))
                    Text(Pizza.SupportedGame.starRail.localizedDescriptionTrimmed)
                        .tag(HoYo.AccountRegion.miyoushe(.starRail))
                    Text(Pizza.SupportedGame.zenlessZone.localizedDescriptionTrimmed)
                        .tag(HoYo.AccountRegion.miyoushe(.zenlessZone))
                }
            }
            .pickerStyle(.segmented)
            .fontWidth(.condensed)
        }
        LabeledContent("settings.profile.pleaseSelectRegion".i18nPZHelper) {
            Picker("".description, selection: $region) {
                switch region.game {
                case .genshinImpact:
                    Text(HoYo.AccountRegion.miyoushe(.genshinImpact).localizedDescription)
                        .tag(HoYo.AccountRegion.miyoushe(.genshinImpact))
                    Text(HoYo.AccountRegion.hoyoLab(.genshinImpact).localizedDescription)
                        .tag(HoYo.AccountRegion.hoyoLab(.genshinImpact))
                case .starRail:
                    Text(HoYo.AccountRegion.miyoushe(.starRail).localizedDescription)
                        .tag(HoYo.AccountRegion.miyoushe(.starRail))
                    Text(HoYo.AccountRegion.hoyoLab(.starRail).localizedDescription)
                        .tag(HoYo.AccountRegion.hoyoLab(.starRail))
                case .zenlessZone:
                    Text(HoYo.AccountRegion.miyoushe(.zenlessZone).localizedDescription)
                        .tag(HoYo.AccountRegion.miyoushe(.zenlessZone))
                    Text(HoYo.AccountRegion.hoyoLab(.zenlessZone).localizedDescription)
                        .tag(HoYo.AccountRegion.hoyoLab(.zenlessZone))
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()
        }
        VStack {
            Toggle("settings.profile.importAllUIDs".i18nPZHelper, isOn: $importAllUIDs)
            Text("settings.profile.importAllUIDs.explanation".i18nPZHelper)
                .font(.footnote).foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }

        Button {
            assignRegion()
        } label: {
            Text(loginLabelText + " \(region.localizedDescription)\n(\(region.game.localizedDescription))")
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                }
        }
        .sheet(item: $getCookieWebViewRegion, content: handleSheetNavigation)
    }

    // MARK: Private

    @State private var getCookieWebViewRegion: HoYo.AccountRegion?
    @Binding private var importAllUIDs: Bool
    @Binding private var unsavedCookie: String
    @Binding private var unsavedFP: String
    @Binding private var region: HoYo.AccountRegion

    private var loginLabelText: String {
        unsavedCookie.isEmpty
            ? "settings.profile.clickHereToLogin".i18nPZHelper
            : "settings.profile.clickHereToLogin.reLogin".i18nPZHelper
    }

    private var isCookieWebViewShown: Binding<Bool> {
        .init(get: {
            getCookieWebViewRegion != nil
        }, set: { newValue in
            if !newValue {
                getCookieWebViewRegion = nil
            }
        })
    }

    private func assignRegion() {
        getCookieWebViewRegion = region
    }

    @ViewBuilder
    private func handleSheetNavigation(_ region: HoYo.AccountRegion) -> some View {
        switch region {
        case .hoyoLab:
            GetCookieWebView(
                isShown: isCookieWebViewShown,
                cookie: $unsavedCookie,
                region: region
            )
        case .miyoushe:
            GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP)
        }
    }
}

// MARK: - AddProfileStatus

private enum AddProfileStatus {
    case pending
    case gotCookie
    case gotProfile
}

// MARK: - ExplanationView

private struct ExplanationView: View {
    // MARK: Internal

    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 9) {
                Text(verbatim: beareOfTextHeader)
                    .font(.callout)
                    .bold()
                    .foregroundColor(.red)
                ForEach(beareOfTextContents, id: \.self) { currentLine in
                    Text(verbatim: currentLine)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                Text("profileMgr.accountLogin.explanation.title.1".i18nPZHelper)
                    .font(.callout)
                    .bold()
                    .padding(.top)
                Text("profileMgr.accountLogin.explanation.1".i18nPZHelper)
                    .font(.subheadline)
                Text("profileMgr.accountLogin.explanation.title.2".i18nPZHelper)
                    .font(.callout)
                    .bold()
                    .padding(.top)
                Text("profileMgr.accountLogin.explanation.2".i18nPZHelper)
                    .font(.subheadline)
            }
        }
    }

    // MARK: Private

    private let bewareOfTextLines: [String] = "profileMgr.accountLogin.notice.bewareof".i18nPZHelper
        .split(separator: "\n\n").map(\.description)

    private var beareOfTextHeader: String {
        bewareOfTextLines.first ?? "BewareOf_Header"
    }

    private var beareOfTextContents: [String] {
        Array(bewareOfTextLines.dropFirst())
    }
}
