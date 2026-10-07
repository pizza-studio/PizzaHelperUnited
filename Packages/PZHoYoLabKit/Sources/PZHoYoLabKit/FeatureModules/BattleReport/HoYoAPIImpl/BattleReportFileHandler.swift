// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - BattleReportFileHandler

public enum BattleReportFileHandler {}

@available(iOS 17.0, macCatalyst 17.0, *)
extension BattleReportFileHandler {
    public enum SeasonScope: String {
        case current = "Current"
        case previous = "Previous"
        case bothSeasons = "BothSeasons"
    }

    /// 将战报 API 返回的原始 JSON 数据覆写存入硬碟，用于排障 JSON 解码层的故障。
    /// 每个（游戏 × 战报种类 × 赛季范围）组合只保留一份档案，每次获取都直接覆写。
    /// - Returns: 实际写入的档案路径。写入失败时回传 `nil`。
    @discardableResult
    public static func saveRawReportData(
        _ data: Data,
        game: Pizza.SupportedGame,
        reportType: String,
        seasonScope: SeasonScope
    )
        -> URL? {
        let fileURL = getURL4RawReport(game: game, reportType: reportType, seasonScope: seasonScope)
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileURL
        } catch {
            PZLog.error(
                "[BattleReportFileHandler] Failed to save raw battle report at \(fileURL.path): \(error)"
            )
            return nil
        }
    }

    /// We assume that this API never fails.
    public static var contentFolderURL: URL {
        let backgroundFolderURL: URL = {
            switch Pizza.isAppStoreRelease {
            case false: break
            case true:
                guard let groupContainerURL else { break }
                return groupContainerURL
                    .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                    .appendingPathComponent("CachedBattleReports", isDirectory: true)
            }
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                .appendingPathComponent("CachedBattleReports", isDirectory: true)
        }()

        try? FileManager.default.createDirectory(
            at: backgroundFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderURL
    }

    private static func getURL4RawReport(
        game: Pizza.SupportedGame,
        reportType: String,
        seasonScope: SeasonScope
    )
        -> URL {
        contentFolderURL.appendingPathComponent(
            "BattleReport-\(game.rawValue)-\(reportType)-\(seasonScope.rawValue).json",
            isDirectory: false
        )
    }
}
