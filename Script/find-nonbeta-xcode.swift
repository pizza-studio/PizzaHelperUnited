#!/usr/bin/env swift
// find-nonbeta-xcode.swift
// 尋找 /Applications 內最高版本的 non-beta Xcode。
// 觸發條件：當前 /Applications/Xcode.app 的 Resources 內存在 XcodeBeta.icns。
// 若當前 Xcode 並非 beta，則直接輸出其路徑，無需掃描。

import Foundation

let fileManager = FileManager.default
let applicationsDir = "/Applications"
let defaultXcodePath = "\(applicationsDir)/Xcode.app"
let defaultBetaIconPath = "\(defaultXcodePath)/Contents/Resources/XcodeBeta.icns"

/// 判斷一個 Xcode bundle 是否為 beta。
/// 檢查順序：LicenseInfo.plist 的 licenseType → XcodeBeta.icns → CFBundleShortVersionString 關鍵字。
func isBetaBundle(at path: String) -> Bool {
    // 最可靠：LicenseInfo.plist 的 licenseType
    let licenseInfoPath = "\(path)/Contents/Resources/LicenseInfo.plist"
    if let licenseInfo = NSDictionary(contentsOfFile: licenseInfoPath),
       let licenseType = licenseInfo["licenseType"] as? String,
       licenseType == "Beta" {
        return true
    }

    // 備援：XcodeBeta.icns
    let betaIconPath = "\(path)/Contents/Resources/XcodeBeta.icns"
    if fileManager.fileExists(atPath: betaIconPath) {
        return true
    }

    // 備援：CFBundleShortVersionString 關鍵字
    let infoPlistPath = "\(path)/Contents/Info.plist"
    if let infoPlist = NSDictionary(contentsOfFile: infoPlistPath),
       let versionStr = infoPlist["CFBundleShortVersionString"] as? String {
        let lowercased = versionStr.lowercased()
        let betaKeywords = ["beta", "preview", "seed", "developer preview"]
        for keyword in betaKeywords {
            if lowercased.contains(keyword) {
                return true
            }
        }
    }

    return false
}

// 若當前 Xcode 並非 beta，直接使用
guard isBetaBundle(at: defaultXcodePath) else {
    print(defaultXcodePath)
    exit(0)
}

// MARK: - XcodeBundle

// 當前 Xcode 是 beta，掃描其他 Xcode*.app
struct XcodeBundle {
    let path: String
    let version: String
    let versionComponents: [Int]
}

var candidates: [XcodeBundle] = []

guard let contents = try? fileManager.contentsOfDirectory(atPath: applicationsDir) else {
    print(defaultXcodePath)
    exit(0)
}

for item in contents {
    guard item.hasPrefix("Xcode"), item.hasSuffix(".app") else { continue }
    let bundlePath = "\(applicationsDir)/\(item)"

    // 確認有 Xcode binary
    let binaryPath = "\(bundlePath)/Contents/MacOS/Xcode"
    guard fileManager.fileExists(atPath: binaryPath) else { continue }

    // 跳過 beta 版本
    if isBetaBundle(at: bundlePath) { continue }

    // 取得版本號
    let infoPlistPath = "\(bundlePath)/Contents/Info.plist"
    guard let infoPlist = NSDictionary(contentsOfFile: infoPlistPath),
          let version = infoPlist["CFBundleShortVersionString"] as? String else { continue }

    let components = version.split(separator: ".").compactMap { Int($0) }
    guard !components.isEmpty else { continue }

    candidates.append(XcodeBundle(
        path: bundlePath,
        version: version,
        versionComponents: components
    ))
}

// 按版本降冪排序（最高版本在前）
candidates.sort { a, b in
    let maxLen = max(a.versionComponents.count, b.versionComponents.count)
    for i in 0 ..< maxLen {
        let av = i < a.versionComponents.count ? a.versionComponents[i] : 0
        let bv = i < b.versionComponents.count ? b.versionComponents[i] : 0
        if av != bv { return av > bv }
    }
    return false
}

if let best = candidates.first {
    fputs("info: 已選取 non-beta Xcode \(best.version) 用於封存: \(best.path)\n", stderr)
    print(best.path)
} else {
    fputs("warning: 未找到 non-beta Xcode，將使用當前 beta 版本: \(defaultXcodePath)\n", stderr)
    print(defaultXcodePath)
}
