// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI

// MARK: - InAppDailyNoteCardView

@available(iOS 17.0, macCatalyst 17.0, *)
struct InAppDailyNoteCardView: View {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    var body: some View {
        Section {
            switch theVM.dailyNoteStatus {
            case let .succeed(dailyNote, _):
                switch dailyNote {
                case let note as any Note4GI: DailyNoteCardView4GI(note: note)
                case let note as any Note4HSR: DailyNoteCardView4HSR(note: note)
                case let note as Note4ZZZ: DailyNoteCardView4ZZZ(note: note)
                default: EmptyView()
                }
            case let .failure(error):
                DailyNoteCardErrorView(profile: theVM.profile, error: error)
            case .progress:
                ProgressView()
            }
        } header: {
            HStack {
                Text(theVM.profile.name)
                Spacer()
                Text(theVM.profile.uidWithGame)
                switch theVM.dailyNoteStatus {
                case let .succeed(dailyNote, _):
                    #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
                    Menu {
                        EnableLiveActivityButton(
                            for: theVM.profile,
                            dailyNote: dailyNote
                        )
                    } label: {
                        Image(systemSymbol: .ellipsisCircle)
                            .headerFooterTextVisibilityEnhanced()
                    }
                    #else
                    EmptyView()
                    #endif
                default:
                    EmptyView()
                }
            }
            .headerFooterTextVisibilityEnhanced()
            .textCase(.none)
        }
        .react(to: broadcaster.eventForJustSwitchedToTodayTab) {
            theVM.getDailyNote()
        }
        .react(to: broadcaster.eventForRefreshingTodayTab) {
            theVM.getDailyNoteUncheck()
        }
        .onAppBecomeActive(debounced: false) {
            theVM.getDailyNote()
        }
    }

    // MARK: Private

    @Environment(DailyNoteViewModel.self) private var theVM
    @StateObject private var broadcaster = Broadcaster.shared
}

// MARK: - DailyNoteCardErrorView

@available(iOS 17.0, macCatalyst 17.0, *)
private struct DailyNoteCardErrorView: View {
    // MARK: Public

    public let profile: PZProfileSendable
    public var error: Error

    public var body: some View {
        Section {
            Label {
                VStack {
                    Text("app.dailynote.card.error.pleaseCheckAtProfileMgr".i18nPZHelper)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(error.localizedDescription).font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 0.5)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            } icon: {
                Image(systemSymbol: .questionmarkCircle)
                    .foregroundColor(.yellow)
            }
            rootNavVM.gotoSettingsButtonIfAppropriate
        }
    }

    // MARK: Private

    @State private var rootNavVM = RootNavVM.shared
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter.CurrentLocale()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    dateFormatter.doesRelativeDateFormatting = true
    return dateFormatter
}()

private let dateComponentsFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()

// MARK: - DailyNoteCardView4GI

@available(iOS 17.0, macCatalyst 17.0, *)
private struct DailyNoteCardView4GI: View, ExpeditionViewSuppliable {
    // MARK: Lifecycle

    public init(note dailyNote: any Note4GI) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        drawStaminaBlock()
        drawGIMiscComponents()
        drawExpeditionTasks()
            .task {
                pilotAssetMap = await dailyNote.getExpeditionAssetMap()
            }
    }

    // MARK: Internal

    @ViewBuilder
    func drawStaminaBlock() -> some View {
        VStack {
            HStack {
                Text("app.dailynote.card.resin.label".i18nPZHelper).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack(spacing: 10) {
                let iconFrame: CGFloat = 40
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(dailyNote.staminaIntel.finished)")
                        .font(.title)
                    Text(verbatim: " / \(dailyNote.staminaIntel.all)")
                        .font(.caption)
                    Spacer()
                    let fullTime = dailyNote.staminaFullTimeOnFinish
                    if fullTime > Date() {
                        (
                            Text(fullTime, style: .relative)
                                + Text(verbatim: "\n")
                                + Text(dateFormatter.string(from: fullTime))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        .help("app.dailynote.card.resin.label".i18nPZHelper)
    }

    @ViewBuilder
    func drawGIMiscComponents() -> some View {
        // Daily Task.
        do {
            let iconFrame: CGFloat = 24
            HStack {
                dailyNote.game.dailyTaskAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.dailyTask.label".i18nPZHelper)
                Spacer()
                let sitrep = dailyNote.dailyTaskCompletionStatus
                if !sitrep.isAccomplished {
                    Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
                } else {
                    HStack {
                        if !dailyNote.allDailyTasksAccomplished {
                            Image(systemSymbol: .giftFill)
                                .foregroundColor(.orange)
                                .frame(width: 20, height: 20)
                                .clipShape(.rect)
                                .help(
                                    "app.dailynote.card.dailyTask.extraReward.notReceived"
                                        .i18nPZHelper
                                )
                        } else {
                            Image(systemSymbol: .checkmarkCircle)
                                .foregroundColor(.green)
                                .frame(width: 20, height: 20)
                                .clipShape(.rect)
                                .help(
                                    "app.dailynote.card.dailyTask.extraReward.received"
                                        .i18nPZHelper
                                )
                        }
                    }
                }
            }
            .help("app.dailynote.card.dailyTask.label".i18nPZHelper)
        }

        // Realm Currency.
        do {
            let homeCoin = dailyNote.homeCoinInfo
            let iconFrame: CGFloat = 24
            HStack {
                dailyNote.game.giRealmCurrencyAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                if homeCoin.fullTime > Date() {
                    Text(verbatim: "\(homeCoin.currentHomeCoin) / \(homeCoin.maxHomeCoin)")
                    Spacer()
                    let fullyChargedTime = homeCoin.fullTime
                    let nestedString = """
                    \(dateComponentsFormatter.string(from: TimeInterval.sinceNow(to: fullyChargedTime))!)
                    \(dateFormatter.string(from: fullyChargedTime))
                    """
                    Text(verbatim: nestedString)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(verbatim: "app.dailynote.card.homeCoin.label".i18nPZHelper)
                    Spacer()
                    if homeCoin.currentHomeCoin == homeCoin.maxHomeCoin {
                        Image(systemSymbol: .checkmarkCircle)
                            .foregroundColor(.green)
                            .frame(width: 20, height: 20)
                    } else {
                        Text(verbatim: "\(homeCoin.currentHomeCoin) / \(homeCoin.maxHomeCoin)")
                    }
                }
            }
            .help("app.dailynote.card.homeCoin.label".i18nPZHelper)
        }

        // Trounce Blossom:
        if let trounceBlossomIntel = dailyNote.trounceBlossomIntel {
            HStack {
                let iconFrame: CGFloat = 24
                dailyNote.game.giTrounceBlossomAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.giTrounceBlossom.label".i18nPZHelper)
                Spacer()
                if trounceBlossomIntel.allDiscountsAreUsedUp {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                } else {
                    Text(verbatim: trounceBlossomIntel.textDescription)
                }
            }
        }

        // Parametric Transformer.
        if let paraTransIntel = dailyNote.parametricTransformerIntel {
            HStack {
                let iconFrame: CGFloat = 24
                dailyNote.game.giTransformerAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.parametricTransformer.label".i18nPZHelper)
                Spacer()
                switch paraTransIntel.isAvailable {
                case true:
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                case false:
                    if paraTransIntel.remainingDays > 0 {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(verbatim: "\(paraTransIntel.remainingDays)")
                            Text(verbatim: "app.dailynote.card.unit.days".i18nPZHelper)
                        }
                    } else {
                        let recoveryTime = paraTransIntel.recoveryTime
                        let nestedString = """
                        \(dateFormatter.string(from: recoveryTime))
                        \(
                            dateComponentsFormatter
                                .string(from: TimeInterval.sinceNow(to: recoveryTime))!
                        )
                        """
                        Text(verbatim: nestedString)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .help("app.dailynote.card.parametricTransformer.label".i18nPZHelper)
        }
    }

    @ViewBuilder
    func drawExpeditionTasks() -> some View {
        // Dispatch
        VStack {
            HStack {
                let iconFrame: CGFloat = 24
                dailyNote.game.expeditionAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.expedition.label".i18nPZHelper).bold()
                Spacer()
                let completionIntel = dailyNote.expeditionCompletionStatus
                if completionIntel.isAccomplished {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                } else {
                    Text(verbatim: "\(completionIntel.finished) / \(completionIntel.all)")
                }
            }
            ExpeditionAutoGridLayout(xSpacing: 2, ySpacing: 8) {
                ForEach(dailyNote.expeditionTasks, id: \.hashValue) { expeditionTask in
                    drawSingleExpedition(expeditionTask)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Fileprivate

    fileprivate func getPilotImage(_ url: URL?) -> Image? {
        guard let url else { return nil }
        return pilotAssetMap?[url]?.img
    }

    // MARK: Private

    @State private var pilotAssetMap: [URL: SendableImagePtr]?

    private let dailyNote: any Note4GI
    private let iconFrame: CGFloat = 40
}

// MARK: - DailyNoteCardView4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
private struct DailyNoteCardView4HSR: View, ExpeditionViewSuppliable {
    // MARK: Lifecycle

    public init(note dailyNote: any Note4HSR) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        drawStaminaBlock()
        drawHSRMiscComponents()
        drawExpeditionTasks()
            .task {
                pilotAssetMap = await dailyNote.getExpeditionAssetMap()
            }
    }

    // MARK: Internal

    @ViewBuilder
    func drawStaminaBlock() -> some View {
        VStack {
            let reservedStamina = dailyNote.staminaInfo.currentReserveStamina
            let hasReservedStamina = reservedStamina > 0
            let deltaExMax = hasReservedStamina ? dailyNote.staminaInfo.maxReserveStamina : 0
            HStack {
                Text("app.dailynote.card.trailblazePower.label".i18nPZHelper).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                if hasReservedStamina {
                    HStack {
                        dailyNote.game.secondaryStaminaAssetIcon
                            .resizable()
                            .scaledToFit()
                            .frame(height: iconFrame / 2)

                        Text(verbatim: "\(reservedStamina)").fontWeight(.heavy)
                            + Text(verbatim: " / \(deltaExMax)").fontWidth(.compressed)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 6)
                    .blurMaterialBackground(
                        shape: RoundedRectangle(cornerRadius: 6, style: .continuous)
                    )
                }
            }
            HStack(spacing: 10) {
                let iconFrame: CGFloat = 40
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(dailyNote.staminaIntel.finished)")
                        .font(.title)
                    Text(verbatim: " / \(dailyNote.staminaIntel.all)")
                        .font(.caption)
                    Spacer()
                    let fullTime = dailyNote.staminaFullTimeOnFinish
                    if fullTime > Date() {
                        (
                            Text(fullTime, style: .relative)
                                + Text(verbatim: "\n")
                                + Text(dateFormatter.string(from: fullTime))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        .help("app.dailynote.card.trailblazePower.label".i18nPZHelper)
    }

    @ViewBuilder
    func drawHSRMiscComponents() -> some View {
        let iconFrame: CGFloat = 24
        HStack {
            dailyNote.game.dailyTaskAssetIcon
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
            Text("app.dailynote.card.daily_training.label".i18nPZHelper)
            Spacer()
            let sitrep = dailyNote.dailyTaskCompletionStatus
            if !sitrep.isAccomplished {
                Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
            } else {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
                    .frame(width: 20, height: 20)
            }
        }
        .help("app.dailynote.card.daily_training.label".i18nPZHelper)
        if let strifeIntel = dailyNote.cosmicStrifeIntel {
            HStack {
                dailyNote.game.hsrCosmicStrifeAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.cosmic_strife.label".i18nPZHelper)
                Spacer()
                let currentScore = strifeIntel.finished
                let maxScore = strifeIntel.all
                if strifeIntel.isAccomplished {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                } else {
                    Text(verbatim: "\(currentScore) / \(maxScore)")
                }
            }
            .help("app.dailynote.card.cosmic_strife.label".i18nPZHelper)
        } else {
            HStack {
                dailyNote.game.hsrCosmicStrifeAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.simulated_universe.label".i18nPZHelper)
                Spacer()
                let currentScore = dailyNote.simulatedUniverseInfo.currentScore
                let maxScore = dailyNote.simulatedUniverseInfo.maxScore
                if currentScore >= maxScore {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                } else {
                    Text(verbatim: "\(currentScore) / \(maxScore)")
                }
            }
            .help("app.dailynote.card.simulated_universe.label".i18nPZHelper)
        }
        if let eowIntel = dailyNote.echoOfWarIntel {
            HStack {
                dailyNote.game.hsrEchoOfWarAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.hsr_echo_of_war.label".i18nPZHelper)
                Spacer()
                if eowIntel.allRewardsClaimed {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                } else {
                    Text(verbatim: eowIntel.textDescription)
                }
            }
        }
    }

    @ViewBuilder
    func drawExpeditionTasks() -> some View {
        // Dispatch
        VStack {
            HStack {
                let iconFrame: CGFloat = 24
                dailyNote.game.expeditionAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.dispatch.label".i18nPZHelper).bold()
                Spacer()
                let completionIntel = dailyNote.expeditionCompletionStatus
                if completionIntel.isAccomplished {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                } else {
                    Text(verbatim: "\(completionIntel.finished) / \(completionIntel.all)")
                }
            }
            ExpeditionAutoGridLayout(xSpacing: 2, ySpacing: 8) {
                ForEach(dailyNote.expeditionTasks, id: \.hashValue) { expeditionTask in
                    drawSingleExpedition(expeditionTask)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Fileprivate

    fileprivate func getPilotImage(_ url: URL?) -> Image? {
        guard let url else { return nil }
        return pilotAssetMap?[url]?.img
    }

    // MARK: Private

    @State private var pilotAssetMap: [URL: SendableImagePtr]?

    private let dailyNote: any Note4HSR
    private let iconFrame: CGFloat = 40
}

// MARK: - DailyNoteCardView4ZZZ

@available(iOS 17.0, macCatalyst 17.0, *)
private struct DailyNoteCardView4ZZZ: View {
    // MARK: Lifecycle

    public init(note dailyNote: Note4ZZZ) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        // Energy. 绝区电量。这里注意本地化不要直接写「电量」，免得被 App Store 审委会认为有歧义。
        VStack {
            HStack {
                Text("app.dailynote.card.zzzBatteryEnergy.label".i18nPZHelper).bold()
                Spacer()
            }
            HStack(spacing: 10) {
                let iconFrame: CGFloat = 40
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(dailyNote.energy.currentEnergyAmountDynamic)")
                        .font(.title)
                    Text(verbatim: " / \(dailyNote.energy.progress.max)")
                        .font(.caption)
                    Spacer()
                    if dailyNote.energy.fullyChargedDate > Date() {
                        (
                            Text(dailyNote.energy.fullyChargedDate, style: .relative)
                                + Text(verbatim: "\n")
                                + Text(dateFormatter.string(from: dailyNote.energy.fullyChargedDate))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        let iconFrame: CGFloat = 24
        HStack {
            dailyNote.game.dailyTaskAssetIcon
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
            Text("app.dailynote.card.zzzVitality.label".i18nPZHelper)
            Spacer()
            let sitrep = dailyNote.dailyTaskCompletionStatus
            if !sitrep.isAccomplished {
                Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
            } else {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
                    .frame(width: 20, height: 20)
                    .clipShape(.rect)
            }
        }
        HStack {
            dailyNote.game.zzzVHSStoreAssetIcon
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
            Text("app.dailynote.card.zzzVHSStoreInOperationState.label".i18nPZHelper)
            Spacer()
            Text(verbatim: dailyNote.vhsStoreState.localizedDescription)
        }
        if let cardScratched = dailyNote.cardScratched {
            HStack {
                dailyNote.game.zzzScratchCardAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.zzzScratchableCard.label".i18nPZHelper)
                Spacer()
                let stateDone = "app.dailynote.card.zzzScratchableCard.done".i18nPZHelper
                let stateNyet = "app.dailynote.card.zzzScratchableCard.notYet".i18nPZHelper
                if cardScratched {
                    HStack {
                        Text(verbatim: stateDone)
                        Image(systemSymbol: .checkmarkCircle)
                            .frame(width: 20, height: 20)
                            .clipShape(.rect)
                    }
                    .foregroundColor(.green)
                } else {
                    Text(verbatim: stateNyet)
                }
            }
        }
        if let bountyCommission = dailyNote.hollowZero.bountyCommission {
            HStack {
                dailyNote.game.zzzBountyAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.zzzHollowZeroBountyCommission.label".i18nPZHelper)
                Spacer()
                let sitrep = FieldCompletionIntel<Int>(
                    pending: bountyCommission.total - bountyCommission.num,
                    finished: bountyCommission.num,
                    all: bountyCommission.total
                )
                if !sitrep.isAccomplished {
                    Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
                } else {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                }
            }
        }
        if let investigationPoint = dailyNote.hollowZero.investigationPoint {
            HStack {
                dailyNote.game.zzzInvestigationPointsAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.zzzHollowZeroInvestigationPoint.label".i18nPZHelper)
                Spacer()
                let sitrep = FieldCompletionIntel<Int>(
                    pending: investigationPoint.total - investigationPoint.num,
                    finished: investigationPoint.num,
                    all: investigationPoint.total
                )
                if !sitrep.isAccomplished {
                    Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
                } else {
                    Image(systemSymbol: .checkmarkCircle)
                        .foregroundColor(.green)
                        .frame(width: 20, height: 20)
                }
            }
        }
    }

    // MARK: Private

    private let dailyNote: Note4ZZZ
    private let iconFrame: CGFloat = 40
}

// MARK: - ExpeditionViewSuppliable

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor
private protocol ExpeditionViewSuppliable {
    func getPilotImage(_ url: URL?) -> Image?
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension ExpeditionViewSuppliable {
    @ViewBuilder
    func drawSingleExpedition(_ task: any ExpeditionTask) -> some View {
        let avatarIconURLs: [URL] = [task.iconURL, task.iconURL4Copilot].compactMap { $0 }
        let timeOnFinish = task.timeOnFinish
        HStack(alignment: .center, spacing: 2) {
            // Avatar Icon
            HStack(alignment: .top, spacing: 0) {
                let imageFrame: CGFloat = 32
                let innerImageFrame: CGFloat = imageFrame - 2
                ForEach(avatarIconURLs, id: \.self) { url in
                    let image = getPilotImage(url) ?? Image(systemSymbol: .person)
                    switch task.isFinished {
                    case false:
                        image
                            .resizable()
                            .overlayImageWithRingProgressBar(
                                task.percOfCompletion ?? 0.5,
                                thickness: 2,
                                startAngle: 0,
                                scaler: 1.3
                            )
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(task.isFinished ? Color.clear : .green)
                            .contentShape(.circle)
                            .frame(width: innerImageFrame, height: innerImageFrame)
                            .contentShape(.circle)
                            .frame(width: imageFrame, height: imageFrame)
                    case true:
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: imageFrame)
                            .background {
                                Color.gray.opacity(0.5).clipShape(Circle())
                            }
                    }
                }
            }
            .fixedSize()
            .contentShape(.rect)
            .corneredTag(
                verbatim: getString4CorneredTagOfCompletion(task),
                alignment: avatarIconURLs.count == 1 ? .bottomTrailing : .bottom,
                textSize: 9,
                padding: 0
            )
            // Time
            if task.isFinished {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
                    .padding(.leading, 6)
                    .padding(.trailing, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if timeOnFinish == nil {
                Image(systemSymbol: .ellipsisCircle)
                    .padding(.leading, 6)
                    .padding(.trailing, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack {
                    if let timeOnFinish {
                        Text(timeOnFinish, style: .relative)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(dateFormatter.string(from: timeOnFinish))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .font(.caption2)
                .fontWidth(.compressed)
            }
        }
        .background {
            LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.1), .clear]),
                startPoint: .leading, endPoint: .trailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func getString4CorneredTagOfCompletion(_ task: any ExpeditionTask) -> String {
        guard !task.isFinished else { return "" }
        return task.percOfCompletion?.formatted(
            .percent.precision(.fractionLength(0))
        ) ?? (task.timeOnFinish != nil ? "" : "…")
    }
}

// MARK: - ExpeditionAutoGridLayout

@available(iOS 17.0, macCatalyst 17.0, *)
private struct ExpeditionAutoGridLayout: Layout {
    // MARK: Lifecycle

    /// 不需要 minWidth，布局会自动根据最宽的子视图计算
    public init(xSpacing: CGFloat = 8, ySpacing: CGFloat = 8) {
        self.xSpacing = xSpacing
        self.ySpacing = ySpacing
    }

    // MARK: Public

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    )
        -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let containerWidth = proposal.width ?? .infinity
        let layout = calculateLayout(for: containerWidth, subviews: subviews)

        // 最后一行的 Y 偏移 + 最后一行的行高 = 总高度
        let totalHeight = (layout.rowYOffsets.last ?? 0) + (layout.rowHeights.last ?? 0)
        return CGSize(width: containerWidth, height: totalHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else { return }

        let layout = calculateLayout(for: bounds.width, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let rowIndex = index / layout.columnCount
            let columnIndex = index % layout.columnCount

            let x = bounds.minX + CGFloat(columnIndex) * (layout.itemWidth + xSpacing)
            let y = bounds.minY + layout.rowYOffsets[rowIndex]

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: layout.itemWidth, height: layout.rowHeights[rowIndex])
            )
        }
    }

    // MARK: Private

    // MARK: - Private Helper

    private struct LayoutInfo {
        let columnCount: Int
        let itemWidth: CGFloat
        let rowHeights: [CGFloat]
        let rowYOffsets: [CGFloat]
    }

    private var xSpacing: CGFloat
    private var ySpacing: CGFloat

    private func calculateLayout(for containerWidth: CGFloat, subviews: Subviews) -> LayoutInfo {
        // 1. 自动寻找最大的固有宽度 (Ideal Width)
        // 我们询问每个 subview: "在没有约束的情况下，你想要多宽？"
        // 然后取最大值作为列宽的基础。
        var maxElementWidth: CGFloat = 0
        for view in subviews {
            let idealSize = view.sizeThatFits(.unspecified)
            if idealSize.width > maxElementWidth {
                maxElementWidth = idealSize.width
            }
        }

        // 防止宽度为0的边缘情况
        if maxElementWidth == 0 { maxElementWidth = 10 }

        // 2. 根据这个 maxElementWidth 计算能放几列
        // 公式：n * width + (n-1) * spacing <= containerWidth
        let columnCount = max(1, Int((containerWidth + xSpacing) / (maxElementWidth + xSpacing)))

        // 3. 计算实际每列的宽度 (让列撑满容器)
        // 即使最宽元素只有 100，如果容器能放 2.5 个，我们只放 2 个，
        // 并把剩下的空间平均分配给这 2 个，让它们变大。
        let totalSpacing = CGFloat(max(0, columnCount - 1)) * xSpacing
        let itemWidth = (containerWidth - totalSpacing) / CGFloat(columnCount)

        // 4. 计算行高
        var rowHeights: [CGFloat] = []
        var currentRowMaxHeight: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            // 这里给 subview 提议的宽度是计算出来的 itemWidth (强制等宽)
            let size = subview.sizeThatFits(ProposedViewSize(width: itemWidth, height: nil))
            currentRowMaxHeight = max(currentRowMaxHeight, size.height)

            // 换行检测：如果是该行最后一个，或者所有元素的最后一个
            if (index + 1) % columnCount == 0 || index == subviews.count - 1 {
                rowHeights.append(currentRowMaxHeight)
                currentRowMaxHeight = 0
            }
        }

        // 5. 计算 Y 轴偏移
        var rowYOffsets: [CGFloat] = []
        var currentY: CGFloat = 0
        for height in rowHeights {
            rowYOffsets.append(currentY)
            currentY += height + ySpacing
        }

        return LayoutInfo(
            columnCount: columnCount,
            itemWidth: itemWidth,
            rowHeights: rowHeights,
            rowYOffsets: rowYOffsets
        )
    }
}
