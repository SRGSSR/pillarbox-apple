//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

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
