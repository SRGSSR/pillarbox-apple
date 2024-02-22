//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Foundation

typealias EmptyAsset = Asset<Never>

struct StructError: LocalizedError {
    var errorDescription: String? {
        "Struct error description"
    }
}

extension UUID {
    init(_ char: Character) {
        self.init(
            uuidString: """
            \(String(repeating: char, count: 8))\
            -\(String(repeating: char, count: 4))\
            -\(String(repeating: char, count: 4))\
            -\(String(repeating: char, count: 4))\
            -\(String(repeating: char, count: 12))
            """
        )!
    }
}

func beEqual(_ lhsError: Error?, _ rhsError: Error?) -> Bool {
    lhsError as? NSError == rhsError as? NSError
}
