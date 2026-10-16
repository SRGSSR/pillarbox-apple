//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MalformedHLSError: Error {}

enum HLSParser {
    static func extractKeyAttributes(from string: String) throws -> [String: String] {
        try string.components(separatedBy: ",").reduce(into: [:]) { attributes, attribute in
            let components = attribute.components(separatedBy: "=")
            guard components.count == 2 else { throw MalformedHLSError() }
            attributes[components[0]] = components[1].trimmingCharacters(in: .init(charactersIn: "\""))
        }
    }

    static func extractKeyUrls(from string: String) -> [URL] {
        []
    }
}
