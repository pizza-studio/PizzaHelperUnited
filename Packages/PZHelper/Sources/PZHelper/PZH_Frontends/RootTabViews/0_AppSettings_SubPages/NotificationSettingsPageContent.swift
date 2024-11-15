// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI
import UserNotifications

// MARK: - NotificationSettingsPageContent

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
                        Link(destination: "x-apple.systempreferences:com.apple.preference.notifications".asURL) {
                            osSettingsLinkLabel
                        }
                        #else
                        Link(destination: UIApplication.openSettingsURLString.asURL) {
                            osSettingsLinkLabel
                        }
                        #endif
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
                ForEach(pzProfiles) { profile in
                    Toggle(
                        isOn: allowNotificationBinding(for: profile).animation()
                    ) {
                        Self.drawLocalProfile(profile, isChosen: profile.allowNotification)
                    }
                }
            } footer: {
                Text("settings.notification.profilesReceivingNotifications.description", bundle: .module)
            }
        }
        .formStyle(.grouped)
        .navBarTitleDisplayMode(.large)
        .navigationTitle(Self.navTitleShortened)
    }

    // MARK: Private

    @Query(sort: \PZProfileMO.priority) private var pzProfiles: [PZProfileMO]
    @Environment(\.modelContext) private var modelContext

    @ViewBuilder
    private static func drawLocalProfile(
        _ profile: PZProfileMO,
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

    private func allowNotificationBinding(for profile: PZProfileMO) -> Binding<Bool> {
        .init {
            profile.allowNotification
        } set: { newValue in
            profile.allowNotification = newValue
            try? modelContext.save()
            PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
            Defaults[.pzProfiles][profile.uuid.uuidString] = profile.asSendable
            UserDefaults.profileSuite.synchronize()
        }
    }
}

// MARK: - StaminaNotificationThresholdConfigView

private struct StaminaNotificationThresholdConfigView: View {
    // MARK: Public

    public static let navTitle: String = .init(
        localized: "settings.notification.staminaThresholds.navTitle", bundle: .module
    )

    // MARK: Internal

    var body: some View {
        List {
            Section {
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
                    Slider(value: $newNumber, in: 10.0 ... 240.0, step: 5.0) {
                        Text(verbatim: "\(numberToSave)")
                            .foregroundColor(isNewThresholdValid ? .primary : .red)
                    }
                    Button {
                        if isNewThresholdValid {
                            withAnimation {
                                options.staminaAdditionalNotificationThresholds.append(numberToSave)
                            }
                        } else {
                            isNumberExistAlertVisible.toggle()
                        }
                    } label: {
                        Text("sys.save".i18nBaseKit)
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
            .alert(
                "settings.notification.staminaThresholds.valueAlreadyExist",
                isPresented: $isNumberExistAlertVisible
            ) {
                Button("sys.ok".i18nBaseKit) {
                    isNumberExistAlertVisible.toggle()
                }
            }
            Section {
                ForEach(options.staminaAdditionalNotificationThresholds.sorted(by: <), id: \.self) { number in
                    Text(verbatim: "\(number)")
                }
                .onDelete(perform: deleteItems)
            } header: {
                Text("settings.notification.staminaThresholds.header", bundle: .module).textCase(.none)
                    .textCase(.none)
            } footer: {
                Text("settings.notification.staminaThresholds.footer", bundle: .module)
                    .textCase(.none)
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
    @Default(.notificationOptions) private var options: NotificationOptions

    private var isNewThresholdValid: Bool { !options.staminaAdditionalNotificationThresholds.contains(numberToSave) }
    private var numberToSave: Int { Int(newNumber) }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            options.staminaAdditionalNotificationThresholds.remove(atOffsets: offsets)
        }
    }
}

// MARK: - NotificationSettingDetailContent

private struct NotificationSettingDetailContent: View {
    // MARK: Public

    public var body: some View {
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
            #if targetEnvironment(macCatalyst)
            Text("settings.notification.dateTimePicker.macCatalystNotice", bundle: .module)
                .foregroundStyle(.orange)
            #endif
        }

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

        // 每日任务
        Section {
            Toggle(isOn: options.allowDailyTaskNotification.animation()) {
                Text("settings.notification.dailyTask.toggle", bundle: .module)
            }
            if let bindingDate = Binding(
                options.dailyTaskNotificationTime
            ) {
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.dailyTask.datePicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.dailyTask.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.dailyTask.footer", bundle: .module)
        }

        // 凯瑟琳领奖
        Section {
            Toggle(isOn: options.allowGIKatheryneNotification.animation()) {
                Text("settings.notification.katheryneRewards.toggle", bundle: .module)
            }
            if let bindingDate = Binding(
                options.giKatheryneNotificationTime
            ) {
                DatePicker(selection: bindingDate, displayedComponents: .hourAndMinute) {
                    Text("settings.notification.katheryneRewards.datePicker", bundle: .module)
                }
            }
        } header: {
            Text("settings.notification.katheryneRewards.header", bundle: .module).textCase(.none)
        } footer: {
            Text("settings.notification.katheryneRewards.footer", bundle: .module)
        }

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

        // 征讨之花
        Section {
            Toggle(isOn: options.allowGITrounceBlossomNotification.animation()) {
                Text("settings.notification.giTrounceBlossom.toggle", bundle: .module)
            }
            if let bindingDate = Binding(options.giTrounceBlossomNotificationTime),
               let bindingWeekday = Binding(options.giTrounceBlossomNotificationWeekday) {
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

        // 模拟宇宙
        Section {
            Toggle(isOn: options.allowHSRSimulUnivNotification.animation()) {
                Text("settings.notification.hsrSimulatedUniverse.toggle", bundle: .module)
            }
            if let bindingDate = Binding(options.hsrSimulUnivNotificationTime),
               let bindingWeekday = Binding(options.hsrSimulUnivNotificationWeekday) {
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

    // MARK: Internal

    @Default(.notificationOptions) var options: NotificationOptions
}
