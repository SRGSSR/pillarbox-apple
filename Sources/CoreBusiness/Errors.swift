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

private extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}

private extension HTTPURLResponse {
    static func fixedLocalizedString(forStatusCode statusCode: Int) -> String {
        // The `localizedString(forStatusCode:)` method always returns the English version, which we use as localization key
        let key = localizedString(forStatusCode: statusCode)
        if let description = Bundle(identifier: "com.apple.CFNetwork")?.localizedString(forKey: key, value: nil, table: nil) {
            return description.capitalizingFirstLetter()
        }
        else {
            return NSLocalizedString("Unknown error", comment: "Generic error message")
        }
    }
}
