// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - InAppDailyNoteCardView

struct InAppDailyNoteCardView: View {
    // MARK: Lifecycle

    init(profile: PZProfileMO) {
        self.theVM = DailyNoteViewModel(profile: profile)
    }

    // MARK: Internal

    @MainActor var body: some View {
        Section {
            switch theVM.dailyNoteStatus {
            case let .succeed(dailyNote, _):
                NoteView(profile: theVM.profile, givenNote: dailyNote)
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
            }
            .secondaryColorVerseBackground()
            .textCase(.none)
        }
        .onChange(of: broadcaster.eventForRefreshingCurrentPage) {
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

// MARK: - NoteView

private struct NoteView: View {
    // MARK: Internal

    let profile: PZProfileMO
    let givenNote: any DailyNoteProtocol

    @MainActor var body: some View {
        switch givenNote {
        case let note as any Note4GI: getBody4GI(note: note)
        case let note as Note4HSR: getBody4HSR(note: note)
        default: EmptyView()
        }
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @ViewBuilder @MainActor
    private func getBody4HSR(note: Note4HSR) -> some View {
        // Trailblaze_Power
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
                    Text(verbatim: "\(note.staminaInfo.currentStamina)")
                        .font(.title)
                    Text(verbatim: " / \(note.staminaInfo.maxStamina)")
                        .font(.caption)
                    Spacer()
                    if note.staminaInfo.fullTime > Date() {
                        (
                            Text(note.staminaInfo.fullTime, style: .relative)
                                + Text(verbatim: "\n")
                                + Text(dateFormatter.string(from: note.staminaInfo.fullTime))
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        // Daily Training & Simulated Universe (China mainland user only)
        if let dailyNote = note as? WidgetNote4HSR {
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
        // Dispatch
        VStack {
            HStack {
                Text("app.dailynote.card.dispatch.label".i18nPZHelper).bold()
                Spacer()
                let onGoingAssignmentNumber = note.assignmentInfo.onGoingAssignmentNumber
                let totalAssignmentNumber = note.assignmentInfo.totalAssignmentNumber
                Text(verbatim: "\(onGoingAssignmentNumber)/\(totalAssignmentNumber)")
            }
            VStack(spacing: 15) {
                StaggeredGrid(
                    columns: horizontalSizeClass == .compact ? 2 : 4,
                    outerPadding: false,
                    scroll: false,
                    list: note.assignmentInfo.assignments
                ) { currentAssignment in
                    AssignmentView4HSR(assignment: currentAssignment)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder @MainActor
    private func getBody4GI(note dailyNote: any Note4GI) -> some View {
        let iconFrame: CGFloat = 40

        // Resin
        InformationRowView("app.dailynote.card.resin.label".i18nPZHelper) {
            let resinIntel = dailyNote.resinInfo
            HStack(spacing: 10) {
                AccountKit.imageAsset("gi_note_resin")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.1)
                    .frame(width: iconFrame, height: iconFrame)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(verbatim: "\(resinIntel.currentResin)")
                        .font(.title)
                    Text(verbatim: " / \(resinIntel.maxResin)")
                        .font(.caption)
                    Spacer()
                    if resinIntel.resinRecoveryTime > Date() {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(dateFormatter.string(from: resinIntel.resinRecoveryTime))
                                + Text(verbatim: "\n")
                                +
                                Text(
                                    dateComponentsFormatter
                                        .string(from: TimeInterval.sinceNow(to: resinIntel.resinRecoveryTime))!
                                )
                        }
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        // Daily Task
        InformationRowView("app.dailynote.card.dailyTask.label".i18nPZHelper) {
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
                        case false:
                            Text("app.dailynote.card.dailyTask.extraReward.notReceived".i18nPZHelper)
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        // Coin
        InformationRowView("app.dailynote.card.homeCoin.label".i18nPZHelper) {
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
                        (
                            Text(dateFormatter.string(from: homeCoin.fullTime))
                                + Text(verbatim: "\n")
                                +
                                Text(
                                    dateComponentsFormatter
                                        .string(from: TimeInterval.sinceNow(to: homeCoin.fullTime))!
                                )
                        )
                        .multilineTextAlignment(.trailing)
                        .font(.caption2)
                    }
                }
            }
        }
        // Expedition
        InformationRowView("app.dailynote.card.expedition.label".i18nPZHelper) {
            let expeditionInfo = dailyNote.expeditionInfo4GI
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
                    HStack {
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
        }
    }
}

// MARK: - AssignmentView4HSR

private struct AssignmentView4HSR: View {
    // MARK: Public

    @MainActor public var body: some View {
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
                        + Text("\n")
                        + Text(dateFormatter.string(from: assignment.finishedTime))
                )
                .multilineTextAlignment(.leading)
                .font(.caption2)
                .fontWidth(.condensed)
            } else {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            Spacer()
        }
    }

    // MARK: Internal

    @State var assignment: AssignmentInfo4HSR.Assignment
}

// MARK: - InformationRowView

/// Only for Genshin Impact
private struct InformationRowView<L: View>: View {
    // MARK: Lifecycle

    init(_ title: String, @ViewBuilder labelContent: @escaping () -> L) {
        self.title = title
        self.labelContent = labelContent
    }

    // MARK: Internal

    @ViewBuilder let labelContent: () -> L

    let title: String

    @MainActor var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.subheadline).bold()
            labelContent()
        }
    }
}

// MARK: - DailyNoteCardErrorView

private struct DailyNoteCardErrorView: View {
    public let profile: PZProfileMO
    public var error: Error

    @MainActor public var body: some View {
        Label {
            Text("app.dailynote.card.error.pleaseCheckAtProfileMgr".i18nPZHelper)
        } icon: {
            Image(systemSymbol: .questionmarkCircle)
                .foregroundColor(.yellow)
        }
//        switch error {
//        case MiHoYoAPIError.verificationNeeded:
//            Label {
//                Text("app.dailynote.card.error.need_verification.button".i18nPZHelper)
//            } icon: {
//                Image(systemSymbol: .questionmarkCircle)
//                    .foregroundColor(.yellow)
//            }
//        default:
//            Label {
//                Text("app.dailynote.card.error.other_error.button".i18nPZHelper)
//            } icon: {
//                Image(systemSymbol: .exclamationmarkCircle)
//                    .foregroundColor(.red)
//            }
//        }
    }

    // MARK: Private

    // @State private var isEditProfileSheetShown: Bool = false
    // @State private var alertToastEventStatus = AlertToastEventStatus()
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
