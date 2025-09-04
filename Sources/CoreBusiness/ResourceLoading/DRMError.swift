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
