// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI

// MARK: - InAppDailyNoteCardView

struct InAppDailyNoteCardView: View {
    // MARK: Lifecycle

    init(profile: PZProfileMO) {
        self._theVM = .init(
            wrappedValue: DailyNoteViewModel(profile: profile) { dailyNote in
                #if canImport(ActivityKit)
                if Defaults[.autoDeliveryResinTimerLiveActivity] {
                    Task {
                        // let accounts = AccountModel.shared.fetchAccountConfigs()
                        try? ResinRecoveryActivityController.shared.createResinRecoveryTimerActivity(
                            for: profile.asSendable,
                            data: dailyNote
                        )
                    }
                }
                #endif
            }
        )
    }

    // MARK: Internal

    var body: some View {
        Section {
            switch theVM.dailyNoteStatus {
            case let .succeed(dailyNote, _):
                switch dailyNote {
                case let note as any Note4GI: DailyNoteCardView4GI(note: note)
                case let note as Note4HSR: DailyNoteCardView4HSR(note: note)
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
                    #if canImport(ActivityKit)
                    Menu {
                        EnableLiveActivityButton(
                            for: theVM.profile.asSendable,
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
        .onChange(of: broadcaster.eventForJustSwitchedToTodayTab) {
            theVM.getDailyNote()
        }
        .onChange(of: broadcaster.eventForRefreshingCurrentPage) {
            theVM.getDailyNoteUncheck()
        }
        .onAppBecomeActive {
            theVM.getDailyNote()
        }
    }

    // MARK: Private

    @StateObject private var theVM: DailyNoteViewModel
    @StateObject private var broadcaster = Broadcaster.shared
}

// MARK: - DailyNoteCardErrorView

private struct DailyNoteCardErrorView: View {
    public let profile: PZProfileMO
    public var error: Error

    public var body: some View {
        Label {
            Text("app.dailynote.card.error.pleaseCheckAtProfileMgr".i18nPZHelper)
        } icon: {
            Image(systemSymbol: .questionmarkCircle)
                .foregroundColor(.yellow)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
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

private struct DailyNoteCardView4GI: View {
    // MARK: Lifecycle

    public init(note dailyNote: any Note4GI) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        drawResinAndWeeklyBosses()
        drawDailyTaskAndParametricTransformer()
        drawRealmCurrencyStatus()
        drawExpeditions()
    }

    // MARK: Internal

    @ViewBuilder
    func drawResinAndWeeklyBosses() -> some View {
        VStack(alignment: .leading) {
            let resinIntel = dailyNote.resinInfo
            HStack(spacing: 10) {
                AccountKit.imageAsset("gi_note_resin")
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
                    if resinIntel.resinRecoveryTime > Date() {
                        let fullyChargedTime = resinIntel.resinRecoveryTime
                        let nestedString = """
                        \(dateFormatter.string(from: fullyChargedTime))
                        \(dateComponentsFormatter.string(from: TimeInterval.sinceNow(to: fullyChargedTime))!)
                        """
                        Text(verbatim: nestedString)
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                            .fontWidth(.compressed)
                    }
                }
                // Trounce Blossom (Weekly Bosses)
                if let dailyNote = dailyNote as? GeneralNote4GI {
                    HStack(spacing: 4) {
                        AccountKit.imageAsset("gi_note_weeklyBosses")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconFrame - 6, height: iconFrame - 6)
                        let weeklyBossesInfo = dailyNote.weeklyBossesInfo
                        if weeklyBossesInfo.remainResinDiscount == 0 {
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
        }.help(Text("app.dailynote.card.resin.label".i18nPZHelper))
    }

    @ViewBuilder
    func drawDailyTaskAndParametricTransformer() -> some View {
        VStack(alignment: .leading) {
            let dailyTask = dailyNote.dailyTaskInfo
            HStack(spacing: 10) {
                AccountKit.imageAsset("gi_note_dailyTask")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconFrame, height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(dailyTask.finishedTaskCount)")
                        .font(.title)
                    Text(verbatim: " / \(dailyTask.totalTaskCount)")
                        .font(.caption)
                    Spacer()
                    if dailyTask.finishedTaskCount == dailyTask.totalTaskCount {
                        switch dailyTask.isExtraRewardReceived {
                        case true:
                            Text("app.dailynote.card.dailyTask.extraReward.received".i18nPZHelper)
                                .font(.caption2)
                                .fontWidth(.compressed)
                                .multilineTextAlignment(.trailing)
                        case false:
                            Text("app.dailynote.card.dailyTask.extraReward.notReceived".i18nPZHelper)
                                .font(.caption2)
                                .fontWidth(.compressed)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }

                // Parametric Transformer
                if let dailyNote = dailyNote as? GeneralNote4GI, dailyNote.transformerInfo.obtained {
                    let paraTransIntel = dailyNote.transformerInfo
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            AccountKit.imageAsset("gi_note_transformer")
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
        }.help(Text("app.dailynote.card.dailyTask.label".i18nPZHelper))
    }

    @ViewBuilder
    func drawRealmCurrencyStatus() -> some View {
        VStack(alignment: .leading) {
            let homeCoin = dailyNote.homeCoinInfo
            HStack(spacing: 10) {
                AccountKit.imageAsset("gi_note_teapot_coin")
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
                        \(dateFormatter.string(from: fullyChargedTime))
                        \(dateComponentsFormatter.string(from: TimeInterval.sinceNow(to: fullyChargedTime))!)
                        """
                        Text(verbatim: nestedString)
                            .multilineTextAlignment(.trailing)
                            .font(.caption2)
                            .fontWidth(.compressed)
                    }
                }
            }
        }.help(Text("app.dailynote.card.homeCoin.label".i18nPZHelper))
    }

    @ViewBuilder
    func drawExpeditions() -> some View {
        VStack(alignment: .leading) {
            let expeditionInfo = dailyNote.expeditions
            HStack(spacing: 10) {
                AccountKit.imageAsset("gi_note_expedition")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconFrame * 0.9, height: iconFrame * 0.9)
                    .frame(width: iconFrame, height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(expeditionInfo.ongoingExpeditionCount)")
                        .font(.title)
                    Text(verbatim: " / \(expeditionInfo.maxExpeditionsCount)")
                        .font(.caption)
                    Spacer()
                    HStack(spacing: 0) {
                        ForEach(expeditionInfo.expeditions, id: \.iconURL) { expedition in
                            AsyncImage(url: expedition.iconURL) { image in
                                GeometryReader { g in
                                    image.resizable().scaleEffect(1.4)
                                        .scaledToFit()
                                        .offset(x: -g.size.width * 0.06, y: -g.size.height * 0.25)
                                }
                            } placeholder: {
                                ProgressView().id(UUID())
                            }
                            .overlay(
                                Circle()
                                    .stroke(expedition.isFinished ? .green : .secondary, lineWidth: 3)
                            )
                            .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }.help("app.dailynote.card.expedition.label".i18nPZHelper)
    }

    // MARK: Private

    private let dailyNote: any Note4GI
    private let iconFrame: CGFloat = 40
}

// MARK: - DailyNoteCardView4HSR

private struct DailyNoteCardView4HSR: View {
    // MARK: Lifecycle

    public init(note dailyNote: Note4HSR) {
        self.dailyNote = dailyNote
    }

    // MARK: Public

    public var body: some View {
        drawTrailblazePower()
        drawDailyTrainingAndSimulatedUniverse()
        drawAssignments()
    }

    // MARK: Internal

    @ViewBuilder
    func drawTrailblazePower() -> some View {
        VStack {
            HStack {
                Text("app.dailynote.card.trailblazePower.label".i18nPZHelper).bold()
                Spacer()
            }
            HStack(spacing: 10) {
                let iconFrame: CGFloat = 40
                AccountKit.imageAsset("hsr_note_trailblazePower")
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
    func drawDailyTrainingAndSimulatedUniverse() -> some View {
        // Daily Training & Simulated Universe (WidgetNote4HSR only).
        if let dailyNote = dailyNote as? WidgetNote4HSR {
            HStack {
                Text("app.dailynote.card.daily_training.label".i18nPZHelper).bold()
                Spacer()
                let currentScore = dailyNote.dailyTrainingInfo.currentScore
                let maxScore = dailyNote.dailyTrainingInfo.maxScore
                Text(verbatim: "\(currentScore)/\(maxScore)")
            }
            HStack {
                Text("app.dailynote.card.simulated_universe.label".i18nPZHelper).bold()
                Spacer()
                let currentScore = dailyNote.simulatedUniverseInfo.currentScore
                let maxScore = dailyNote.simulatedUniverseInfo.maxScore
                Text(verbatim: "\(currentScore)/\(maxScore)")
            }
        }
    }

    @ViewBuilder
    func drawAssignments() -> some View {
        // Dispatch
        VStack {
            HStack {
                Text("app.dailynote.card.dispatch.label".i18nPZHelper).bold()
                Spacer()
                let onGoingAssignmentNumber = dailyNote.assignmentInfo.onGoingAssignmentNumber
                let totalAssignmentNumber = dailyNote.assignmentInfo.totalAssignmentNumber
                Text(verbatim: "\(onGoingAssignmentNumber)/\(totalAssignmentNumber)")
            }
            VStack(spacing: 15) {
                StaggeredGrid(
                    columns: horizontalSizeClass == .compact ? 2 : 4,
                    outerPadding: false,
                    scroll: false,
                    list: dailyNote.assignmentInfo.assignments
                ) { currentAssignment in
                    drawSingleAssignment(currentAssignment)
                }
                .fixedSize(horizontal: false, vertical: true)
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
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
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

    private let dailyNote: Note4HSR
    private let iconFrame: CGFloat = 40
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
}

// MARK: - DailyNoteCardView4ZZZ

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
                AccountKit.imageAsset("zzz_note_battery")
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
        HStack {
            Text("app.dailynote.card.zzzVitality.label".i18nPZHelper).bold()
            Spacer()
            Text(verbatim: "\(dailyNote.vitality.current)/\(dailyNote.vitality.max)")
        }
        HStack {
            Text("app.dailynote.card.zzzVHSStoreInOperationState.label".i18nPZHelper).bold()
            Spacer()
            let stateOn = "app.dailynote.card.zzzVHSStoreInOperationState.on".i18nPZHelper
            let stateOff = "app.dailynote.card.zzzVHSStoreInOperationState.off".i18nPZHelper
            Text(verbatim: dailyNote.vhsSale.isInOperation ? stateOn : stateOff)
        }
        HStack {
            Text("app.dailynote.card.zzzScratchableCard.label".i18nPZHelper).bold()
            Spacer()
            let stateDone = "app.dailynote.card.zzzScratchableCard.done".i18nPZHelper
            let stateNyet = "app.dailynote.card.zzzScratchableCard.notYet".i18nPZHelper
            Text(verbatim: dailyNote.cardScratched ? stateDone : stateNyet)
        }
    }

    // MARK: Private

    private let dailyNote: Note4ZZZ
    private let iconFrame: CGFloat = 40
}
