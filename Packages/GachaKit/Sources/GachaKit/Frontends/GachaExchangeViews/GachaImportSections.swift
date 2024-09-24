// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import MultiPicker
import SFSafeSymbols
import SwiftUI
import UniformTypeIdentifiers

// MARK: - GachaImportSections

public struct GachaImportSections: View {
    // MARK: Public

    @MainActor public var body: some View {
        currentPage()
            .animation(.default, value: theVM.currentSceneStep4Import)
    }

    // MARK: Internal

    @MainActor @ViewBuilder
    func makeFormatPicker() -> some View {
        LabeledContent {
            Picker(
                "gachaKit.exchange.fileFormat".i18nGachaKit,
                selection: $format.animation()
            ) {
                ForEach(GachaExchange.ImportableFormat.allCases) { enumeratedFormat in
                    Text(verbatim: enumeratedFormat.shortNameForPicker)
                        .tag(enumeratedFormat)
                }
            }
            .labelsHidden()
            .fixedSize()
        } label: {
            Text("gachaKit.exchange.fileFormat".i18nGachaKit)
        }
    }

    @MainActor @ViewBuilder
    func buttonToStepOne() -> some View {
        if theVM.taskState != .busy {
            Button("gachaKit.exchange.backAndReselectFile.button".i18nGachaKit) {
                withAnimation {
                    theVM.currentSceneStep4Import = .chooseFormat
                    chosenGPID.removeAll()
                }
            }
        }
    }

    // MARK: Fileprivate

    @Environment(GachaVM.self) fileprivate var theVM
    @State fileprivate var format: GachaExchange.ImportableFormat = .asUIGFv4
    @State fileprivate var chosenGPID: Set<GachaProfileID> = []
}

// MARK: GachaImportSections.SceneStep

extension GachaImportSections {
    public enum SceneStep: Hashable, Sendable, Equatable {
        case chooseFormat
        case chooseProfiles(UIGFv4)
        case importSucceeded([GachaProfileID: Int])
        case error(Error)

        // MARK: Public

        public var typeNum: Int {
            switch self {
            case .chooseFormat: 0
            case let .chooseProfiles(document): document.hashValue
            case let .importSucceeded(dictionary): dictionary.hashValue
            case let .error(error): "\(error)".hashValue
            }
        }

        public static func == (lhs: SceneStep, rhs: SceneStep) -> Bool {
            lhs.typeNum == rhs.typeNum
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(typeNum)
        }
    }

    @MainActor @ViewBuilder
    func currentPage() -> some View {
        @Bindable var theVM = theVM
        switch $theVM.currentSceneStep4Import.animation().wrappedValue {
        case .chooseFormat: body4SceneStepChooseFormat()
        case let .chooseProfiles(source): body4SceneStepChooseProfiles(source)
        case let .importSucceeded(source): body4SceneStepImportResultPresentation(source)
        case let .error(error): errorView(error)
        }
    }
}

// MARK: - Scene Page - Choose Format

extension GachaImportSections {
    @MainActor @ViewBuilder
    func body4SceneStepChooseFormat() -> some View {
        Section {
            makeFormatPicker()
            if format.isObsoletedFormat {
                FallbackTimeZonePicker()
            }
            if theVM.taskState == .busy {
                ProgressView()
            } else {
                Group {
                    let rawUTTypes: [String] = switch format {
                    case .asUIGFv4: ["uigf", "json"]
                    case .asSRGFv1: ["srgf", "json"]
                    case .asGIGFJson: ["gigf", "json"]
                    case .asGIGFExcel: ["xlsx"]
                    }
                    let utTypes: [UTType] = rawUTTypes.compactMap { UTType(filenameExtension: $0) }
                    PopFileButton(
                        title: "gachaKit.exchange.loadFile.button.title".i18nGachaKit,
                        allowedContentTypes: utTypes
                    ) { result in
                        withAnimation {
                            switch result {
                            case let .success(url):
                                theVM.prepareGachaDocumentForImport(url, format: self.format)
                            case let .failure(error):
                                theVM.currentError = GachaKit.FileExchangeException.otherError(error)
                            }
                        }
                    }
                }

                if let error = theVM.currentError, error is GachaKit.FileExchangeException {
                    Text(verbatim: "\(error)").font(.caption2)
                }
            }
        } footer: {
            VStack(alignment: .leading, spacing: 11) {
                switch format {
                case .asUIGFv4:
                    Text("gachaKit.exchange.formatExplain.uigfv4".i18nGachaKit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .asSRGFv1:
                    Text("gachaKit.exchange.formatExplain.srgfv1".i18nGachaKit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .asGIGFExcel, .asGIGFJson:
                    Text(format.longName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("gachaKit.exchange.formatExplain.gigf".i18nGachaKit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    let timeZoneExplain = "gachaKit.exchange.formatExplain.gigf.timeZone".i18nGachaKit
                    let lines = timeZoneExplain.components(separatedBy: .newlines)
                    ForEach(lines, id: \.self) { currentLine in
                        Text(verbatim: currentLine)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("gachaKit.exchange.formatExplain.gigf.minimumSupportedVersion".i18nGachaKit)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("gachaKit.uigf.affLink.[UIGF](https://uigf.org/)", bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Scene Page - Choose Profiles

extension GachaImportSections {
    @MainActor @ViewBuilder
    func body4SceneStepChooseProfiles(_ source: UIGFv4) -> some View {
        buttonToStepOne()

        Section {
            LabeledContent {
                Text(verbatim: source.info.previousFormat)
            } label: {
                Text("gachaKit.exchange.fileFormat".i18nGachaKit)
            }
            LabeledContent {
                Text(verbatim: source.info.exportApp)
            } label: {
                Text("gachaKit.exchange.exportedFromApp".i18nGachaKit)
            }
            makeDateLabel(unixTimeStamp: source.info.exportTimestamp)

            Group {
                if theVM.taskState != .busy {
                    Button {
                        theVM.importUIGFv4(
                            source,
                            specifiedGPIDs: self.chosenGPID
                        )
                        theVM.updateMappedEntriesByPools(
                            immediately: false
                        )
                    } label: {
                        Text(verbatim: "gachaKit.exchange.startImportingData.button".i18nGachaKit)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                            }
                    }
                } else {
                    ProgressView()
                }
            }
        }

        Section {
            // Do NOT animate this. Animating this doesn't make any sense.
            MultiPicker("".description, selection: $chosenGPID) {
                let nameIDMap = theVM.nameIDMap
                let sortedGPIDs = source.extractGachaProfileIDs()
                ForEach(sortedGPIDs) { gpid in
                    GachaExchangeView.drawGPID(
                        gpid,
                        nameIDMap: nameIDMap,
                        isChosen: chosenGPID.contains(gpid)
                    )
                    .mpTag(gpid)
                }
            }
            .labelsHidden()
        } header: {
            Text("gachaKit.exchange.chooseProfiles.import.prompt".i18nGachaKit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.none)
        }
        .mpPickerStyle(.inline)
        .selectionIndicatorPosition(.trailing)
    }

    @MainActor @ViewBuilder
    fileprivate func makeDateLabel(unixTimeStamp: String) -> some View {
        if let timeInterval: TimeInterval = Double(unixTimeStamp) {
            let date = Date(timeIntervalSince1970: timeInterval)
            LabeledContent {
                let bigTime = Text(verbatim: dateFormatterCurrent.string(from: date))
                if TimeZone.autoupdatingCurrent != .gmt {
                    VStack(alignment: .trailing) {
                        bigTime.font(.caption)
                        let timeInfo2 = "UTC+0: " + dateFormatterGMT.string(from: date)
                        Text(verbatim: timeInfo2).font(.caption2).foregroundStyle(.secondary)
                    }
                } else {
                    bigTime
                }
            } label: {
                Text("gachaKit.exchange.import.info.time".i18nGachaKit)
            }
        } else {
            LabeledContent {
                Text(verbatim: "N/A")
            } label: {
                Text("gachaKit.exchange.import.info.time".i18nGachaKit)
            }
        }
    }

    private var dateFormatterGMT: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        fmt.timeZone = .gmt
        return fmt
    }

    private var dateFormatterCurrent: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        fmt.timeZone = .autoupdatingCurrent
        return fmt
    }
}

// MARK: - Scene Page - Ready to Import

extension GachaImportSections {
    @MainActor @ViewBuilder
    func body4SceneStepImportResultPresentation(_ result: [GachaProfileID: Int]) -> some View {
        Section {
            Label {
                Text("gachaKit.exchange.import.succeeded".i18nGachaKit)
            } icon: {
                Image(systemSymbol: .externaldriveFillBadgeCheckmark)
            }
            .accentColor(.green)
            buttonToStepOne()
        }

        Section {
            let nameIDMap = theVM.nameIDMap
            let sortedPairs = result.sorted { $0.key.uidWithGame < $1.key.uidWithGame }
            ForEach(sortedPairs, id: \.key) { gpid, importedCount in
                LabeledContent {
                    Text(verbatim: importedCount.description)
                        .font(.title3)
                        .fontWidth(.compressed)
                        .fontWeight(.medium)
                } label: {
                    GachaExchangeView.drawGPID(
                        gpid,
                        nameIDMap: nameIDMap
                    )
                }
            }
        } header: {
            Text("gachaKit.exchange.import.succeededReport.sectionHeader".i18nGachaKit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.none)
        }
    }
}

// MARK: - Scene Page - Error

extension GachaImportSections {
    @MainActor @ViewBuilder
    func errorView(_ error: Error) -> some View {
        Section {
            buttonToStepOne()
            Text(verbatim: "\(error)")
        }
    }
}

// MARK: - PopFileButton

private struct PopFileButton: View {
    // MARK: Lifecycle

    public init(
        title: String,
        allowedContentTypes: [UTType],
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        self.title = title
        self.allowedContentTypes = allowedContentTypes
        self.completion = completion
    }

    // MARK: Public

    public var body: some View {
        Button {
            isFileImporterShown.toggle()
        } label: {
            Text(verbatim: title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(8)
                .background {
                    RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                }
        }
        .fileImporter(
            isPresented: $isFileImporterShown,
            allowedContentTypes: allowedContentTypes
        ) { result in
            completion(result)
        }
    }

    // MARK: Fileprivate

    fileprivate let title: String
    fileprivate let allowedContentTypes: [UTType]
    fileprivate let completion: (Result<URL, Error>) -> Void
    @State fileprivate var isFileImporterShown: Bool = false
}

// MARK: - FallbackTimeZonePicker

private struct FallbackTimeZonePicker: View {
    // MARK: Public

    public var body: some View {
        Picker(
            "gachaKit.import.gigf.fallbackTimeZone".i18nGachaKit,
            selection: $fallbackTimeZone
        ) {
            Text(
                "gachaKit.import.gigf.fallbackTimeZone.autoDeduct".i18nGachaKit
            ).tag(TimeZone?.none)
            ForEach(tagPairs, id: \.1) { timeZoneName, identifier, timeZone in
                Text(verbatim: "\(timeZoneName) \(identifier)").monospacedDigit().tag(timeZone)
            }
        }
        .pickerStyle(.navigationLink)
    }

    // MARK: Fileprivate

    @Default(.fallbackTimeForGIGFFileImport) fileprivate var fallbackTimeZone: TimeZone?

    fileprivate var tagPairs: [(timeZoneName: String, identifier: String, timeZone: TimeZone?)] {
        var results: [(timeZoneName: String, identifier: String, timeZone: TimeZone)] = []
        TimeZone.knownTimeZoneIdentifiers.forEach { identifier in
            guard identifier != "GMT", let zone = TimeZone(identifier: identifier) else { return }
            let initialName = zone.localizedName(
                for: .shortDaylightSaving, locale: .autoupdatingCurrent
            ) ?? "N/A"
            var timeZoneName: String = initialName == "GMT" ? "GMT+0" : initialName
            timeZoneName = timeZoneName.replacingOccurrences(of: "GMT", with: "UTC")
            var identifierCells = identifier.split(separator: "/")
            if identifierCells.count > 2 {
                identifierCells.remove(at: 0)
            }
            let newEntry = (timeZoneName, identifierCells.joined(separator: " / "), zone)
            results.append(newEntry)
        }
        results.insert(("UTC+0", "Snap Hutao Deprecated & GMT", TimeZone.gmt), at: 0)
        return results
    }
}
