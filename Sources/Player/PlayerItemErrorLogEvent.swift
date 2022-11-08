//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayerItemErrorLogEvent {
    static func friendlyComment(from comment: String?) -> String? {
        // For some reason extended delimiters are currently required for compilation to succeed in Swift Packages.
        let regex = #/.* \(.* error -?\d+ - (.*)\)/#
        guard let comment, let result = try? regex.wholeMatch(in: comment) else { return comment }
        return String(result.1)
    }

    var friendlyErrorComment: String? {
        ""
    }
}
