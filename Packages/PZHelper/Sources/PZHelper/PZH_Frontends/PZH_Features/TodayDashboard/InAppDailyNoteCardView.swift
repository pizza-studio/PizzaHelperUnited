// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI

// MARK: - InAppDailyNoteCardView

@available(iOS 17.0, macCatalyst 17.0, *)
struct InAppDailyNoteCardView: View {
    // MARK: Lifecycle

    init(profile: PZProfileSendable) {
        // InAppDailyNoteCardView 是在一个惰性容器（List / Form）内创建的。
        // 这就导致在今日画面卷动过程中会有一个现象：
        // 所有跑到视野之外的 InAppDailyNoteCardView 都会连同其 VM 一同被销毁。
        // 然后再卷到视野内的话就又会刷出来。
        // 这就容易造成对 HoYoLAB / 米游社伺服器的洪水访问增频事故。
        // 所以 InAppDailyNoteCardView 的 VM 必须缓存处理。
        let existingVM = DailyNoteViewModel.vmMap[profile.uuid.uuidString]
        self._theVM = .init(
            wrappedValue: existingVM ?? DailyNoteViewModel(profile: profile) { dailyNote in
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
                if Defaults[.autoDeliveryStaminaTimerLiveActivity] {
                    Task {
                        try? StaminaLiveActivityController.shared.createResinRecoveryTimerActivity(
                            for: profile,
                            data: dailyNote
                        )
                    }
                }
                #endif
            }
        )
        if existingVM == nil {
            DailyNoteViewModel.vmMap[profile.uuid.uuidString] = theVM
        }
    }

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
                            .secondaryColorVerseBackground()
                    }
                    #else
                    EmptyView()
                    #endif
                default:
                    EmptyView()
                }
            }
            .secondaryColorVerseBackground()
            .textCase(.none)
        }
        .react(to: broadcaster.eventForJustSwitchedToTodayTab) {
            theVM.getDailyNote()
        }
        .react(to: broadcaster.eventForRefreshingTodayTab) {
            theVM.getDailyNoteUncheck()
        }
        .onAppBecomeActive {
            theVM.getDailyNote()
        }
    }

    // MARK: Private

    @State private var theVM: DailyNoteViewModel
    @State private var broadcaster = Broadcaster.shared
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
private struct DailyNoteCardView4GI: View {
    // MARK: Lifecycle

    public init(note dailyNote: any Note4GI) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        drawResin() // This draws trounce blossom when resin is finished
        drawTrounceBlossomIfResinNotFinished()
        drawDailyTaskAndParametricTransformer()
        drawRealmCurrencyStatus()
        drawExpeditions()
            .task {
                pilotAssetMap = await dailyNote.getExpeditionAssetMap()
            }
    }

    // MARK: Internal

    var resinFinished: Bool {
        dailyNote.staminaIntel.isAccomplished
    }

    @ViewBuilder
    func drawResin() -> some View {
        VStack(alignment: .leading) {
            let resinIntel = dailyNote.resinInfo
            HStack(spacing: 10) {
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.1)
                    .frame(width: iconFrame, height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(resinIntel.currentResinDynamic)")
                        .font(.title)
                    Text(verbatim: " / \(resinIntel.maxResin)")
                        .font(.caption)
                    Spacer()
                    if !resinFinished {
                        let fullyChargedTime = resinIntel.resinRecoveryTime
                        let nestedString = """
                        \(dateComponentsFormatter.string(from: TimeInterval.sinceNow(to: fullyChargedTime))!)
                        \(dateFormatter.string(from: fullyChargedTime))
                        """
                        Text(verbatim: nestedString)
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                            .fontWidth(.compressed)
                    }
                }
                // Trounce Blossom (Weekly Bosses)
                if resinFinished, let dailyNote = dailyNote as? FullNote4GI {
                    HStack(spacing: 4) {
                        dailyNote.game.giTrounceBlossomAssetIcon
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconFrame - 6, height: iconFrame - 6)
                        let weeklyBossesInfo = dailyNote.weeklyBossesInfo
                        if weeklyBossesInfo.allDiscountsAreUsedUp {
                            Image(systemSymbol: .checkmarkCircle)
                                .foregroundColor(.green)
                                .frame(width: 20, height: 20)
                        } else {
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                Text(verbatim: "\(weeklyBossesInfo.remainResinDiscount)")
                                    .font(.title)
                                Text(verbatim: " / \(weeklyBossesInfo.totalResinDiscount)")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                    )
                }
            }
        }.help("app.dailynote.card.resin.label".i18nPZHelper)
    }

    @ViewBuilder
    func drawTrounceBlossomIfResinNotFinished() -> some View {
        if !resinFinished, let dailyNote = dailyNote as? FullNote4GI {
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    dailyNote.game.giTrounceBlossomAssetIcon
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.1)
                        .frame(width: iconFrame, height: iconFrame)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        let weeklyBossesInfo = dailyNote.weeklyBossesInfo
                        if weeklyBossesInfo.allDiscountsAreUsedUp {
                            Image(systemSymbol: .checkmarkCircle)
                                .foregroundColor(.green)
                                .frame(width: 20, height: 20)
                        } else {
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                Text(verbatim: "\(weeklyBossesInfo.remainResinDiscount)")
                                    .font(.title)
                                Text(verbatim: " / \(weeklyBossesInfo.totalResinDiscount)")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                    }
                }
            }.help("app.dailynote.card.resin.label".i18nPZHelper)
        }
    }

    @ViewBuilder
    func drawDailyTaskAndParametricTransformer() -> some View {
        VStack(alignment: .leading) {
            let sitrep = dailyNote.dailyTaskCompletionStatus
            HStack(spacing: 10) {
                dailyNote.game.dailyTaskAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconFrame, height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(sitrep.finished)").font(.title)
                    Text(verbatim: " / \(sitrep.all)").font(.caption)
                    Spacer()
                    Group {
                        if sitrep.isAccomplished,
                           let extraRewardClaimed = dailyNote.claimedRewardsFromKatheryne {
                            switch extraRewardClaimed {
                            case true:
                                Text("app.dailynote.card.dailyTask.extraReward.received".i18nPZHelper)
                            case false:
                                Text("app.dailynote.card.dailyTask.extraReward.notReceived".i18nPZHelper)
                            }
                        }
                    }
                    .font(.caption2)
                    .fontWidth(.compressed)
                    .multilineTextAlignment(.trailing)
                }

                // Parametric Transformer
                if let dailyNote = dailyNote as? FullNote4GI, dailyNote.transformerInfo.obtained {
                    let paraTransIntel = dailyNote.transformerInfo
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            dailyNote.game.giTransformerAssetIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: iconFrame - 6, height: iconFrame - 6)
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                // Time
                                if !paraTransIntel.isAvailable {
                                    if paraTransIntel.remainingDays > 0 {
                                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                                            Text(verbatim: "\(paraTransIntel.remainingDays)")
                                                .font(.title)
                                            Text(verbatim: "app.dailynote.card.unit.days".i18nPZHelper)
                                                .font(.caption)
                                                .fontWidth(.compressed)
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
                                            .font(.caption2)
                                            .fontWidth(.compressed)
                                    }
                                } else {
                                    Image(systemSymbol: .checkmarkCircle)
                                        .foregroundColor(.green)
                                        .frame(width: 20, height: 20)
                                }
                            }
                        }
                    }
                    .help(Text("app.dailynote.card.parametricTransformer.label".i18nPZHelper))
                    .padding(.horizontal, 6)
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                    )
                }
            }
        }.help("app.dailynote.card.dailyTask.label".i18nPZHelper)
    }

    @ViewBuilder
    func drawRealmCurrencyStatus() -> some View {
        VStack(alignment: .leading) {
            let homeCoin = dailyNote.homeCoinInfo
            HStack(spacing: 10) {
                dailyNote.game.giRealmCurrencyAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconFrame * 0.9, height: iconFrame * 0.9)
                    .frame(width: iconFrame, height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(homeCoin.currentHomeCoin)")
                        .font(.title)
                    Text(verbatim: " / \(homeCoin.maxHomeCoin)")
                        .font(.caption)
                    Spacer()
                    if homeCoin.fullTime > Date() {
                        let fullyChargedTime = homeCoin.fullTime
                        let nestedString = """
                        \(dateComponentsFormatter.string(from: TimeInterval.sinceNow(to: fullyChargedTime))!)
                        \(dateFormatter.string(from: fullyChargedTime))
                        """
                        Text(verbatim: nestedString)
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                            .fontWidth(.compressed)
                    }
                }
            }
        }.help("app.dailynote.card.homeCoin.label".i18nPZHelper)
    }

    @ViewBuilder
    func drawExpeditions() -> some View {
        VStack(alignment: .leading) {
            let expeditionIntel = dailyNote.expeditionCompletionStatus
            HStack(alignment: .center, spacing: 0) {
                dailyNote.game.expeditionAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconFrame * 0.9, height: iconFrame * 0.9)
                    .frame(width: iconFrame, height: iconFrame)
                    .padding(.trailing, 10)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(expeditionIntel.finished)")
                        .font(.title)
                    Text(verbatim: " / \(expeditionIntel.all)")
                        .font(.caption)
                    Spacer(minLength: 0)
                }
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(dailyNote.expeditionTasks, id: \.iconURL) { expedition in
                        let image = getPilotImage(expedition.iconURL) ?? Image(systemSymbol: .person)
                        image
                            .resizable()
                            .scaledToFit()
                            .background {
                                if expedition.isFinished {
                                    Color.green.opacity(0.75).clipShape(Circle())
                                } else {
                                    Color.gray.opacity(0.5).clipShape(Circle())
                                }
                            }
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }.help("app.dailynote.card.expedition.label".i18nPZHelper)
    }

    // MARK: Private

    @State private var pilotAssetMap: [URL: SendableImagePtr]?

    private let dailyNote: any Note4GI
    private let iconFrame: CGFloat = 40

    private func getPilotImage(_ url: URL?) -> Image? {
        guard let url else { return nil }
        return pilotAssetMap?[url]?.img
    }
}

// MARK: - DailyNoteCardView4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
private struct DailyNoteCardView4HSR: View {
    // MARK: Lifecycle

    public init(note dailyNote: any Note4HSR) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        drawTrailblazePower()
        drawHSRMiscComponents()
        drawAssignments()
            .task {
                pilotAssetMap = await dailyNote.getExpeditionAssetMap()
            }
    }

    // MARK: Internal

    @ViewBuilder
    func drawTrailblazePower() -> some View {
        VStack {
            let reservedStamina = dailyNote.staminaInfo.currentReserveStamina
            let hasReservedStamina = reservedStamina > 0
            let deltaExMax = hasReservedStamina ? dailyNote.staminaInfo.maxReserveStamina : 0
            HStack {
                Text("app.dailynote.card.trailblazePower.label".i18nPZHelper).bold()
                Spacer()
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
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 6, style: .continuous)
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
                    Text(verbatim: "\(dailyNote.staminaInfo.currentStamina)")
                        .font(.title)
                    Text(verbatim: " / \(dailyNote.staminaInfo.maxStamina)")
                        .font(.caption)
                    Spacer()
                    if dailyNote.staminaInfo.fullTime > Date() {
                        (
                            Text(dailyNote.staminaInfo.fullTime, style: .relative)
                                + Text(verbatim: "\n")
                                + Text(dateFormatter.string(from: dailyNote.staminaInfo.fullTime))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
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
            Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
        }
        .help("app.dailynote.card.daily_training.label".i18nPZHelper)
        HStack {
            dailyNote.game.hsrSimulatedUniverseAssetIcon
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
            Text("app.dailynote.card.simulated_universe.label".i18nPZHelper)
            Spacer()
            let currentScore = dailyNote.simulatedUniverseInfo.currentScore
            let maxScore = dailyNote.simulatedUniverseInfo.maxScore
            Text(verbatim: "\(currentScore) / \(maxScore)")
        }
        .help("app.dailynote.card.simulated_universe.label".i18nPZHelper)
        if let eowIntel = dailyNote.echoOfWarIntel {
            HStack {
                dailyNote.game.hsrEchoOfWarAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.hsr_echo_of_war.label".i18nPZHelper)
                Spacer()
                Text(verbatim: eowIntel.textDescription)
            }
        }
    }

    @ViewBuilder
    func drawAssignments() -> some View {
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
                Text(verbatim: "\(completionIntel.finished) / \(completionIntel.all)")
            }
            VStack(spacing: 15) {
                ViewThatFits(in: .horizontal) {
                    ForEach([4, 2, 1], id: \.self) { columnsCompatible in
                        StaggeredGrid(
                            columns: columnsCompatible,
                            outerPadding: false,
                            scroll: false,
                            list: dailyNote.assignmentInfo.assignments
                        ) { currentAssignment in
                            drawSingleAssignment(currentAssignment)
                                .fixedSize()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    @ViewBuilder
    func drawSingleAssignment(_ assignment: AssignmentInfo4HSR.Assignment) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                // Avatar Icon
                HStack(alignment: .top, spacing: 2) {
                    let imageFrame: CGFloat = 32
                    ForEach(assignment.avatarIconURLs, id: \.self) { url in
                        let image = getPilotImage(url) ?? Image(systemSymbol: .person)
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: imageFrame)
                            .background {
                                Color.gray.opacity(0.5).clipShape(Circle())
                            }
                    }
                }.fixedSize()
            }
            // Time
            if assignment.remainingTime > 0 {
                (
                    Text(assignment.finishedTime, style: .relative)
                        + Text(verbatim: "\n")
                        + Text(dateFormatter.string(from: assignment.finishedTime))
                )
                .multilineTextAlignment(.leading)
                .font(.caption2)
                .fontWidth(.compressed)
            } else {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            Spacer()
        }
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @State private var pilotAssetMap: [URL: SendableImagePtr]?

    private let dailyNote: any Note4HSR
    private let iconFrame: CGFloat = 40

    private func getPilotImage(_ url: URL?) -> Image? {
        guard let url else { return nil }
        return pilotAssetMap?[url]?.img
    }
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
            Text("app.dailynote.card.zzzVitality.label".i18nPZHelper).bold()
            Spacer()
            let sitrep = dailyNote.dailyTaskCompletionStatus
            Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
        }
        HStack {
            dailyNote.game.zzzVHSStoreAssetIcon
                .resizable()
                .scaledToFit()
                .frame(height: iconFrame)
            Text("app.dailynote.card.zzzVHSStoreInOperationState.label".i18nPZHelper).bold()
            Spacer()
            Text(verbatim: dailyNote.vhsStoreState.localizedDescription)
        }
        if let cardScratched = dailyNote.cardScratched {
            HStack {
                dailyNote.game.zzzScratchCardAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.zzzScratchableCard.label".i18nPZHelper).bold()
                Spacer()
                let stateDone = "app.dailynote.card.zzzScratchableCard.done".i18nPZHelper
                let stateNyet = "app.dailynote.card.zzzScratchableCard.notYet".i18nPZHelper
                Text(verbatim: cardScratched ? stateDone : stateNyet)
            }
        }
        if let bountyCommission = dailyNote.hollowZero.bountyCommission {
            HStack {
                dailyNote.game.zzzBountyAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.zzzHollowZeroBountyCommission.label".i18nPZHelper).bold()
                Spacer()
                Text(verbatim: bountyCommission.textDescription)
            }
        }
        if let investigationPoint = dailyNote.hollowZero.investigationPoint {
            HStack {
                dailyNote.game.zzzInvestigationPointsAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: iconFrame)
                Text("app.dailynote.card.zzzHollowZeroInvestigationPoint.label".i18nPZHelper).bold()
                Spacer()
                Text(verbatim: investigationPoint.textDescription)
            }
        }
    }

    // MARK: Private

    private let dailyNote: Note4ZZZ
    private let iconFrame: CGFloat = 40
}
