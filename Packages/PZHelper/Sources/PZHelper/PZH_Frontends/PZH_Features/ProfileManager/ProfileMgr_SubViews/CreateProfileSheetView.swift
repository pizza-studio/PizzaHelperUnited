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

        @MainActor var body: some View {
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
                        ToolbarItem(placement: .confirmationAction) {
                            Button("sys.done".i18nBaseKit) {
                                saveProfile()
                                // globalDailyNoteCardRefreshSubject.send(())
                                alertToastEventStatus.isProfileTaskSucceeded.toggle()
                            }
                            .disabled(status != .gotProfile)
                        }
                    } else {
                        ToolbarItem(placement: .confirmationAction) {
                            menuForManagingHoYoLabProfiles()
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
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

        /// 仅用于对批次帐号处理当中的单个帐号的处理。
        /// 所以，这个函式并未在最终执行 modelContext.save()。
        @MainActor
        func handleSingleFetchedUnit(_ account: FetchedAccount, game: Pizza.SupportedGame) async throws {
            guard let server = HoYo.Server(uid: account.gameUid, game: game) else { return }
            let newProfile = PZProfileMO(server: server, uid: account.gameUid)
            newProfile.game = game
            newProfile.server = server
            newProfile.name = account.nickname
            newProfile.cookie = profile.cookie // 很重要
            newProfile.deviceID = profile.deviceID
            checkFP: switch server.region {
            case .hoyoLab:
                // HoYoLAB automatically supplies valid device_FP values in the cookie.
                break checkFP
            case .miyoushe:
                newProfile.deviceFingerPrint = try await HoYo.getDeviceFingerPrint(
                    region: server.region, deviceID: profile.deviceID
                ).deviceFP
            }

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

        /// Add all accounts at once.
        func getAllAccountsFetched() {
            Task(priority: .userInitiated) { @MainActor in
                if !profile.cookie.isEmpty {
                    do {
                        var map = [(Pizza.SupportedGame, FetchedAccount)]()

                        try await HoYo.getUserGameRolesByCookie(
                            region: region.withGame(.genshinImpact),
                            cookie: profile.cookie
                        ).forEach {
                            map.append((.genshinImpact, $0))
                        }

                        try await HoYo.getUserGameRolesByCookie(
                            region: region.withGame(.starRail),
                            cookie: profile.cookie
                        ).forEach {
                            map.append((.starRail, $0))
                        }

                        try await HoYo.getUserGameRolesByCookie(
                            region: region.withGame(.zenlessZone),
                            cookie: profile.cookie
                        ).forEach {
                            map.append((.zenlessZone, $0))
                        }

                        for (game, fetchedAccount) in map {
                            try await handleSingleFetchedUnit(fetchedAccount, game: game)
                        }

                        alertToastEventStatus.isProfileTaskSucceeded.toggle()
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
                        // This make sure it refreshes everytime you rescan using QR Code.
                        status = .gotProfile
                    } catch {
                        getAccountError = .source(error)
                        isGetAccountFailAlertShown.toggle()
                        status = .pending
                    }
                }
            }
        }

        @MainActor @ViewBuilder
        func menuForManagingHoYoLabProfiles() -> some View {
            Menu {
                HoYoPassWithdrawView.linksForManagingHoYoLabAccounts
            } label: {
                Text("profileMgr.manageHoYoAccounts.shortened".i18nPZHelper)
            }
        }

        @MainActor @ViewBuilder
        func pendingView() -> some View {
            Group {
                Section {
                    RequireLoginView(
                        unsavedCookie: $profile.cookie,
                        unsavedFP: $profile.deviceFingerPrint,
                        deviceID: $profile.deviceID,
                        region: $region,
                        game: game,
                        importAllUIDs: $importAllUIDs
                    )
                } header: {
                    Text("profile.login.sectionHeader".i18nPZHelper).textCase(.none)
                } footer: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("profileMgr.login.manual.1".i18nPZHelper)
                            NavigationLink {
                                ProfileConfigEditorView(unsavedProfile: profile)
                            } label: {
                                Text("profileMgr.login.manual.2")
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

        @MainActor @ViewBuilder
        func gotCookieView() -> some View {
            ProgressView()
        }

        @MainActor @ViewBuilder
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

        private var game: Binding<Pizza.SupportedGame> {
            .init(
                get: { profile.server.game },
                set: { newGame in
                    profile.server.changeGame(to: newGame)
                    region.changeGame(to: newGame)
                }
            )
        }
    }
}

// MARK: - RequireLoginView

private struct RequireLoginView: View {
    // MARK: Lifecycle

    public init(
        unsavedCookie: Binding<String>,
        unsavedFP: Binding<String>,
        deviceID: Binding<String>,
        region: Binding<HoYo.AccountRegion>,
        game: Binding<Pizza.SupportedGame>,
        importAllUIDs: Binding<Bool>
    ) {
        self._unsavedCookie = unsavedCookie
        self._unsavedFP = unsavedFP
        self._deviceID = deviceID
        self._region = region
        self._importAllUIDs = importAllUIDs
        self._game = game
    }

    // MARK: Internal

    @Binding var deviceID: String

    @MainActor var body: some View {
        VStack {
            Text("settings.profile.pleaseSelectGame".i18nPZHelper).frame(maxWidth: .infinity, alignment: .leading)
            Picker("".description, selection: $game) {
                ForEach(Pizza.SupportedGame.allCases) { currentGame in
                    Text(currentGame.localizedDescriptionTrimmed)
                        .tag(currentGame)
                }
            }
            .pickerStyle(.segmented)
            .fontWidth(.condensed)
        }
        LabeledContent("settings.profile.pleaseSelectRegion".i18nPZHelper) {
            Picker("".description, selection: $region) {
                let regionsMatched = HoYo.AccountRegion.getCases(region.game)
                ForEach(regionsMatched) { matchedRegion in
                    Text(matchedRegion.localizedDescription)
                        .tag(matchedRegion)
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

        NavigationLink {
            handleSheetNavigation()
        } label: {
            Text(loginLabelText + " \(region.localizedDescription)\n(\(game.localizedDescription))")
                .fontWeight(.bold)
                .fontWidth(.condensed)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                }
        }
        .foregroundColor(.accentColor)
    }

    // MARK: Private

    @Binding private var importAllUIDs: Bool
    @Binding private var unsavedCookie: String
    @Binding private var unsavedFP: String
    @Binding private var region: HoYo.AccountRegion
    @Binding private var game: Pizza.SupportedGame

    private var loginLabelText: String {
        unsavedCookie.isEmpty
            ? "settings.profile.clickHereToLogin".i18nPZHelper
            : "settings.profile.clickHereToLogin.reLogin".i18nPZHelper
    }

    @MainActor @ViewBuilder
    private func handleSheetNavigation() -> some View {
        Group {
            switch region {
            case .hoyoLab:
                GetCookieWebView(
                    cookie: $unsavedCookie,
                    region: region.withGame(game)
                )
            case .miyoushe:
                GetCookieQRCodeView(cookie: $unsavedCookie, deviceFP: $unsavedFP, deviceID: $deviceID)
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        #if os(iOS) || targetEnvironment(macCatalyst)
        .toolbar(.hidden, for: .tabBar)
        #endif
        // 逼着用户改用自订的后退按钮。
        // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
        // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
        .navigationBarBackButtonHidden(true)
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

    @MainActor var body: some View {
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
