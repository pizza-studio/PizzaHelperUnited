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

func process(_ dirXcodeProjectFile: String) {
    var verMarket = "1.0.0"
    var verBuild = "1000"
    var strXcodeProjContent = ""

    if CommandLine.arguments.count == 3 {
        verMarket = CommandLine.arguments[1]
        verBuild = CommandLine.arguments[2]

        // Xcode project file version update.
        do {
            strXcodeProjContent += try String(contentsOfFile: dirXcodeProjectFile, encoding: .utf8)
        } catch {
            NSLog(" - Exception happened when reading raw phrases data.")
        }

        strXcodeProjContent.regReplace(
            pattern: #"CURRENT_PROJECT_VERSION = .*$"#, replaceWith: "CURRENT_PROJECT_VERSION = " + verBuild + ";"
        )
        strXcodeProjContent.regReplace(
            pattern: #"MARKETING_VERSION = .*$"#, replaceWith: "MARKETING_VERSION = " + verMarket + ";"
        )
        do {
            try strXcodeProjContent.write(
                to: URL(fileURLWithPath: dirXcodeProjectFile),
                atomically: false,
                encoding: .utf8
            )
        } catch {
            NSLog(" -: Error on writing strings to file: \(error)")
        }
        NSLog(" - Xcode 專案版本資訊更新完成：\(verMarket) \(verBuild)。")
    }
}

process("./UnitedPizzaHelper.xcodeproj/project.pbxproj")
