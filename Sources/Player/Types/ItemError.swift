//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum ItemError {
    /// Consolidates intrinsic error and error log information.
    static func error(for item: AVPlayerItem) -> Error? {
        guard let nsError = item.error as? NSError else { return nil }
        if nsError.userInfo[NSLocalizedDescriptionKey] != nil {
            return nsError
        }
        else if let errorLog = item.errorLog(), let event = errorLog.events.last {
            return NSError(
                domain: event.errorDomain,
                code: event.errorStatusCode,
                userInfo: userInfo(for: event)
            )
        }
        else {
            return nsError
        }
    }

    static func innerComment(from comment: String?) -> String? {
        // For some reason extended delimiters are currently required for compilation to succeed in Swift Packages.
        let regex = #/[^\(\)]* \([^\(\)]* -?\d+ - (.*)\)/#
        guard let comment, let result = try? regex.wholeMatch(in: comment) else { return comment }
        return innerComment(from: String(result.1))
    }

    private static func userInfo(for event: AVPlayerItemErrorLogEvent) -> [String: Any] {
        guard let comment = innerComment(from: event.errorComment) else { return [:] }
        return [NSLocalizedDescriptionKey: comment]
    }
}
