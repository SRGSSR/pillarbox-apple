//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MalformedHLSError: Error {}

enum HLSParser {
    static func extractKeyAttributes(from string: String) throws -> [String: String] {
        try string.unquotedComponents(separatedBy: ",").reduce(into: [:]) { attributes, attribute in
            let components = attribute.components(separatedBy: "=")
            guard components.count >= 2 else { throw MalformedHLSError() }
            let value = components.suffix(from: 1).joined(separator: "=")
            guard !value.isEmpty else { throw MalformedHLSError() }
            attributes[components[0]] = value
        }
    }

    static func extractKeyUrls(from string: String) throws -> [URL] {
        try string.matches(of: #/#EXT-X-(?:SESSION-)?KEY:(?<attributes>.*)/#).compactMap { match in
            let attributes = try extractKeyAttributes(from: String(match.output.attributes))
            guard let method = attributes["METHOD"], method == "AES-128",
                  let uri = attributes["URI"], let urlComponents = URLComponents(string: uri), ["http", "https"].contains(urlComponents.scheme) else {
                return nil
            }
            return urlComponents.url
        }
    }
}
