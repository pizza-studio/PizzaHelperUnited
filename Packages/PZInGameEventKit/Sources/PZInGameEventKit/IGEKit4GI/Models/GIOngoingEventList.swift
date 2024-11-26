// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - GIOngoingEvents

public enum GIOngoingEvents {
    public struct EventList: AbleToCodeSendHash, Equatable {
        // MARK: Lifecycle

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: EventKey.self)

            var events = [String: EventModel]()
            for key in container.allKeys {
                if let model = try? container.decode(EventModel.self, forKey: key) {
                    events[key.stringValue] = model
                }
            }
            self.event = events
        }

        // MARK: Public

        public struct EventKey: CodingKey {
            // MARK: Lifecycle

            public init?(stringValue: String) {
                self.stringValue = stringValue
            }

            public init?(intValue: Int) {
                self.stringValue = "\(intValue)"
                self.intValue = intValue
            }

            // MARK: Public

            public var stringValue: String
            public var intValue: Int?
        }

        public var event: [String: EventModel]
    }
}

// MARK: - GIOngoingEvents.EventList.EventModel

extension GIOngoingEvents.EventList {
    public struct EventModel: AbleToCodeSendHash, Identifiable {
        public struct MultiLanguageContents: AbleToCodeSendHash {
            public var EN: String
            public var RU: String
            public var CHS: String
            public var CHT: String
            public var KR: String
            public var JP: String
        }

        public var id: Int
        public var name: MultiLanguageContents
        public var nameFull: MultiLanguageContents
        public var description: MultiLanguageContents
        public var banner: MultiLanguageContents
        public var endAt: String
    }
}
