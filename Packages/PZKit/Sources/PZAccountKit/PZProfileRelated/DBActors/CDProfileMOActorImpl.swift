// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZProfileCDMOBackports

extension CDProfileMOActor {
    public static var shared: CDProfileMOActor? {
        guard case let .success(result) = singleton else { return nil }
        return result
    }

    public static let singleton: Result<CDProfileMOActor, Error> = {
        let useGroupContainer = Defaults[.situatePZProfileDBIntoGroupContainer]
        do {
            let result = try CDProfileMOActor(
                persistence: .cloud,
                backgroundContext: true,
                useGroupContainer: useGroupContainer
            )
            return .success(result)
        } catch let firstError {
            #if DEBUG
            print("----------------")
            print("CDProfileMOActor failed from booting with useGroupContainer: \(useGroupContainer).")
            print(firstError)
            print("----------------")
            #endif
            guard useGroupContainer else { return .failure(firstError) }
            // Defaults[.situatePZProfileDBIntoGroupContainer] = false
            do {
                let result = try CDProfileMOActor(
                    persistence: .cloud,
                    backgroundContext: true,
                    useGroupContainer: false
                )
                return .success(result)
            } catch let secondError {
                #if DEBUG
                print("----------------")
                print("CDProfileMOActor failed from final booting.")
                print("This attempt doesn't use useGroupContainer.")
                print(secondError)
                print("----------------")
                #endif
                return .failure(secondError)
            }
        }
    }()
}
