//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum DataError: Error {
    case notFound
}

extension NSError {
    static func httpError(from response: URLResponse) -> NSError? {
        guard let httpResponse = response as? HTTPURLResponse else { return nil }
        return httpError(withStatusCode: httpResponse.statusCode)
    }

    // Only errors with codes different from zero can be properly forwarded through the resource loader. The status
    // code is therefore a natural choice for HTTP errors in a common dedicated domain.
    static func httpError(withStatusCode statusCode: Int) -> NSError? {
        guard statusCode >= 400 else { return nil }
        return Self.init(domain: "ch.srgssr.pillarbox.core_business.network", code: statusCode, userInfo: [
            NSLocalizedDescriptionKey: HTTPURLResponse.fixedLocalizedString(forStatusCode: statusCode)
        ])
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
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
            return "Unknown error"
        }
    }
}
