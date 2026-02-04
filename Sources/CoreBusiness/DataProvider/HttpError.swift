//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Http error.
public struct HttpError: LocalizedError {
    /// A code.
    public let statusCode: Int

    /// A readable error description.
    public let errorDescription: String?

    init?(statusCode: Int) {
        guard statusCode >= 400 else { return nil }
        self.statusCode = statusCode
        self.errorDescription = HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode)
    }

    init?(response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        self.init(statusCode: httpResponse.statusCode)
    }
}
