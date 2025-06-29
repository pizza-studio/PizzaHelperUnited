// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYo.BattleReport4GI.StygianOnslaughtQueryResult

extension HoYo.BattleReport4GI {
    public struct StygianOnslaughtQueryResult: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public struct Links: AbleToCodeSendHash {
            // MARK: Public

            public let lineupLink: String
            public let playLink: String

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case lineupLink = "lineup_link"
                case playLink = "play_link"
            }
        }

        public let data: [HoYo.BattleReport4GI.StygianOnslaughtData]
        public let isUnlock: Bool
        public let links: Links

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case data, links
            case isUnlock = "is_unlock"
        }
    }
}

// MARK: - HoYo.BattleReport4GI.StygianOnslaughtData

extension HoYo.BattleReport4GI {
    public struct StygianOnslaughtData: AbleToCodeSendHash {
        // MARK: Public

        public struct Schedule: AbleToCodeSendHash {
            // MARK: Public

            public struct SODateComponents: AbleToCodeSendHash {
                // MARK: Public

                public let year: Int
                public let month: Int
                public let day: Int
                public let hour: Int
                public let minute: Int
                public let second: Int

                public var description: String {
                    let monthString = "0\(month)".suffix(2)
                    let dayString = "0\(day)".suffix(2)
                    let hourString = "0\(hour)".suffix(2)
                    let minuteString = "0\(minute)".suffix(2)
                    let dateStr = "\(year)-\(monthString)-\(dayString)"
                    let time = "\(hourString):\(minuteString)"
                    return "\(dateStr) \(time)"
                }

                public func asDate(timeZoneDelta: Int) -> Date? {
                    let calendar = Calendar(identifier: .gregorian)
                    let components = DateComponents(
                        calendar: calendar,
                        timeZone: TimeZone(secondsFromGMT: timeZoneDelta * 3600),
                        year: year,
                        month: month,
                        day: day,
                        hour: hour,
                        minute: minute
                    )
                    return calendar.date(from: components)
                }

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case year, month, day, hour, minute, second
                }
            }

            public let scheduleID: String
            public let startTime: String
            public let endTime: String
            public let startDateTime: SODateComponents?
            public let endDateTime: SODateComponents?
            public let isValid: Bool
            public let name: String

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case scheduleID = "schedule_id"
                case startTime = "start_time"
                case endTime = "end_time"
                case startDateTime = "start_date_time"
                case endDateTime = "end_date_time"
                case isValid = "is_valid"
                case name
            }
        }

        public struct ModeData: AbleToCodeSendHash {
            // MARK: Public

            public struct Best: AbleToCodeSendHash {
                // MARK: Public

                public let difficulty: Int
                public let second: Int
                public let icon: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case difficulty, second, icon
                }
            }

            public struct Challenge: AbleToCodeSendHash {
                // MARK: Public

                public struct TeamAvatar: AbleToCodeSendHash {
                    // MARK: Public

                    public let avatarID: Int
                    public let name: String
                    public let element: String
                    public let image: String
                    public let level: Int
                    public let rarity: Int
                    public let rank: Int

                    // MARK: Internal

                    enum CodingKeys: String, CodingKey {
                        case avatarID = "avatar_id"
                        case name, element, image, level, rarity, rank
                    }
                }

                public struct BestAvatar: AbleToCodeSendHash {
                    // MARK: Public

                    public let avatarID: Int
                    public let sideIcon: String
                    public let dps: String
                    public let type: Int

                    // MARK: Internal

                    enum CodingKeys: String, CodingKey {
                        case avatarID = "avatar_id"
                        case sideIcon = "side_icon"
                        case dps, type
                    }
                }

                public struct Monster: AbleToCodeSendHash {
                    // MARK: Public

                    public struct MonsterTag: AbleToCodeSendHash {
                        // MARK: Public

                        public let type: Int
                        public let desc: String

                        // MARK: Internal

                        enum CodingKeys: String, CodingKey {
                            case type, desc
                        }
                    }

                    public let name: String
                    public let level: Int
                    public let icon: String
                    public let desc: [String]
                    public let tags: [MonsterTag]
                    public let monsterID: Int

                    // MARK: Internal

                    enum CodingKeys: String, CodingKey {
                        case name, level, icon, desc, tags
                        case monsterID = "monster_id"
                    }
                }

                public let name: String
                public let second: Int
                public let crew: [TeamAvatar]
                public let bestAvatar: [BestAvatar]
                public let monster: Monster

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case name, second, monster
                    case crew = "teams"
                    case bestAvatar = "best_avatar"
                }
            }

            public let best: Best?
            public let challenge: [Challenge]
            public let hasData: Bool

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case best, challenge
                case hasData = "has_data"
            }
        }

        public let schedule: Schedule
        public let single: ModeData
        public let mp: ModeData
        public let blings: [String]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case schedule, single, mp, blings
        }
    }
}

extension [HoYo.BattleReport4GI.StygianOnslaughtData.ModeData.Challenge] {
    var bestAvatarForSingleStrike: HoYo.BattleReport4GI.StygianOnslaughtData.ModeData.Challenge.BestAvatar? {
        let sortedSelf = sorted {
            guard $0.bestAvatar.count >= 2, $1.bestAvatar.count >= 2 else { return false }
            return (Int($0.bestAvatar[0].dps) ?? 0) < (Int($1.bestAvatar[0].dps) ?? 0)
        }
        guard let bestAvatars = sortedSelf.last?.bestAvatar else { return nil }
        guard bestAvatars.count >= 2 else { return nil }
        return bestAvatars[0]
    }

    var bestAvatarForTotalDMG: HoYo.BattleReport4GI.StygianOnslaughtData.ModeData.Challenge.BestAvatar? {
        let sortedSelf = sorted {
            guard $0.bestAvatar.count >= 2, $1.bestAvatar.count >= 2 else { return false }
            return (Int($0.bestAvatar[1].dps) ?? 0) < (Int($1.bestAvatar[1].dps) ?? 0)
        }
        guard let bestAvatars = sortedSelf.last?.bestAvatar else { return nil }
        guard bestAvatars.count >= 2 else { return nil }
        return bestAvatars[1]
    }
}

extension HoYo.BattleReport4GI.StygianOnslaughtData.ModeData {
    func summarizedIntoCells(oddCellsPerLine: Bool = false) -> [AbyssValueCell] {
        var result = [AbyssValueCell]()
        if oddCellsPerLine {
            result.append(
                AbyssValueCell(
                    value: "Lv." + (best?.difficulty.description ?? "N/A"),
                    description: (best?.second.description ?? "N/A") + "s " + "hylKit.battleReport.gi.stat.secondsSpent"
                        .i18nHYLKit
                )
            )
        } else {
            result.append(
                AbyssValueCell(
                    value: best?.difficulty.description ?? "N/A",
                    description: "hylKit.battleReport.gi.stat.deepest"
                )
            )
            result.append(
                AbyssValueCell(
                    value: best?.second.description ?? "N/A",
                    description: "hylKit.battleReport.gi.stat.secondsSpent"
                )
            )
        }
        let bestAvatarForSingleStrike = challenge.bestAvatarForSingleStrike
        if let bestAvatarForSingleStrike {
            result.append(
                AbyssValueCell(
                    value: bestAvatarForSingleStrike.dps,
                    description: "hylKit.battleReport.gi.stat.strongest",
                    avatarID: bestAvatarForSingleStrike.avatarID
                )
            )
        }
        let bestAvatarForTotalDMG = challenge.bestAvatarForTotalDMG
        if let bestAvatarForTotalDMG {
            result.append(
                AbyssValueCell(
                    value: bestAvatarForTotalDMG.dps,
                    description: "hylKit.battleReport.gi.stat.maxRoomDMG",
                    avatarID: bestAvatarForTotalDMG.avatarID
                )
            )
        }
        return result
    }

    var allCharIDsEnumerated: Set<Int> {
        .init(
            challenge.map { currentFight in
                currentFight.crew.map(\.avatarID)
            }.flatMap(\.self)
        )
    }
}

extension HoYo.BattleReport4GI.StygianOnslaughtData {
    var allCharIDsEnumerated: Set<Int> {
        single.allCharIDsEnumerated.union(mp.allCharIDsEnumerated)
    }
}
