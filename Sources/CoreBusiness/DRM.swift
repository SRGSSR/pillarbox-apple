//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct DRM: Decodable {
    enum `Type`: String, Decodable {
        case fairPlay = "FAIRPLAY"
        case playReady = "PLAYREADY"
        case widevine = "WIDEVINE"
    }

    let type: `Type`
    let certificateUrl: URL?
    let licenseUrl: URL
}
