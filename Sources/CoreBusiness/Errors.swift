//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DRMError: Error {
    case missingContentKeyContext
}

enum TokenError: Error {
    case malformedParameters
}

struct DataError: LocalizedError {
    static var noResourceAvailable: Self {
        DataError(errorDescription: NSLocalizedString(
            "No playable resources could be found",
            comment: "Generic error message returned when no playable resources could be found"
        ))
    }

    let errorDescription: String?

    static func http(from response: URLResponse) -> Self? {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        return http(withStatusCode: httpResponse.statusCode)
    }

    static func http(withStatusCode statusCode: Int) -> Self? {
        guard statusCode >= 400 else { return nil }
        return DataError(errorDescription: HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode))
    }

    static func blocked(withMessage message: String) -> Self {
        DataError(errorDescription: message)
    }
}
