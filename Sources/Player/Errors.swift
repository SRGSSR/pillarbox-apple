//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum PlaybackError: Error {
    case unknown
}

extension Error {
    // Errors returned through `AVAssetResourceLoader` do not apply correct error localization rules. Fix.
    func localized() -> Error {
        let error = self as NSError
        var userInfo = error.userInfo
        let descriptionKey = "NSDescription"
        guard let description = userInfo[descriptionKey] else { return self }
        userInfo[NSLocalizedDescriptionKey] = description
        userInfo[descriptionKey] = nil
        return NSError(domain: error.domain, code: error.code, userInfo: userInfo)
    }
}
