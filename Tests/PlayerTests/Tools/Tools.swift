//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation

typealias EmptyAsset = Asset<Never>

struct StructError: LocalizedError {
    var errorDescription: String? {
        "Struct error description"
    }
}

enum PlayerError {
    static var resourceNotFound: NSError {
        NSError(
            domain: URLError.errorDomain,
            code: URLError.fileDoesNotExist.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: "The requested URL was not found on this server.",
                NSUnderlyingErrorKey: NSError(
                    domain: "CoreMediaErrorDomain",
                    code: -12938,
                    userInfo: [
                        "NSDescription": "HTTP 404: File Not Found"
                    ]
                )
            ]
        )
    }

    static var segmentNotFound: NSError {
        NSError(
            domain: "CoreMediaErrorDomain",
            code: -12938,
            userInfo: [
                NSLocalizedDescriptionKey: "HTTP 404: File Not Found"
            ]
        )
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
