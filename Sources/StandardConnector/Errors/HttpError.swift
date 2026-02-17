//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An error representing an HTTP failure.
///
/// `HttpError` is created from an HTTP status code greater than or equal to 400.
public struct HttpError: LocalizedError {
    /// A code.
    public let statusCode: Int

    /// A readable error description.
    public let errorDescription: String?

    @_spi(StandardConnectorPrivate)
    public init?(statusCode: Int) {
        // swiftlint:disable:previous missing_docs
        guard statusCode >= 400 else { return nil }
        self.statusCode = statusCode
        self.errorDescription = HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode)
    }

    @_spi(StandardConnectorPrivate)
    public init?(response: URLResponse) {
        // swiftlint:disable:previous missing_docs
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        self.init(statusCode: httpResponse.statusCode)
    }
}
