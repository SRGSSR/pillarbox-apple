//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum YouTubeIdentifier {
    static func extract(from url: URL) -> String? {
        guard
            let match = try? Regex("https://(?:.*youtube.*v=|.*youtu.*/(?:embed/)*(?:shorts/)*)([\\w-]+)").firstMatch(in: url.absoluteString),
            let identifier = match[1].substring else {
            return nil
        }
        return String(identifier)
    }
}
