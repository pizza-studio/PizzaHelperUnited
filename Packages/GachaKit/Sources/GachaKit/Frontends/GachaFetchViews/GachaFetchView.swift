// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Charts
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaFetchView

public struct GachaFetchView: View {
    // MARK: Lifecycle

    public init(for game: Pizza.SupportedGame) {
        self.game = game
    }

    // MARK: Public

    public static let navTitle = "gachaKit.getRecord.title".i18nGachaKit

    @MainActor public var body: some View {
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

    private let game: Pizza.SupportedGame
    @Environment(GachaVM.self) private var gachaRootVM
}

// MARK: - GachaFetchView4Game

private struct GachaFetchView4Game<GachaType: GachaTypeProtocol>: View {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    typealias VMType = GachaFetchVM<GachaType>

    @MainActor var body: some View {
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
                case let .finished(typeFetchedCount: typeFetchedCount, initialize: initialize):
                    FinishedView(typeFetchedCount: typeFetchedCount, reinit: initialize)
                        .onAppear {
                            gachaRootVM.updateMappedEntriesByPools()
                        }
                }

                switch gachaVM4Fetch.status {
                case .failFetching, .finished, .got:
                    Section {
                        GetGachaChart(data: $gachaVM4Fetch.gachaTypeDateCounts)
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
                        Text("gachaKit.getRecord.running".i18nGachaKit)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(GachaFetchView.navTitle)
            .navBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(gachaVM4Fetch.status.isBusy)
        }
    }

    // MARK: Private

    @State private var gachaVM4Fetch: VMType = .init()
    @Environment(GachaVM.self) private var gachaRootVM
}

// MARK: GachaFetchView4Game.WaitingForURLView

extension GachaFetchView4Game {
    private struct WaitingForURLView: View {
        // MARK: Lifecycle

        init(completion: @escaping (String) throws -> Void) {
            self.completion = completion
        }

        // MARK: Internal

        @MainActor var body: some View {
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
                }
                genshinPZProfileList
            }
            .onAppear {
                refreshPZProfilesInThisView()
            }
        }

        // MARK: Private

        @Observable
        private class URLAwaitVM: TaskManagedVM {}

        private let completion: (String) throws -> Void
        @State private var pzProfiles: [PZProfileSendable] = []
        @State private var error: ParseGachaURLError?
        @State private var subError: Error?
        @State private var isErrorAlertVisible: Bool = false
        @State private var urlAwaitVM = URLAwaitVM()

        @MainActor @ViewBuilder private var genshinPZProfileList: some View {
            if GachaType.game == .genshinImpact, !pzProfiles.isEmpty {
                Section {
                    ForEach(pzProfiles, id: \.uid) { pzProfile in
                        Button {
                            urlAwaitVM.fireTask(
                                givenTask: {
                                    try await HoYo.generateGIGachaURLByMiyousheAPI(pzProfile)
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
                    Text("gachaKit.getRecord.quickFetch4GenshinMiyousheUIDs".i18nGachaKit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textCase(.none)
                }
            }
        }

        private func refreshPZProfilesInThisView() {
            let context = PZProfileActor.shared.modelContainer.mainContext
            let fetched = try? context.fetch(FetchDescriptor<PZProfileMO>())
            pzProfiles = (fetched ?? []).map(\.asSendable).filter { pzProfile in
                guard pzProfile.game == .genshinImpact else { return false }
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

extension GachaFetchView4Game {
    private struct ReadyToFireView: View {
        // MARK: Lifecycle

        init(start: @escaping () -> Void, reinit: @escaping () -> Void) {
            self.start = start
            self.reinit = reinit
        }

        // MARK: Internal

        @MainActor var body: some View {
            Section {
                Button {
                    start()
                } label: {
                    Label("gachaKit.getRecord.readyStart.start".i18nGachaKit, systemSymbol: .playCircle)
                }
                @Bindable var gachaFetchVM = gachaFetchVM
                Toggle(isOn: $gachaFetchVM.isForceOverrideModeEnabled) {
                    Label(
                        "gachaKit.getRecord.readyStart.forceOverride".i18nGachaKit,
                        systemSymbol: .arrowshapeBounceRight
                    )
                }
                if let urlStr = gachaFetchVM.client?.urlString {
                    Button {
                        Clipboard.currentString = urlStr
                    } label: {
                        Label("gachaKit.getRecord.readyStart.copyThisURL".i18nGachaKit, systemSymbol: .docOnClipboard)
                    }
                }
            }
            Section {
                Button {
                    reinit()
                } label: {
                    Label("gachaKit.getRecord.readyStart.reinit".i18nGachaKit, systemSymbol: .arrowClockwiseCircle)
                }
            }
        }

        // MARK: Private

        private let start: () -> Void
        private let reinit: () -> Void
        @Environment(VMType.self) private var gachaFetchVM
    }
}

// MARK: GachaFetchView4Game.InProgressView

extension GachaFetchView4Game {
    private struct InProgressView: View {
        // MARK: Lifecycle

        init(cancel: @escaping () -> Void) {
            self.cancel = cancel
        }

        // MARK: Internal

        @MainActor var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.inProgress.obtaining".i18nGachaKit)
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

        @MainActor var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.gotSome.obtaining".i18nGachaKit)
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
                    Text(verbatim: GachaPoolExpressible.getPoolFilterLabel(by: GachaType.game) + ":")
                    Text(verbatim: poolType.localizedTitle + " (\(gachaType.rawValue))")
                    Spacer()
                    Text(String(format: "gachaKit.getRecord.gotSome.page".i18nGachaKit, page))
                    Spacer()
                    Text(String(format: "gachaKit.getRecord.gotSome.gotNewRecords".i18nGachaKit, newItemCount))
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

        @MainActor var body: some View {
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

extension GachaFetchView4Game {
    private struct FinishedView: View {
        // MARK: Lifecycle

        init(typeFetchedCount: [GachaType: Int], reinit: @escaping () -> Void) {
            self.typeFetchedCount = typeFetchedCount
            self.reinit = reinit
        }

        // MARK: Internal

        @MainActor var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.finished.succeeded".i18nGachaKit)
                } icon: {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                }
                Button {
                    reinit()
                } label: {
                    Label("gachaKit.getRecord.finished.initialize".i18nGachaKit, systemSymbol: .arrowClockwiseCircle)
                }
            }

            Section {
                let sortedTypeFechedCount = typeFetchedCount.sorted {
                    $0.key.expressible.rawValue < $1.key.expressible.rawValue
                }
                ForEach(sortedTypeFechedCount, id: \.key) { currentPoolType, currentPoolCount in
                    LabeledContent {
                        Text(verbatim: currentPoolCount.description)
                    } label: {
                        Text(verbatim: currentPoolType.description)
                    }
                }
            }
        }

        // MARK: Private

        private let typeFetchedCount: [GachaType: Int]
        private let reinit: () -> Void

        private var newRecordCount: String {
            let sortedTypeFechedCount = typeFetchedCount.sorted { $0.key.rawValue < $1.key.rawValue }
            return sortedTypeFechedCount.map { gachaType, count in
                "\(gachaType.description) - \(count); "
            }.reduce("", +)
        }
    }
}

// MARK: GachaFetchView4Game.GetGachaChart

extension GachaFetchView4Game {
    private struct GetGachaChart: View {
        // MARK: Internal

        @Binding var data: [VMType.GachaTypeDateCount]

        @MainActor var body: some View {
            let sorted = data.sorted {
                $0.date < $1.date
            }
            Chart(sorted) {
                LineMark(
                    x: .value("gachaKit.getRecord.chart.date".i18nGachaKit, $0.date),
                    y: .value("gachaKit.getRecord.chart.count".i18nGachaKit, $0.count)
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
