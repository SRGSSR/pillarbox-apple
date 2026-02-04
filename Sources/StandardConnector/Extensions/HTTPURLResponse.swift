//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension HTTPURLResponse {
    static func fixedLocalizedString(forStatusCode statusCode: Int) -> String {
        // The `localizedString(forStatusCode:)` method always returns the English version (FB5751726). We can still use
        // this string as key to retrieve the correct translation from CFNetwork. If the status code is invalid the method
        // always returns "Server error".
        coreNetworkLocalizedString(forKey: localizedString(forStatusCode: statusCode))
    }

    static func coreNetworkLocalizedString(forKey key: String) -> String {
        let missingKey = "pillarbox_missing_key"
        if let description = Bundle(identifier: "com.apple.CFNetwork")?.localizedString(forKey: key, value: missingKey, table: nil),
           description != missingKey {
            return description.capitalizingFirstLetter()
        }
        else {
            return String(localized: "Unknown error.", bundle: .module, comment: "Generic error message")
        }
    }
}

private extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }
}
