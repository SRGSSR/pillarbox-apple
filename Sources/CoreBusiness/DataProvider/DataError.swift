//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Data error.
public struct DataError: LocalizedError {
    /// The error type.
    public let kind: Kind

    /// A readable error description.
    public let errorDescription: String?
}

public extension DataError {
    /// Represents the type of data error.
    enum Kind {
        /// Missing resource.
        case noResourceAvailable

        /// Blocked content.
        case blocked(reason: MediaComposition.BlockingReason)

        /// HTTP error.
        case http(statusCode: Int)
    }
}

extension DataError {
    static var noResourceAvailable: Self {
        Self(kind: .noResourceAvailable, errorDescription: String(
            localized: "No playable resources could be found.",
            bundle: .module,
            comment: "Generic error message returned when no playable resources could be found"
        ))
    }

    static func blocked(reason: MediaComposition.BlockingReason) -> Self {
        Self(kind: .blocked(reason: reason), errorDescription: reason.description)
    }

    static func http(statusCode: Int) -> Self {
        Self(
            kind: .http(statusCode: statusCode),
            errorDescription: HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode)
        )
    }

    static func http(from response: URLResponse) -> Self? {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        return http(withStatusCode: httpResponse.statusCode)
    }

    static func http(withStatusCode statusCode: Int) -> Self? {
        statusCode >= 400 ? .http(statusCode: statusCode) : nil
    }
}
