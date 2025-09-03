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

/// Data error.
public enum DataError: LocalizedError {
    /// Blocked content.
    case blocked(reason: MediaComposition.BlockingReason)

    /// HTTP error.
    case http(statusCode: Int)

    /// Missing resource.
    case noResourceAvailable

    // swiftlint:disable:next missing_docs
    public var errorDescription: String? {
        switch self {
        case let .blocked(reason):
            reason.description
        case let .http(statusCode):
            HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode)
        case .noResourceAvailable:
            String(
                localized: "No playable resources could be found.",
                bundle: .module,
                comment: "Generic error message returned when no playable resources could be found"
            )
        }
    }

    static func http(from response: URLResponse) -> Self? {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        return http(withStatusCode: httpResponse.statusCode)
    }

    static func http(withStatusCode statusCode: Int) -> Self? {
        statusCode >= 400 ? .http(statusCode: statusCode) : nil
    }
}
