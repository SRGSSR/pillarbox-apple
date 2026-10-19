//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MalformedHLSError: Error {}

enum HLSParser {
    static func extractKeyUrls(from string: String) -> [URL] {
        let pattern = #/#EXT-X-(?:SESSION-)?KEY:(?=.*METHOD=AES-128).*URI="(?<url>https?[^"]+)"/#
        return string.matches(of: pattern)
            .map(\.output.url)
            .compactMap { URL(string: String($0)) }
    }

    static func replaceUrl(_ url: URL, with data: Data, in string: String) -> String {
        string.replacingOccurrences(of: url.absoluteString, with: URI.dataUri(for: data))
    }

    static func inlineAES128Keys(in string: String) async -> String {
        string
    }
}
