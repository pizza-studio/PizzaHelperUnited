// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - GIOngoingEvents.Exception

extension GIOngoingEvents {
    public enum Exception: Error, LocalizedError {
        case dataRetrievalException(Error)

        // MARK: Public

        public var localizedDescription: String {
            switch self {
            case let .dataRetrievalException(error):
                "GIOngoingEvents.dataRetrievalException: \(error)"
            }
        }

        public var errorDescription: String? { localizedDescription }

        public var description: String { localizedDescription }
    }
}

extension GIOngoingEvents {
    public static func fetch() async -> Result<Self.EventList, Self.Exception> {
        let urlStr = "https://gi.yatta.moe/assets/data/event.json"
        do {
            let (data, _) = try await URLSession.shared.data(from: urlStr.asURL)
            let decoded = try JSONDecoder().decode(Self.EventList.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(Self.Exception.dataRetrievalException(error))
        }
    }

    public static func getRemainDays(_ endAt: String) -> Date.IntervalDate? {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let cachedServerRawValue = Defaults[.defaultServer]
        let cachedServerTyped = HoYo.Server(rawValue: cachedServerRawValue) ?? .asia(.genshinImpact)
        dateFormatter.timeZone = cachedServerTyped.timeZone
        let endDate = dateFormatter.date(from: endAt)
        guard let endDate = endDate else {
            return nil
        }
        let interval = endDate - Date()
        return interval
    }
}
