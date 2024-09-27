// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Charts
import PZBaseKit
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

    // MARK: Fileprivate

    fileprivate let game: Pizza.SupportedGame
    @Environment(GachaVM.self) fileprivate var gachaRootVM
}

// MARK: - GachaFetchView4Game

private struct GachaFetchView4Game<GachaType: GachaTypeProtocol>: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public typealias VMType = GachaFetchVM<GachaType>

    @MainActor public var body: some View {
        NavigationStack {
            Form {
                switch gachaVM4Fetch.status {
                case .waitingForURL:
                    WaitingForURLView { urlString in
                        gachaVM4Fetch.load(urlString: urlString)
                    }
                case let .readyToFire(start: start, reinit: initialize):
                    WaitingForStartView(start: start, fireTask: initialize)
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
                    FinishedView(typeFetchedCount: typeFetchedCount, fireTask: initialize)
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

    // MARK: Fileprivate

    @State fileprivate var gachaVM4Fetch: VMType = .init()
    @Environment(GachaVM.self) fileprivate var gachaRootVM
}

// MARK: GachaFetchView4Game.WaitingForURLView

extension GachaFetchView4Game {
    fileprivate struct WaitingForURLView: View {
        // MARK: Lifecycle

        public init(completion: @escaping (String) -> Void) {
            self.completion = completion
        }

        // MARK: Public

        @MainActor public var body: some View {
            Section {
                Button {
                    let urlString = Clipboard.currentString
                    if urlString.hasPrefix("https://"), urlString.contains("api/getGachaLog") {
                        do {
                            try completion(urlString)
                        } catch let error as ParseGachaURLError {
                            self.error = error
                            self.isErrorAlertVisible.toggle()
                        } catch {
                            fatalError()
                        }
                    } else {
                        isPasteBoardNoDataAlertVisible.toggle()
                    }
                } label: {
                    Label("gachaKit.getRecord.waitingURL.readClipboard".i18nGachaKit, systemSymbol: .docOnClipboard)
                }
                .alert(isPresented: $isErrorAlertVisible, error: error) {
                    Button("sys.ok") {
                        isErrorAlertVisible.toggle()
                    }
                }
            } header: {
                Text(GachaType.game.titleMarkedName).textCase(.none)
            }
        }

        // MARK: Fileprivate

        fileprivate let completion: (String) throws -> Void
        @State fileprivate var error: ParseGachaURLError?
        @State fileprivate var isErrorAlertVisible: Bool = false
        @State fileprivate var isPasteBoardNoDataAlertVisible: Bool = false
    }
}

// MARK: GachaFetchView4Game.WaitingForStartView

extension GachaFetchView4Game {
    fileprivate struct WaitingForStartView: View {
        // MARK: Lifecycle

        public init(start: @escaping () -> Void, fireTask: @escaping () -> Void) {
            self.start = start
            self.fireTask = fireTask
        }

        // MARK: Public

        @MainActor public var body: some View {
            Button {
                start()
            } label: {
                Label("gachaKit.getRecord.readyStart.start".i18nGachaKit, systemSymbol: .playCircle)
            }
            Button {
                fireTask()
            } label: {
                Label("gachaKit.getRecord.readyStart.fire".i18nGachaKit, systemSymbol: .arrowClockwiseCircle)
            }
        }

        // MARK: Fileprivate

        fileprivate let start: () -> Void
        fileprivate let fireTask: () -> Void
    }
}

// MARK: GachaFetchView4Game.InProgressView

extension GachaFetchView4Game {
    fileprivate struct InProgressView: View {
        // MARK: Lifecycle

        public init(cancel: @escaping () -> Void) {
            self.cancel = cancel
        }

        // MARK: Public

        @MainActor public var body: some View {
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

        // MARK: Fileprivate

        fileprivate let cancel: () -> Void
    }
}

// MARK: GachaFetchView4Game.GotSomeItemView

extension GachaFetchView4Game {
    fileprivate struct GotSomeItemView: View {
        // MARK: Lifecycle

        public init(page: Int, gachaType: GachaType, newItemCount: Int, cancel: @escaping () -> Void) {
            self.page = page
            self.gachaType = gachaType
            self.poolType = gachaType.expressible
            self.newItemCount = newItemCount
            self.cancel = cancel
        }

        // MARK: Public

        @MainActor public var body: some View {
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

        // MARK: Fileprivate

        fileprivate let page: Int
        fileprivate let gachaType: GachaType
        fileprivate let poolType: GachaPoolExpressible
        fileprivate let newItemCount: Int
        fileprivate let cancel: () -> Void
    }
}

// MARK: GachaFetchView4Game.FailFetchingView

extension GachaFetchView4Game {
    fileprivate struct FailFetchingView: View {
        // MARK: Lifecycle

        public init(page: Int, gachaType: GachaType, error: Error, retry: @escaping () -> Void) {
            self.page = page
            self.gachaType = gachaType
            self.error = error
            self.retry = retry
        }

        // MARK: Public

        @MainActor public var body: some View {
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

        // MARK: Fileprivate

        fileprivate let page: Int
        fileprivate let gachaType: GachaType
        fileprivate let error: Error
        fileprivate let retry: () -> Void
    }
}

// MARK: GachaFetchView4Game.FinishedView

extension GachaFetchView4Game {
    fileprivate struct FinishedView: View {
        // MARK: Lifecycle

        public init(typeFetchedCount: [GachaType: Int], fireTask: @escaping () -> Void) {
            self.typeFetchedCount = typeFetchedCount
            self.fireTask = fireTask
        }

        // MARK: Public

        @MainActor public var body: some View {
            Section {
                Label {
                    Text("gachaKit.getRecord.finished.succeeded".i18nGachaKit)
                } icon: {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                }
                Button {
                    fireTask()
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

        // MARK: Fileprivate

        fileprivate let typeFetchedCount: [GachaType: Int]
        fileprivate let fireTask: () -> Void

        fileprivate var newRecordCount: String {
            let sortedTypeFechedCount = typeFetchedCount.sorted { $0.key.rawValue < $1.key.rawValue }
            return sortedTypeFechedCount.map { gachaType, count in
                "\(gachaType.description) - \(count); "
            }.reduce("", +)
        }
    }
}

// MARK: GachaFetchView4Game.GetGachaChart

extension GachaFetchView4Game {
    fileprivate struct GetGachaChart: View {
        // MARK: Public

        @Binding public var data: [VMType.GachaTypeDateCount]

        @MainActor public var body: some View {
            Chart(data) {
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

        // MARK: Fileprivate

        fileprivate var colorMap: KeyValuePairs<String, Color> {
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
