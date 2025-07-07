// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import Charts
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - GachaFetchView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaFetchView: View {
    // MARK: Lifecycle

    public init(for game: Pizza.SupportedGame) {
        self.game = game
    }

    // MARK: Public

    public static let navTitle = "gachaKit.getRecord.title".i18nGachaKit

    public var body: some View {
        Group {
            switch game {
            case .genshinImpact: GachaFetchView4Game<GachaTypeGI>()
            case .starRail: GachaFetchView4Game<GachaTypeHSR>()
            case .zenlessZone: GachaFetchView4Game<GachaTypeZZZ>()
            }
        }
        .environment(gachaRootVM)
    }

    // MARK: Private

    @Environment(GachaVM.self) private var gachaRootVM

    private let game: Pizza.SupportedGame
}

// MARK: - GachaFetchView4Game

@available(iOS 17.0, macCatalyst 17.0, *)
private struct GachaFetchView4Game<GachaType: GachaTypeProtocol>: View {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    typealias VMType = GachaFetchVM<GachaType>

    var body: some View {
        NavigationStack {
            Form {
                switch gachaVM4Fetch.status {
                case .waitingForURL:
                    WaitingForURLView { urlString in
                        try gachaVM4Fetch.load(urlString: urlString)
                    }
                case let .readyToFire(start: start, reinit: initialize):
                    ReadyToFireView(start: start, reinit: initialize)
                        .environment(gachaVM4Fetch)
                case let .inProgress(cancel: cancel):
                    InProgressView(cancel: cancel)
                case let .got(page: page, gachaType: gachaType, newItemCount: newItemCount, cancel: cancel):
                    GotSomeItemView(page: page, gachaType: gachaType, newItemCount: newItemCount, cancel: cancel)
                case let .failFetching(page: page, gachaType: gachaType, error: error, retry: retry):
                    FailFetchingView(page: page, gachaType: gachaType, error: error, retry: retry)
                        .onAppear {
                            gachaRootVM.updateMappedEntriesByPools()
                        }
                case let .finished(
                    typeFetchedCount: typeFetchedCount,
                    dataBleachedCount: dataBleachedCount,
                    initialize: initialize
                ):
                    FinishedView(
                        typeFetchedCount: typeFetchedCount,
                        dataBleachedCount: dataBleachedCount,
                        chosenPools: gachaVM4Fetch.chosenPools,
                        reinit: initialize
                    )
                    .onAppear {
                        gachaRootVM.updateMappedEntriesByPools()
                    }
                }

                switch gachaVM4Fetch.status {
                case .failFetching, .finished, .got:
                    Section {
                        GetGachaChart(data: $gachaVM4Fetch.gachaTypeDateCounts)
                    } header: {
                        HStack {
                            (Text("gachaKit.getRecord.fetchRange.title", bundle: .module) + Text(verbatim: ":"))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text(verbatim: gachaVM4Fetch.fetchRange.localizedLabel)
                                .multilineTextAlignment(.leading)
                        }
                        .textCase(.none)
                    }
                default:
                    EmptyView()
                }

                if !gachaVM4Fetch.cachedItems.isEmpty {
                    Section {
                        ForEach(gachaVM4Fetch.cachedItems.reversed(), id: \.id) { item in
                            GachaEntryBar(entry: item.expressible, showDate: true, debug: true)
                                .disabled(true)
                        }
                    } header: {
                        Text("gachaKit.getRecord.running", bundle: .module)
                            .textCase(.none)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(GachaFetchView.navTitle)
            .navBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(gachaVM4Fetch.status.isBusy)
        }
        .apply { mainContent in
            @Bindable var theVM = gachaVM4Fetch
            mainContent
                .toast(isPresenting: $theVM.showSucceededAlertToast) {
                    AlertToast(
                        displayMode: .alert,
                        type: .complete(.green),
                        title: "gachaKit.alertToast.succeeded".i18nGachaKit
                    )
                }
        }
    }

    // MARK: Private

    @State private var gachaVM4Fetch: VMType = .init()
    @Environment(GachaVM.self) private var gachaRootVM
}

// MARK: GachaFetchView4Game.WaitingForURLView

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct WaitingForURLView: View {
        // MARK: Lifecycle

        init(completion: @escaping (String) throws -> Void) {
            self.completion = completion
        }

        // MARK: Internal

        var body: some View {
            Group {
                Section {
                    let alertIntelPack = packAlertIntel()
                    Button {
                        handleURLString(Clipboard.currentString)
                    } label: {
                        Label("gachaKit.getRecord.waitingURL.readClipboard".i18nGachaKit, systemSymbol: .docOnClipboard)
                    }
                    .alert(alertIntelPack.title, isPresented: $isErrorAlertVisible) {
                        Button("sys.ok".i18nBaseKit) {
                            subError = nil
                            error = nil
                        }
                    } message: {
                        Text(verbatim: alertIntelPack.message)
                    }
                } header: {
                    Text(GachaType.game.titleMarkedName).textCase(.none)
                } footer: {
                    let textView = Text("gachaKit.getRecord.waitingURL.footer".i18nGachaKit)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let destinationView = GachaRootView.getFAQView?() {
                        NavigationLink(destination: destinationView) { textView }
                    } else {
                        textView
                    }
                }
                gachaURLDeductableProfilesListView()
            }
            .onAppear {
                refreshPZProfilesInThisView()
            }
        }

        // MARK: Private

        @Observable
        @available(iOS 17.0, macCatalyst 17.0, *)
        private class URLAwaitVM: TaskManagedVM {}

        @State private var pzProfiles: [PZProfileSendable] = []
        @State private var error: ParseGachaURLError?
        @State private var subError: Error?
        @State private var isErrorAlertVisible: Bool = false
        @State private var urlAwaitVM = URLAwaitVM()

        private let completion: (String) throws -> Void

        @ViewBuilder
        private func gachaURLDeductableProfilesListView() -> some View {
            if !pzProfiles.isEmpty {
                Section {
                    ForEach(pzProfiles, id: \.uid) { pzProfile in
                        Button {
                            urlAwaitVM.fireTask(
                                givenTask: {
                                    try await HoYo.generateGachaURL(pzProfile)
                                },
                                completionHandler: { urlStr in
                                    if let urlStr {
                                        handleURLString(urlStr)
                                    }
                                },
                                errorHandler: { thrownException in
                                    subError = thrownException
                                    error = .urlGenerationFailure
                                    isErrorAlertVisible.toggle()
                                }
                            )
                        } label: {
                            LabeledContent {
                                Image(systemSymbol: .trayAndArrowDownFill)
                                    .foregroundStyle(Color.accentColor)
                            } label: {
                                GachaExchangeView.drawGPID(
                                    GachaProfileID(
                                        uid: pzProfile.uid,
                                        game: pzProfile.game,
                                        profileName: pzProfile.name
                                    ),
                                    nameIDMap: [:]
                                )
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                } header: {
                    Text("gachaKit.getRecord.quickFetch", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textCase(.none)
                }
            }
        }

        private func refreshPZProfilesInThisView() {
            #if !DEBUG
            // 星穹鐵道的 GachaURL 生成機制仍舊有 AuthKey 的問題需要解決，暫時在正式版與 TF 版內停用。
            guard GachaType.game != .starRail else {
                pzProfiles = []
                return
            }
            #endif
            let fetchedItems = GachaVM.shared.allPZProfiles
            pzProfiles = fetchedItems.filter { pzProfile in
                guard pzProfile.game == GachaType.game else { return false }
                switch pzProfile.server.region {
                case .miyoushe: return true
                default: return false
                }
            }.sorted { $0.uid < $1.uid }
        }

        private func handleURLString(_ urlString: String) {
            do {
                try completion(urlString)
            } catch let error as ParseGachaURLError {
                self.error = error
                self.isErrorAlertVisible.toggle()
            } catch {
                fatalError()
            }
        }

        private func packAlertIntel() -> (title: String, message: String) {
            let alertTitle = error?.localizedDescription ?? ""
            var alertSubTitle = ""
            if let error {
                alertSubTitle += "\(error)"
            }
            if let subError {
                alertSubTitle += "\n\n\(subError)"
            }
            return (alertTitle, alertSubTitle)
        }
    }
}

// MARK: GachaFetchView4Game.ReadyToFireView

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct ReadyToFireView: View {
        // MARK: Lifecycle

        init(start: @escaping () -> Void, reinit: @escaping () -> Void) {
            self.start = start
            self.reinit = reinit
        }

        // MARK: Internal

        var body: some View {
            Section {
                Button {
                    start()
                } label: {
                    Label("gachaKit.getRecord.readyStart.start".i18nGachaKit, systemSymbol: .playCircle)
                }
                .disabled(gachaFetchVM.chosenPools.isEmpty)
                @Bindable var gachaFetchVM = gachaFetchVM
                Label {
                    Picker(selection: $gachaFetchVM.fetchRange) {
                        ForEach(GachaFetchRange.allCases, id: \.self) { rangeCase in
                            Text(rangeCase.localizedLabel).tag(rangeCase)
                        }
                    } label: {
                        Text("gachaKit.getRecord.fetchRange.title", bundle: .module)
                    }
                } icon: {
                    Image(systemSymbol: .chartBarXaxisAscendingBadgeClock)
                }
                Toggle(isOn: $gachaFetchVM.isForceOverrideModeEnabled) {
                    Label(
                        "gachaKit.getRecord.readyStart.forceOverride".i18nGachaKit,
                        systemSymbol: .arrowshapeBounceRight
                    )
                }
                Toggle(isOn: $gachaFetchVM.isBleachingModeEnabled) {
                    Label(
                        "gachaKit.getRecord.readyStart.enableBleachingMode".i18nGachaKit,
                        systemSymbol: .paintbrush
                    )
                }
            } header: {
                Text("gachaKit.getRecord.readyStart.sectionHeader.urgeUsersToBackupFirst", bundle: .module)
                    .multilineTextAlignment(.leading)
                    .textCase(.none)
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } footer: {
                drawAlertRegardingTrashDataIncidents()
            }

            GachaPoolTypePickerSection()

            Section {
                if let urlStr = gachaFetchVM.client?.urlString {
                    Button {
                        Clipboard.currentString = urlStr
                        gachaFetchVM.showSucceededAlertToast = true
                    } label: {
                        Label("gachaKit.getRecord.readyStart.copyThisURL".i18nGachaKit, systemSymbol: .docOnClipboard)
                    }
                }
                Button {
                    reinit()
                } label: {
                    Label("gachaKit.getRecord.readyStart.reinit".i18nGachaKit, systemSymbol: .arrowClockwiseCircle)
                }
            }
        }

        @ViewBuilder
        func drawAlertRegardingTrashDataIncidents() -> some View {
            Button {
                isAlertShownRegardingTrashDataIncidents = true
            } label: {
                Group {
                    Text(verbatim: "⚠️ ") + Text(
                        "gachaKit.getRecord.readyStart.sectionFooter.regardingTrashDataIncidents.linkTitle",
                        bundle: .module
                    )
                    .bold()
                }
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .alert(
                "gachaKit.getRecord.readyStart.sectionFooter.regardingTrashDataIncidents.linkTitle".i18nGachaKit,
                isPresented: $isAlertShownRegardingTrashDataIncidents
            ) {
                Button("sys.ok".i18nBaseKit) {
                    isAlertShownRegardingTrashDataIncidents = false
                }
            } message: {
                Text(
                    "gachaKit.getRecord.readyStart.sectionFooter.regardingTrashDataIncidents",
                    bundle: .module
                )
            }
        }

        // MARK: Private

        @Environment(VMType.self) private var gachaFetchVM
        @State private var isAlertShownRegardingTrashDataIncidents: Bool = false

        private let start: () -> Void
        private let reinit: () -> Void
    }
}

// MARK: GachaFetchView4Game.GachaPoolTypePickerSection

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct GachaPoolTypePickerSection: View {
        // MARK: Public

        public var body: some View {
            Section {
                // 合并显示原神的两个限定活动卡池。
                let pools = GachaType.knownCases.filter {
                    ($0 as? GachaTypeGI) != GachaTypeGI.characterEventWish2
                }
                ForEach(pools) { poolType in
                    Toggle(
                        isOn: toggleBinding(for: poolType).animation()
                    ) {
                        Text(verbatim: poolType.expressible.localizedTitle).tag(poolType)
                    }
                }
            } header: {
                Text(verbatim: GachaPoolExpressible.getPoolFilterLabel(by: GachaType.game))
            }
        }

        // MARK: Private

        @Environment(VMType.self) private var gachaFetchVM

        private func toggleBinding(for gachaType: GachaType) -> Binding<Bool> {
            .init {
                !gachaFetchVM.chosenPools.isEmpty && gachaFetchVM.chosenPools.contains(gachaType)
            } set: { newValue in
                var gachaTypes = [gachaType]
                switch gachaType {
                case let gachaType as GachaTypeGI where gachaType.uigfGachaType == .characterEventWish:
                    let eventWishes: [GachaTypeGI] = [.characterEventWish1, .characterEventWish2]
                    gachaTypes = eventWishes.compactMap { $0 as? GachaType }
                default: break
                }
                switch newValue {
                case true:
                    gachaTypes.forEach { gachaFetchVM.chosenPools.insert($0) }
                case false:
                    gachaTypes.forEach { gachaFetchVM.chosenPools.remove($0) }
                }
            }
        }
    }
}

// MARK: GachaFetchView4Game.InProgressView

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct InProgressView: View {
        // MARK: Lifecycle

        init(cancel: @escaping () -> Void) {
            self.cancel = cancel
        }

        // MARK: Internal

        var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.inProgress.obtaining", bundle: .module)
                } icon: {
                    ProgressView().id(UUID())
                }
                Button {
                    cancel()
                } label: {
                    Label("gachaKit.getRecord.inProgress.cancel".i18nGachaKit, systemSymbol: .stopCircle)
                }
            }
        }

        // MARK: Private

        private let cancel: () -> Void
    }
}

// MARK: GachaFetchView4Game.GotSomeItemView

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct GotSomeItemView: View {
        // MARK: Lifecycle

        init(page: Int, gachaType: GachaType, newItemCount: Int, cancel: @escaping () -> Void) {
            self.page = page
            self.gachaType = gachaType
            self.poolType = gachaType.expressible
            self.newItemCount = newItemCount
            self.cancel = cancel
        }

        // MARK: Internal

        var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.gotSome.obtaining", bundle: .module)
                } icon: {
                    ProgressView().id(UUID())
                }
                Button {
                    cancel()
                } label: {
                    Label("sys.cancel".i18nBaseKit, systemSymbol: .stopCircle)
                }
            } footer: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(verbatim: GachaPoolExpressible.getPoolFilterLabel(by: GachaType.game) + ":")
                            .multilineTextAlignment(.leading)
                        Text(verbatim: poolType.localizedTitle + " (\(gachaType.rawValue))")
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(String(format: "gachaKit.getRecord.gotSome.page".i18nGachaKit, page))
                            .multilineTextAlignment(.trailing)
                        Text(String(format: "gachaKit.getRecord.gotSome.gotNewRecords".i18nGachaKit, newItemCount))
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }

        // MARK: Private

        private let page: Int
        private let gachaType: GachaType
        private let poolType: GachaPoolExpressible
        private let newItemCount: Int
        private let cancel: () -> Void
    }
}

// MARK: GachaFetchView4Game.FailFetchingView

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct FailFetchingView: View {
        // MARK: Lifecycle

        init(page: Int, gachaType: GachaType, error: Error, retry: @escaping () -> Void) {
            self.page = page
            self.gachaType = gachaType
            self.error = error
            self.retry = retry
        }

        // MARK: Internal

        var body: some View {
            Label {
                Text(verbatim: "\(error)")
            } icon: {
                Image(systemSymbol: .exclamationmarkCircle)
                    .foregroundColor(.red)
            }
            Button {
                retry()
            } label: {
                Label("gachaKit.getRecord.failFetch.retry".i18nGachaKit, systemSymbol: .arrowClockwiseCircle)
            }
        }

        // MARK: Private

        private let page: Int
        private let gachaType: GachaType
        private let error: Error
        private let retry: () -> Void
    }
}

// MARK: GachaFetchView4Game.FinishedView

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct FinishedView: View {
        // MARK: Lifecycle

        init(
            typeFetchedCount: [GachaType: Int],
            dataBleachedCount: Int,
            chosenPools: Set<GachaType>,
            reinit: @escaping () -> Void
        ) {
            self.typeFetchedCount = typeFetchedCount
            self.dataBleachedCount = dataBleachedCount
            self.chosenPools = chosenPools
            self.reinit = reinit
        }

        // MARK: Internal

        var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.finished.succeeded", bundle: .module)
                } icon: {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                }
                Button {
                    reinit()
                } label: {
                    Label("gachaKit.getRecord.finished.initialize".i18nGachaKit, systemSymbol: .arrowClockwiseCircle)
                }
            } footer: {
                dataBleachedReportView
            }

            Section {
                let sortedTypeFechedCount = typeFetchedCount.sorted {
                    $0.key.expressible.rawValue < $1.key.expressible.rawValue
                }
                ForEach(sortedTypeFechedCount, id: \.key) { currentPoolType, currentPoolCount in
                    if !chosenPools.isEmpty, chosenPools.contains(currentPoolType) {
                        LabeledContent {
                            Text(verbatim: currentPoolCount.description).fontWidth(.condensed)
                        } label: {
                            Text(verbatim: currentPoolType.description).fontWidth(.condensed)
                        }
                    }
                }
            }
        }

        // MARK: Private

        private let typeFetchedCount: [GachaType: Int]
        private let dataBleachedCount: Int
        private let chosenPools: Set<GachaType>
        private let reinit: () -> Void

        private var newRecordCount: String {
            let sortedTypeFechedCount = typeFetchedCount.sorted { $0.key.rawValue < $1.key.rawValue }
            return sortedTypeFechedCount.map { gachaType, count in
                "\(gachaType.description) - \(count); "
            }.reduce("", +)
        }

        @ViewBuilder private var dataBleachedReportView: some View {
            if dataBleachedCount > 0 {
                HStack {
                    Text("gachaKit.getRecord.finished.footer.bleachedInvalidEntriesCount", bundle: .module)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(verbatim: dataBleachedCount.description)
                }
            } else {
                Text("gachaKit.getRecord.finished.footer.nothingToBleach", bundle: .module)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: GachaFetchView4Game.GetGachaChart

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaFetchView4Game {
    private struct GetGachaChart: View {
        // MARK: Internal

        @Binding var data: [VMType.GachaTypeDateCount]

        var body: some View {
            let sorted = data.sorted {
                $0.date < $1.date
            }
            Chart(sorted) {
                LineMark(
                    x: .value("gachaKit.getRecord.chart.date".i18nGachaKit, $0.date),
                    y: .value("gachaKit.getRecord.chart.count".i18nGachaKit, $0.countAsMergedPool)
                )
                .foregroundStyle(
                    by: .value(
                        GachaPoolExpressible.getPoolFilterLabel(by: $0.gachaType.game),
                        $0.gachaType.expressible.localizedTitle
                    )
                )
            }
            .chartForegroundStyleScale(colorMap)
            .padding(.top)
            // NOTE: 上文 `chartForegroundStyleScale` 能接收的 KeyValuePairs 无法动态合成。
        }

        // MARK: Private

        private var colorMap: KeyValuePairs<String, Color> {
            switch GachaType.game {
            case .genshinImpact: [
                    GachaPoolExpressible.giCharacterEventWish.localizedTitle: .blue,
                    GachaPoolExpressible.giWeaponEventWish.localizedTitle: .yellow,
                    GachaPoolExpressible.giChronicledWish.localizedTitle: .red,
                    GachaPoolExpressible.giStandardWish.localizedTitle: .green,
                    GachaPoolExpressible.giBeginnersWish.localizedTitle: .cyan,
                ]
            case .starRail: [
                    GachaPoolExpressible.srCharacterEventWarp.localizedTitle: .blue,
                    GachaPoolExpressible.srLightConeEventWarp.localizedTitle: .yellow,
                    GachaPoolExpressible.srStellarWarp.localizedTitle: .green,
                    GachaPoolExpressible.srDepartureWarp.localizedTitle: .cyan,
                ]
            case .zenlessZone: [
                    GachaPoolExpressible.zzExclusiveChannel.localizedTitle: .blue,
                    GachaPoolExpressible.zzWEngineChannel.localizedTitle: .yellow,
                    GachaPoolExpressible.zzBangbooChannel.localizedTitle: .red,
                    GachaPoolExpressible.zzStableChannel.localizedTitle: .green,
                ]
            }
        }
    }
}
