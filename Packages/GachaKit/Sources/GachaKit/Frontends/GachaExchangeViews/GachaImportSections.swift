// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - GachaImportSections

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaImportSections: View {
    // MARK: Public

    public var body: some View {
        currentPage()
            .animation(.default, value: theVM.currentSceneStep4Import)
    }

    // MARK: Internal

    @ViewBuilder
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
            Text("gachaKit.exchange.fileFormat", bundle: .module)
        }
    }

    @ViewBuilder
    func buttonToStepOne() -> some View {
        if theVM.taskState != .busy {
            Button {
                withAnimation {
                    theVM.currentSceneStep4Import = .chooseFormat
                    chosenGPID.removeAll()
                }
            } label: {
                Text("gachaKit.exchange.backAndReselectFile.button", bundle: .module)
            }
        }
    }

    // MARK: Private

    @State private var theVM: GachaVM = .shared
    @State private var format: GachaExchange.ImportableFormat = .asUIGFv4
    @State private var chosenGPID: Set<GachaProfileID> = []
    @State private var overrideDuplicatedEntriesOnImport: Bool = false
}

// MARK: GachaImportSections.SceneStep

@available(iOS 17.0, macCatalyst 17.0, *)
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

    @ViewBuilder
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaImportSections {
    @ViewBuilder
    func body4SceneStepChooseFormat() -> some View {
        Section {
            makeFormatPicker()
            if format.isObsoletedFormat {
                FallbackTimeZonePicker()
            }
            if theVM.taskState == .busy {
                InfiniteProgressBar().id(UUID())
            } else {
                Group {
                    // `plist` 与 `db` 分别为 披萨难民迁移文件 与 胡桃难民迁移文件。
                    let rawUTTypes: [String] = switch format {
                    case .asUIGFv4: ["uigf", "json", "plist", "db"]
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
                    Text("gachaKit.exchange.formatExplain.uigfv4", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("gachaKit.exchange.formatExplain.uigfv4.refugee.snapHutao", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.brown)
                    Text("gachaKit.exchange.formatExplain.uigfv4.refugee.pzHelper4GenshinV4", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.red)
                case .asSRGFv1:
                    Text("gachaKit.exchange.formatExplain.srgfv1", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case .asGIGFExcel, .asGIGFJson:
                    Text(format.longName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("gachaKit.exchange.formatExplain.gigf", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    let timeZoneExplain = "gachaKit.exchange.formatExplain.gigf.timeZone".i18nGachaKit
                    let lines = timeZoneExplain.components(separatedBy: .newlines)
                    ForEach(lines, id: \.self) { currentLine in
                        Text(verbatim: currentLine)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Text("gachaKit.exchange.formatExplain.gigf.minimumSupportedVersion", bundle: .module)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("gachaKit.uigf.affLink.[UIGF](https://uigf.org/)", bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Scene Page - Choose Profiles

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaImportSections {
    @ViewBuilder
    func body4SceneStepChooseProfiles(_ source: UIGFv4) -> some View {
        buttonToStepOne()

        Section {
            LabeledContent {
                Text(verbatim: source.info.previousFormat)
            } label: {
                Text("gachaKit.exchange.fileFormat", bundle: .module)
            }
            LabeledContent {
                Text(verbatim: source.info.exportApp)
            } label: {
                Text("gachaKit.exchange.exportedFromAppOrigin", bundle: .module)
            }
            makeDateLabel(unixTimeStamp: source.info.exportTimestamp)
            Toggle(
                "gachaKit.exchange.import.overrideDuplicatedEntries".i18nGachaKit,
                isOn: $overrideDuplicatedEntriesOnImport
            )

            Group {
                if theVM.taskState != .busy {
                    Button {
                        theVM.importUIGFv4(
                            source,
                            specifiedGPIDs: self.chosenGPID,
                            overrideDuplicatedEntries: overrideDuplicatedEntriesOnImport
                        )
                        theVM.updateMappedEntriesByPools(
                            immediately: false
                        )
                    } label: {
                        Text("gachaKit.exchange.startImportingData.button", bundle: .module)
                            .fontWeight(.bold)
                            .fontWidth(.condensed)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                } else {
                    InfiniteProgressBar().id(UUID())
                }
            }
        }

        Section {
            let sortedGPIDs = source.extractGachaProfileIDs()
            GachaExchangeView.GachaProfileDoppelPicker(
                among: sortedGPIDs,
                chosenOnes: $chosenGPID,
                nameIDMap: theVM.nameIDMap
            )
        } header: {
            Text("gachaKit.exchange.chooseGachaPullers.import.prompt", bundle: .module)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.none)
        }
    }

    @ViewBuilder
    private func makeDateLabel(unixTimeStamp: String) -> some View {
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
                Text("gachaKit.exchange.import.info.time", bundle: .module)
            }
        } else {
            LabeledContent {
                Text(verbatim: "N/A")
            } label: {
                Text("gachaKit.exchange.import.info.time", bundle: .module)
            }
        }
    }

    private var dateFormatterGMT: DateFormatter {
        let fmt = DateFormatter.GregorianPOSIX()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        fmt.timeZone = .gmt
        return fmt
    }

    private var dateFormatterCurrent: DateFormatter {
        let fmt = DateFormatter.GregorianPOSIX()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        fmt.timeZone = .autoupdatingCurrent
        return fmt
    }
}

// MARK: - Scene Page - Ready to Import

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaImportSections {
    @ViewBuilder
    func body4SceneStepImportResultPresentation(_ result: [GachaProfileID: Int]) -> some View {
        Section {
            Label {
                Text("gachaKit.exchange.import.succeeded", bundle: .module)
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
            Text("gachaKit.exchange.import.succeededReport.sectionHeader", bundle: .module)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.none)
        }
    }
}

// MARK: - Scene Page - Error

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaImportSections {
    @ViewBuilder
    func errorView(_ error: Error) -> some View {
        Section {
            buttonToStepOne()
            Text(verbatim: "\(error)")
        }
    }
}

// MARK: - PopFileButton

@available(iOS 17.0, macCatalyst 17.0, *)
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
                .fontWidth(.condensed)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .fileImporter(
            isPresented: $isFileImporterShown,
            allowedContentTypes: allowedContentTypes
        ) { result in
            completion(result)
        }
    }

    // MARK: Private

    @State private var isFileImporterShown: Bool = false

    private let title: String
    private let allowedContentTypes: [UTType]
    private let completion: (Result<URL, Error>) -> Void
}

// MARK: - FallbackTimeZonePicker

@available(iOS 17.0, macCatalyst 17.0, *)
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
        #if os(iOS) || targetEnvironment(macCatalyst)
        .pickerStyle(.navigationLink)
        #elseif os(macOS)
        .pickerStyle(.menu)
        #endif
    }

    // MARK: Private

    @Default(.fallbackTimeForGIGFFileImport) private var fallbackTimeZone: TimeZone?

    private var tagPairs: [(timeZoneName: String, identifier: String, timeZone: TimeZone?)] {
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
