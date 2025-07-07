// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - NotificationSettingsPageContent

@available(iOS 17.0, macCatalyst 17.0, *)
struct NotificationSettingsPageContent: View {
    // MARK: Public

    public static let navTitle: String = .init(
        localized: "settings.notification.navTitle", bundle: .module
    )

    public static let navTitleShortened: String = .init(
        localized: "settings.notification.navTitle.shortened", bundle: .module
    )

    public var body: some View {
        Form {
            if authorizationStatus != nil {
                if !allowPushNotification {
                    Section {
                        Label {
                            Text("settings.notification.insufficientSystemPrivileges", bundle: .module)
                        } icon: {
                            Image(systemSymbol: .bellSlashFill)
                        }

                        let osSettingsLinkLabel = Label {
                            Text("settings.notification.navigateToOSSettings", bundle: .module)
                        } icon: {
                            Image(systemSymbol: .gear)
                        }
                        #if os(macOS) || targetEnvironment(macCatalyst)
                        let urlOSSettings = "x-apple.systempreferences:com.apple.preference.notifications".asURL
                        #else
                        let urlOSSettings = UIApplication.openSettingsURLString.asURL
                        #endif
                        Link(destination: urlOSSettings) {
                            osSettingsLinkLabel
                        }
                    }
                }
                NotificationSettingDetailContent()
                    .disabled(!allowPushNotification)
            } else {
                ProgressView()
            }
        }
        .formStyle(.grouped)
        .navBarTitleDisplayMode(.large)
        .navigationTitle(Self.navTitleShortened)
        .onAppear {
            Task {
                authorizationStatus = await PZNotificationCenter.authorizationStatus()
                if authorizationStatus == .notDetermined {
                    _ = try? await PZNotificationCenter.requestAuthorization()
                }
            }
        }
    }

    // MARK: Private

    @State private var authorizationStatus: UNAuthorizationStatus?

    private var allowPushNotification: Bool {
        let result = authorizationStatus == .authorized || authorizationStatus == .provisional
        #if os(macOS)
        return result
        #else
        return result || authorizationStatus == .ephemeral
        #endif
    }
}

// MARK: - ProfilesNotificationPermissionView

@available(iOS 17.0, macCatalyst 17.0, *)
private struct ProfilesNotificationPermissionView: View {
    // MARK: Public

    public static let navTitle: String = .init(
        localized: "settings.notification.profilesReceivingNotifications.navTitle", bundle: .module
    )

    public static let navTitleShortened: String = .init(
        localized: "settings.notification.profilesReceivingNotifications.navTitle.shortened", bundle: .module
    )

    // MARK: Internal

    var body: some View {
        Form {
            Section {
                ForEach(profileManagerVM.profiles) { profile in
                    Toggle(
                        isOn: getBinding4AllowingNotification(for: profile).animation()
                    ) {
                        Self.drawLocalProfile(profile, isChosen: profile.allowNotification)
                    }
                }
            } footer: {
                Text("settings.notification.profilesReceivingNotifications.description", bundle: .module)
            }
            .disabled(profileManagerVM.taskState == .busy)
            .saturation(profileManagerVM.taskState == .busy ? 0 : 1)
        }
        .formStyle(.grouped)
        .navBarTitleDisplayMode(.large)
        .navigationTitle(Self.navTitleShortened)
    }

    // MARK: Private

    @State private var profileManagerVM: ProfileManagerVM = .shared

    @ViewBuilder
    private static func drawLocalProfile(
        _ profile: PZProfileSendable,
        isChosen: Bool = false
    )
        -> some View {
        HStack {
            profile.asIcon4SUI().frame(width: 35, height: 35)
            HStack {
                VStack(alignment: .leading) {
                    Text(profile.name)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(profile.uidWithGame)
                        .font(.caption2)
                        .fontDesign(.monospaced)
                        .opacity(0.8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(isChosen ? .primary : .secondary)
                Spacer()
            }
        }.padding(.vertical, 4)
    }

    private func getBinding4AllowingNotification(for profile: PZProfileSendable) -> Binding<Bool> {
        var profile = profile
        return .init {
            profile.allowNotification
        } set: { newValue in
            profile.allowNotification = newValue
            profileManagerVM.updateProfile(
                profile,
                trailingTasks: {
                    PZNotificationCenter.bleachNotificationsIfDisabled(for: profile)
                }
            )
        }
    }
}

// MARK: - StaminaNotificationThresholdConfigView

@available(iOS 17.0, macCatalyst 17.0, *)
private struct StaminaNotificationThresholdConfigView: View {
    // MARK: Public

    public static let navTitle: String = .init(
        localized: "settings.notification.staminaThresholds.navTitle", bundle: .module
    )

    // MARK: Internal

    var body: some View {
        List {
            Section {
                valueInsertionControls
            }
            .alert(
                String(
                    localized: "settings.notification.staminaThresholds.valueAlreadyExist",
                    bundle: .module
                ),
                isPresented: $isNumberExistAlertVisible
            ) {
                Button("sys.ok".i18nBaseKit) {
                    isNumberExistAlertVisible.toggle()
                }
            }
            if !thresholdsForCurrentGame.isEmpty {
                Section {
                    ForEach(thresholdsForCurrentGame, id: \.self) { number in
                        Text(verbatim: "\(number)")
                            .id(number)
                            .contextMenu {
                                Button(role: .destructive) {
                                    options.staminaAdditionalNotificationThresholds.removeAll {
                                        $0.game == game && $0.threshold == number
                                    }
                                    UserDefaults.baseSuite.synchronize()
                                    #if os(iOS) || targetEnvironment(macCatalyst)
                                    if thresholdsForCurrentGame.isEmpty {
                                        isEditMode = .inactive
                                    }
                                    #endif
                                } label: {
                                    Text("sys.delete".i18nBaseKit)
                                }
                            }
                    }
                    .onDelete(perform: deleteItems)
                } header: {
                    Text("settings.notification.staminaThresholds.header", bundle: .module)
                        .textCase(.none)
                } footer: {
                    Text("settings.notification.staminaThresholds.footer", bundle: .module)
                        .textCase(.none)
                }
            }
        }
        .toolbar {
            #if os(iOS) || targetEnvironment(macCatalyst)
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditMode.isEditing ? "sys.done".i18nBaseKit : "sys.edit".i18nBaseKit) {
                    withAnimation {
                        isEditMode = (isEditMode.isEditing) ? .inactive : .active
                    }
                }
            }
            #endif
            ToolbarItem(placement: .confirmationAction) {
                gamePicker
                    .pickerStyle(.segmented)
                    .fixedSize()
            }
        }
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.large)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .environment(\.editMode, $isEditMode)
        #endif
    }

    // MARK: Private

    #if os(iOS) || targetEnvironment(macCatalyst)
    @State private var isEditMode: EditMode = .inactive
    #endif

    @State private var isActivated: Bool = false
    @State private var isNumberExistAlertVisible: Bool = false
    @State private var newNumber: Double = 140.0
    @State private var game: Pizza.SupportedGame = .genshinImpact

    @Default(.notificationOptions) private var options: NotificationOptions

    private var isNewThresholdValid: Bool { !thresholdsForCurrentGame.contains(numberToSave) }
    private var numberToSave: Int { Int(newNumber) }

    private var thresholdsForCurrentGame: [Int] {
        options.staminaAdditionalNotificationThresholds.byGame(game).map(\.threshold)
    }

    @ViewBuilder private var gamePicker: some View {
        Picker("".description, selection: $game.animation()) {
            ForEach(Pizza.SupportedGame.allCases) { game in
                Text(game.localizedShortName).tag(game)
            }
        }
    }

    @ViewBuilder private var valueInsertionControls: some View {
        if isActivated {
            HStack {
                Text("settings.notification.staminaThresholds.add.title", bundle: .module)
                Spacer()
                Text(verbatim: "\(numberToSave)")
                    .foregroundColor(isNewThresholdValid ? .primary : .red)
            }
            .onTapGesture {
                withAnimation {
                    isActivated.toggle()
                }
            }
            Slider(value: $newNumber, in: 10.0 ... Double(game.maxPrimaryStamina), step: 5.0) {
                Text(verbatim: "\(numberToSave)")
                    .foregroundColor(isNewThresholdValid ? .primary : .red)
            }
            .onChange(of: game) {
                newNumber = min(newNumber, Double(game.maxPrimaryStamina))
            }
            Button {
                if isNewThresholdValid {
                    withAnimation {
                        options.staminaAdditionalNotificationThresholds.append(
                            NotificationOptions.StaminaThreshold(game: game, threshold: numberToSave)
                        )
                        isActivated.toggle()
                    }
                } else {
                    withAnimation {
                        isNumberExistAlertVisible.toggle()
                    }
                }
            } label: {
                Text("sys.add".i18nBaseKit)
            }
        } else {
            Button {
                withAnimation {
                    isActivated.toggle()
                }
            } label: {
                Text("settings.notification.staminaThresholds.add.title", bundle: .module)
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var currentValues = thresholdsForCurrentGame
            currentValues.remove(atOffsets: offsets)
            options.staminaAdditionalNotificationThresholds.removeAll { $0.game == game }
            options.staminaAdditionalNotificationThresholds.append(contentsOf: {
                currentValues.map { NotificationOptions.StaminaThreshold(game: game, threshold: $0) }
            }())
            UserDefaults.baseSuite.synchronize()
            #if os(iOS) || targetEnvironment(macCatalyst)
            if thresholdsForCurrentGame.isEmpty {
                isEditMode = .inactive
            }
            #endif
        }
    }
}

// MARK: - NotificationSettingDetailContent

@available(iOS 17.0, macCatalyst 17.0, *)
private struct NotificationSettingDetailContent: View {
    // MARK: Public

    public var body: some View {
        perProfileSettingsSection()
        playerStaminaNotificationSection()
        expeditionNotificationSection()
        dailyTaskNotificationSection()
        giKatheryneRewardsNotificationSection()
        giRealmCurrencyNotificationSection()
        giParametricTransformerNotificationSection()
        giTrounceBlossomNotificationSection()
        hsrEchoOfWarNotificationSection()
        hsrSimulatedUniverseNotificationSection()
    }

    // MARK: Internal

    @Default(.notificationOptions) var options: NotificationOptions

    // MARK: Private

    @ViewBuilder private var macCatalystNoticeView: some View {
        #if targetEnvironment(macCatalyst)
        Text("settings.notification.dateTimePicker.macCatalystNotice", bundle: .module)
            .foregroundStyle(.orange)
        #else
        EmptyView()
        #endif
    }

    @ViewBuilder
    private func handleBindingDateAndWeekdays<T: View>(
        _ date: Binding<Date?>, _ weekday: Binding<Weekday?>,
        @ViewBuilder viewRenderer: (Binding<Date>, Binding<Weekday>) -> T
    )
        -> some View {
        if let bindingDate = Binding(date), let bindingWeekday = Binding(weekday) {
            viewRenderer(bindingDate, bindingWeekday)
        }
    }

    @ViewBuilder
    private func handleBindingDate<T: View>(
        _ date: Binding<Date?>,
        @ViewBuilder viewRenderer: (Binding<Date>) -> T
    )
        -> some View {
        if let bindingDate = Binding(date) {
            viewRenderer(bindingDate)
        }
    }

    @ViewBuilder
    private func perProfileSettingsSection() -> some View {
        // 分账号设定
        Section {
            NavigationLink(
                destination: ProfilesNotificationPermissionView()
            ) {
                Text(verbatim: ProfilesNotificationPermissionView.navTitle)
            }
        } header: {
            Text("settings.notification.faq.howNotificationsGetScheduled", bundle: .module)
                .textCase(.none)
                .padding([.bottom])
        } footer: {
            macCatalystNoticeView
        }
    }

    @ViewBuilder
    private func playerStaminaNotificationSection() -> some View {
        // 玩家体力通知提醒阈值
        Section {
            Toggle(isOn: $options.allowStaminaNotification.animation()) {
                Text("settings.notification.stamina.allow", bundle: .module)
            }
            NavigationLink {
                StaminaNotificationThresholdConfigView()
            } label: {
                Text(StaminaNotificationThresholdConfigView.navTitle)
            }
            .disabled(!options.allowStaminaNotification)
        } header: {
            Text("settings.notification.stamina.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.stamina.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func expeditionNotificationSection() -> some View {
        // 派遣委托
        Section {
            Toggle(isOn: $options.allowExpeditionNotification.animation()) {
                Text("settings.notification.expedition.allow", bundle: .module)
            }
            Picker(selection: $options.expeditionNotificationSetting) {
                let cases = NotificationOptions.ExpeditionNotificationSetting.allCases
                ForEach(cases, id: \.self) { setting in
                    Text(setting.description.i18nAK).tag(setting)
                }
            } label: {
                Text("settings.notification.expedition.method", bundle: .module)
            }
            .disabled(!options.allowExpeditionNotification)
        } header: {
            Text("settings.notification.expedition.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.expedition.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func dailyTaskNotificationSection() -> some View {
        // 每日任务
        Section {
            Toggle(isOn: options.allowDailyTaskNotification.animation()) {
                Text("settings.notification.dailyTask.toggle", bundle: .module)
            }
            handleBindingDate(options.dailyTaskNotificationTime) { bindingDate in
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.dailyTask.datePicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.dailyTask.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.dailyTask.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func giKatheryneRewardsNotificationSection() -> some View {
        // 凯瑟琳领奖
        Section {
            Toggle(isOn: options.allowGIKatheryneNotification.animation()) {
                Text("settings.notification.katheryneRewards.toggle", bundle: .module)
            }
            handleBindingDate(options.giKatheryneNotificationTime) { bindingDate in
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.katheryneRewards.datePicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.katheryneRewards.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.katheryneRewards.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func giRealmCurrencyNotificationSection() -> some View {
        // 洞天财甕
        Section {
            Toggle(isOn: $options.allowGIRealmCurrencyNotification.animation()) {
                Text("settings.notification.giRealmCurrency.allow", bundle: .module)
            }
        } header: {
            Text("settings.notification.giRealmCurrency.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.giRealmCurrency.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func giParametricTransformerNotificationSection() -> some View {
        // 参量质变仪
        Section {
            Toggle(isOn: $options.allowGITransformerNotification.animation()) {
                Text("settings.notification.giTransformer.allow", bundle: .module)
            }
        } header: {
            Text("settings.notification.giTransformer.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.giTransformer.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func giTrounceBlossomNotificationSection() -> some View {
        // 征讨之花
        Section {
            Toggle(isOn: options.allowGITrounceBlossomNotification.animation()) {
                Text("settings.notification.giTrounceBlossom.toggle", bundle: .module)
            }
            handleBindingDateAndWeekdays(
                options.giTrounceBlossomNotificationTime,
                options.giTrounceBlossomNotificationWeekday
            ) { bindingDate, bindingWeekday in
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.giTrounceBlossom.datePicker", bundle: .module)
                }
                Picker(selection: bindingWeekday) {
                    ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                        Text(weekday.description).tag(weekday)
                    }
                } label: {
                    Text("settings.notification.giTrounceBlossom.weekdayPicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.giTrounceBlossom.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.giTrounceBlossom.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func hsrEchoOfWarNotificationSection() -> some View {
        // 历战馀响
        Section {
            Toggle(isOn: options.allowHSREchoOfWarNotification.animation()) {
                Text("settings.notification.hsrEchoOfWar.toggle", bundle: .module)
            }
            handleBindingDateAndWeekdays(
                options.hsrEchoOfWarNotificationTime,
                options.hsrEchoOfWarNotificationWeekday
            ) { bindingDate, bindingWeekday in
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.hsrEchoOfWar.datePicker", bundle: .module)
                }
                Picker(selection: bindingWeekday) {
                    ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                        Text(weekday.description).tag(weekday)
                    }
                } label: {
                    Text("settings.notification.hsrEchoOfWar.weekdayPicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.hsrEchoOfWar.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.hsrEchoOfWar.footer", bundle: .module)
        }
    }

    @ViewBuilder
    private func hsrSimulatedUniverseNotificationSection() -> some View {
        // 模拟宇宙
        Section {
            Toggle(isOn: options.allowHSRSimulUnivNotification.animation()) {
                Text("settings.notification.hsrSimulatedUniverse.toggle", bundle: .module)
            }
            handleBindingDateAndWeekdays(
                options.hsrSimulUnivNotificationTime,
                options.hsrSimulUnivNotificationWeekday
            ) { bindingDate, bindingWeekday in
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.hsrSimulatedUniverse.datePicker", bundle: .module)
                }
                Picker(selection: bindingWeekday) {
                    ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                        Text(weekday.description).tag(weekday)
                    }
                } label: {
                    Text("settings.notification.hsrSimulatedUniverse.weekdayPicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.hsrSimulatedUniverse.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.hsrSimulatedUniverse.footer", bundle: .module)
        }
    }
}
