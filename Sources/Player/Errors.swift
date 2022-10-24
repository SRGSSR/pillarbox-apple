//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum PlaybackError: Error {
    case unknown
}

extension Error {
    // Errors returned through `AVAssetResourceLoader` do not apply correct error localization rules. Fix.
    func localized() -> Error {
        let error = self as NSError
        var userInfo = error.userInfo
        let descriptionKey = "NSDescription"
        guard let description = userInfo[descriptionKey] else { return self }
        userInfo[NSLocalizedDescriptionKey] = description
        userInfo[descriptionKey] = nil
        return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
    }
}

extension NSError {
    private static func domain(from error: Error) -> String {
        (error as NSError).domain
    }

    private static func code(from error: Error) -> Int {
        (error as NSError).code
    }

    private static func userInfo(from error: Error) -> [String: Any] {
        // Returning (error as NSError).userInfo does not work
        let bridgedError = error as NSError
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = bridgedError.localizedDescription
        userInfo[NSLocalizedFailureReasonErrorKey] = bridgedError.localizedFailureReason
        userInfo[NSLocalizedRecoverySuggestionErrorKey] = bridgedError.localizedRecoverySuggestion
        userInfo[NSHelpAnchorErrorKey] = bridgedError.helpAnchor
        return userInfo
    }

    /// Convert any error to a true `NSError`. This is not the same as bridging an `Error` to `NSError` (which is
    /// always possible but is not equivalent).
    /// - Parameter error: The error to convert.
    /// - Returns: The converted error (or the provided error if already an `NSError`).
    static func error(from error: Error?) -> NSError? {
        guard let error else { return nil }
        guard type(of: error) != NSError.self else { return error as NSError }
        return Self(
            domain: domain(from: error),
            code: code(from: error),
            userInfo: userInfo(from: error)
        )
    }
}
