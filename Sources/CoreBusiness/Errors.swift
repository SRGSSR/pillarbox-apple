//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DataError: LocalizedError {
    let errorDescription: String?

    static var notFound: Self {
        DataError(errorDescription: NSLocalizedString(
            "The content cannot be played",
            comment: "Generic error message when some content cannot be played")
        )
    }

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
