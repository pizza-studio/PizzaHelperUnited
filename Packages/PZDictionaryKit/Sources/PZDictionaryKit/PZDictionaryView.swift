// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - PZDictionaryView

public struct PZDictionaryView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle = "tool.dictionary.title".i18nDictKit
    public static let navDescription = "tool.dictionary.navDescription".i18nDictKit

    public var body: some View {
        List {
            if let currentResult = viewModel.currentResult {
                if currentResult.translations.isEmpty {
                    Text("tool.dictionary.not_found".i18nDictKit)
                } else {
                    ForEach(currentResult.translations) { translation in
                        NavigationLink {
                            DictionaryTranslationDetailView(translation: translation)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(translation.targetLanguage.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(translation.target)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                        }
                    }
                    if viewModel.nextPage <= currentResult.totalPage,
                       case .pending = viewModel.queryStatus {
                        Button("tool.dictionary.fetch_more".i18nDictKit) {
                            viewModel.fetchMore()
                        }
                    }
                }
            }
            if case .fetching = viewModel.queryStatus {
                ProgressView().id(UUID())
            } else if viewModel.currentResult == nil {
                Text("tool.dictionary.prompt_for_keywords".i18nDictKit)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Link(destination: viewModel.game.dictURL) {
                    Image(systemSymbol: .safari)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $viewModel.game.animation()) {
                    Text(Pizza.SupportedGame.genshinImpact.localizedShortName)
                        .tag(Pizza.SupportedGame.genshinImpact)
                    Text(Pizza.SupportedGame.starRail.localizedShortName)
                        .tag(Pizza.SupportedGame.starRail)
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("tool.dictionary.title".i18nDictKit)
        .apply { contents in
            #if os(iOS) || targetEnvironment(macCatalyst)
            contents.navBarTitleDisplayMode(.large)
            #else
            contents
            #endif
        }
        .searchable(text: $viewModel.query, placement: searchFieldPlacement)
        .onChange(of: viewModel.game) { oldValue, newValue in
            if oldValue != newValue {
                viewModel.restartFetch()
            }
        }
    }

    // MARK: Private

    @StateObject private var viewModel: Coordinator = .init()

    private var searchFieldPlacement: SearchFieldPlacement {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return .navigationBarDrawer(displayMode: .always)
        #else
        return .automatic
        #endif
    }
}

// MARK: PZDictionaryView.DictionaryTranslationDetailView

extension PZDictionaryView {
    private struct DictionaryTranslationDetailView: View {
        // MARK: Internal

        let translation: TranslationResult.Translation

        var body: some View {
            List {
                Section {
                    Text(translation.target)
                } header: {
                    Text("tool.dictionary.detail.target.header".i18nDictKit)
                } footer: {
                    HStack {
                        Text(translation.targetLanguage.description)
                    }
                }
                Section {
                    ForEach(sortedTranslations, id: \.key) { key, value in
                        Button {
                            Clipboard.currentString = value
                            isAlertShown.toggle()
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(key.description).font(.caption).foregroundColor(.gray)
                                Text(value).foregroundColor(.primary)
                            }
                        }
                    }
                } header: {
                    Text("tool.dictionary.detail.translations.header".i18nDictKit)
                } footer: {
                    Text(translation.nameTextMapHash.description)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .navigationTitle("tool.dictionary.detail.title".i18nDictKit)
            .apply { contents in
                #if os(iOS) || targetEnvironment(macCatalyst)
                contents.navBarTitleDisplayMode(.large)
                #else
                contents
                #endif
            }
            .alert("tool.dictionary.detail.copy_succeeded".i18nDictKit, isPresented: $isAlertShown) {
                Button("sys.ok".i18nBaseKit) {
                    isAlertShown.toggle()
                }
            }
        }

        // MARK: Private

        @State private var isAlertShown: Bool = false

        private var sortedTranslations: [(key: DictionaryLanguage, value: String)] {
            let tuples: [(key: DictionaryLanguage, value: String)] = translation.translationDictionary.map {
                (key: $0, value: $1)
            }
            return tuples.sorted { $0.key.rawValue < $1.key.rawValue }
        }
    }
}

// MARK: PZDictionaryView.Coordinator

extension PZDictionaryView {
    @Observable
    final class Coordinator: ObservableObject, @unchecked Sendable {
        // MARK: Lifecycle

        init() {
            self.cancellable = debouncedSearchSubject
                .debounce(for: .seconds(1), scheduler: DispatchQueue.main) // Adjust debounce time as needed
                .sink(receiveValue: { [weak self] query in
                    guard let self else { return }
                    // Perform search operation here with the debounced query
                    guard query != "" else { return }
                    self.nextPage = 1
                    if case let .fetching(task) = queryStatus {
                        task.cancel()
                    }
                    self.currentResult = nil
                    self.queryStatus = .pending
                    fetchFirst()
                })
        }

        // MARK: Internal

        enum QueryStatus {
            case pending
            case fetching(Task<Void, Never>)
        }

        var game: Pizza.SupportedGame = appGame ?? .genshinImpact
        var queryStatus: QueryStatus = .pending
        var nextPage: Int = 1
        var currentResult: TranslationResult?

        var query: String = "" {
            didSet {
                debouncedSearchSubject.send(query)
            }
        }

        func restartFetch() {
            debouncedSearchSubject.send(query)
        }

        func fetchFirst() {
            queryStatus = .fetching(Task(priority: .high) {
                do {
                    let result = try await self.game.translate(query: query, page: 1, pageSize: 20)
                    Task.detached { @MainActor @Sendable in
                        self.currentResult = result
                        self.queryStatus = .pending
                    }
                } catch {
                    print(error)
                }
            })
        }

        func fetchMore() {
            let game = game
            let query = query
            let nextPage = nextPage
            queryStatus = .fetching(Task(priority: .high) { @Sendable in
                do {
                    let result = try await game.translate(
                        query: query,
                        page: nextPage,
                        pageSize: 20
                    )
                    Task.detached { @MainActor @Sendable in
                        self.currentResult?.totalPage = result.totalPage
                        self.currentResult?.translations.append(contentsOf: result.translations)
                        self.queryStatus = .pending
                        self.nextPage += 1
                    }
                } catch {
                    print(error)
                }
            })
        }

        // MARK: Private

        private let debouncedSearchSubject = PassthroughSubject<String, Never>()
        @ObservationIgnored private var cancellable: AnyCancellable?
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PZDictionaryView()
            .frame(width: 640, height: 768)
    }
}
#endif
