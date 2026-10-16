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
}
