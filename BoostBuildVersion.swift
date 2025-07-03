#!/usr/bin/env swift

// This script is initially migrated (from the vChewing Project) by Shiki Suen.

import Cocoa

extension String {
    fileprivate mutating func regReplace(pattern: String, replaceWith: String = "") {
        // Ref: https://stackoverflow.com/a/40993403/4162914 && https://stackoverflow.com/a/71291137/4162914
        do {
            let regex = try NSRegularExpression(
                pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines]
            )
            let range = NSRange(startIndex..., in: self)
            self = regex.stringByReplacingMatches(
                in: self, options: [], range: range, withTemplate: replaceWith
            )
        } catch { return }
    }
}

func gitCommitCount(branch: String = "main") throws -> Int {
    let process = Process()
    let pipe = Pipe()

    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["git", "rev-list", "--count", branch]
    process.standardOutput = pipe
    process.standardError = pipe

    try process.run()
    process.waitUntilExit()

    if process.terminationStatus != 0 {
        throw NSError(domain: "GitError", code: Int(process.terminationStatus), userInfo: [
            NSLocalizedDescriptionKey: "Failed to get commit count for branch \(branch)",
        ])
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
          let count = Int(output) else {
        throw NSError(domain: "ParseError", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Failed to parse commit count output",
        ])
    }

    return count
}

func process(_ dirXcodeProjectFile: String) {
    var verBuild: String
    var verMarket: String?
    do {
        var intVerBuild = try gitCommitCount()
        intVerBuild += 3041
        verBuild = intVerBuild.description
    } catch {
        print("Failed to get Git Revision Number.")
        exit(1)
    }

    if CommandLine.arguments.count == 2 {
        verMarket = CommandLine.arguments[1]
    }
    var strXcodeProjContent = ""

    // Xcode project file version update.
    do {
        strXcodeProjContent += try String(contentsOfFile: dirXcodeProjectFile, encoding: .utf8)
    } catch {
        NSLog(" - Exception happened when reading raw phrases data.")
    }

    strXcodeProjContent.regReplace(
        pattern: #"CURRENT_PROJECT_VERSION = .*$"#, replaceWith: "CURRENT_PROJECT_VERSION = " + verBuild + ";"
    )
    if let verMarket {
        strXcodeProjContent.regReplace(
            pattern: #"MARKETING_VERSION = .*$"#, replaceWith: "MARKETING_VERSION = " + verMarket + ";"
        )
    }

    do {
        try strXcodeProjContent.write(to: URL(fileURLWithPath: dirXcodeProjectFile), atomically: false, encoding: .utf8)
    } catch {
        NSLog(" -: Error on writing strings to file: \(error)")
    }

    NSLog(" - Xcode 專案版本資訊更新完成：\(verBuild)。")
}

process("./UnitedPizzaHelper.xcodeproj/project.pbxproj")
