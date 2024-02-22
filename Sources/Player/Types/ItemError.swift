//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum ItemError {
    /// Consolidates intrinsic error and error log information.
    static func intrinsicError(for item: AVPlayerItem) -> Error {
        if let errorLog = item.errorLog(), let event = errorLog.events.last {
            return NSError(
                domain: event.errorDomain,
                code: event.errorStatusCode,
                userInfo: userInfo(for: event)
            )
        }
        else if let error = item.error {
            return localizedError(from: error)
        }
        else {
            return PlaybackError.unknown
        }
    }

    static func localizedError(from error: Error) -> Error {
        let bridgedError = error as NSError
        var userInfo = bridgedError.userInfo

        // Errors returned through `AVAssetResourceLoader` do not apply correct error localization rules. Fix.
        let descriptionKey = "NSDescription"
        if let description = userInfo[descriptionKey] {
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[descriptionKey] = nil
        }

        return NSError(domain: bridgedError.domain, code: bridgedError.code, userInfo: userInfo)
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
