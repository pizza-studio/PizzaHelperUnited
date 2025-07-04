// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - AssignmentInfo4HSR

/// A struct representing the assignment info generated by Note API
public struct AssignmentInfo4HSR: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.assignments = try container.decode([AssignmentInfo4HSR.Assignment].self, forKey: .assignments)
        self.totalAssignmentNumber = try container.decode(Int.self, forKey: .totalAssignmentNumber)
        if let acceptedAssignmentNumber = try? container.decode(Int.self, forKey: .acceptedAssignmentNumber) {
            self.acceptedAssignmentNumber = acceptedAssignmentNumber
        } else {
            self.acceptedAssignmentNumber = try container.decode(Int.self, forKey: .alterKeyForAcceptedAssignmentNumber)
        }
    }

    // MARK: Public

    // MARK: - Assignment

    /// Each assignment info generated by Note API
    public struct Assignment: ExpeditionTask, Encodable {
        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder
                .container(keyedBy: CodingKeys.self)
            self._remainingTime = try container.decode(TimeInterval.self, forKey: .remainingTime)
            self.avatarIconURLs = try container.decode([URL].self, forKey: .avatarIconURLs)
            self.itemIconURL = try container.decodeIfPresent(URL.self, forKey: .itemIconURL)
            self.name = try container.decode(String.self, forKey: .name)
            self._accomplishedTimestamp = try container.decodeIfPresent(Int.self, forKey: ._accomplishedTimestamp)
        }

        // MARK: Public

        /// The status of the assignment
        public enum Status: String, Codable, Hashable {
            case onGoing = "Ongoing"
            case finished = "Finished"
        }

        public static let totalTime: TimeInterval = 20 * 60 * 60

        public static let game: Pizza.SupportedGame = .starRail

        /// The avatars' icons of the assignment
        public let avatarIconURLs: [URL]

        /// The name of assignment, localized by HoYoLAB or Miyoushe
        public let name: String

        /// Assignment Item Icon URL (unavailable from Widget API)
        public let itemIconURL: URL?

        /// Remaining time of assignment
        public var remainingTime: TimeInterval {
            max(_remainingTime - Date().timeIntervalSince(fetchTime), 0)
        }

        /// The status of the assignment
        public var status: Status {
            remainingTime <= 0 ? .finished : .onGoing
        }

        /// The finished time of assignment
        public var finishedTime: Date {
            Date(timeInterval: _remainingTime, since: fetchTime)
        }

        /// Percentage of Completion
        public var percOfCompletion: Double {
            1.0 - remainingTime / Self.totalTime
        }

        /// Conforming to `Expedition` protocol.
        public var isFinished: Bool { remainingTime <= 0 }

        /// Conforming to `Expedition` protocol.
        public var iconURL: URL { avatarIconURLs.first! }

        /// Conforming to `Expedition` protocol.
        public var iconURL4Copilot: URL? {
            avatarIconURLs.count == 2 ? avatarIconURLs.last : nil
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(_remainingTime, forKey: .remainingTime)
            try container.encode(avatarIconURLs, forKey: .avatarIconURLs)
            try container.encodeIfPresent(itemIconURL, forKey: .itemIconURL)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(_accomplishedTimestamp, forKey: ._accomplishedTimestamp)
        }

        // MARK: Private

        // MARK: CodingKeys

        private enum CodingKeys: String, CodingKey {
            case status
            case remainingTime = "remaining_time"
            case avatarIconURLs = "avatars"
            case name
            case itemIconURL = "item_url"
            case _accomplishedTimestamp = "finish_ts"
        }

        /// The time when this struct is generated
        private let fetchTime: Date = .init()

        /// Remaining time of assignment when fetch
        private let _remainingTime: TimeInterval

        /// Assignment accomplished timestamp (unavailable from Widget API)
        private let _accomplishedTimestamp: Int?
    }

    /// Details of all accepted assignments
    public var assignments: [Assignment]
    /// Max assignments number
    public let totalAssignmentNumber: Int
    /// Current accepted assignment number
    public let acceptedAssignmentNumber: Int

    /// The number on going assignments
    public var onGoingAssignmentNumber: Int {
        assignments.map { assignment in
            assignment.status == .onGoing ? 1 : 0
        }.reduce(0, +)
    }

    public var allCompleted: Bool {
        assignments.first { $0.status == .onGoing } == nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(assignments, forKey: .assignments)
        try container.encode(totalAssignmentNumber, forKey: .totalAssignmentNumber)
        try container.encode(acceptedAssignmentNumber, forKey: .acceptedAssignmentNumber)
    }

    // MARK: Private

    // MARK: CodingKeys

    private enum CodingKeys: String, CodingKey {
        case assignments = "expeditions"
        case totalAssignmentNumber = "total_expedition_num"
        case acceptedAssignmentNumber = "accepted_epedition_num"
        // The non-Widget api has a typo here. So there are 2 keys for this field.
        case alterKeyForAcceptedAssignmentNumber = "accepted_expedition_num"
    }
}

// MARK: - AssignmentInfo4HSR.Assignment + Identifiable

extension AssignmentInfo4HSR.Assignment: Identifiable {
    public var id: String { name }
}
