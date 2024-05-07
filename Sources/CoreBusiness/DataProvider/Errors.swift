//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DRMError: LocalizedError {
    static let missingContentKeyContext = Self(errorDescription: "The DRM license could not be retrieved")

    let errorDescription: String?
}

enum TokenError: Error {
    case malformedParameters
}

struct DataError: LocalizedError {
    static let noResourceAvailable = Self(errorDescription: String(
        localized: "No playable resources could be found.",
        bundle: .module,
        comment: "Generic error message returned when no playable resources could be found"
    ))

    static let malformedData = Self(errorDescription: String(
        localized: "The data is invalid.",
        bundle: .module,
        comment: "Generic error message returned when data is invalid"
    ))

    let errorDescription: String?

    static func http(from response: URLResponse) -> Self? {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        return http(withStatusCode: httpResponse.statusCode)
    }

    static func http(withStatusCode statusCode: Int) -> Self? {
        guard statusCode >= 400 else { return nil }
        return .init(errorDescription: HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode))
    }

    static func blocked(withMessage message: String) -> Self {
        .init(errorDescription: message)
    }
}
