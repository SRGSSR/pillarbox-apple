//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

struct Resource: Decodable {
    enum CodingKeys: String, CodingKey {
        case drms = "drmList"
        case isDvr = "dvr"
        case isLive = "live"
        case streamingMethod = "streaming"
        case tokenType
        case url
    }

    let url: URL
    let streamingMethod: StreamingMethod

    var streamType: StreamType {
        if isDvr {
            return .dvr
        }
        else if isLive {
            return .live
        }
        else {
            return .onDemand
        }
    }

    let tokenType: TokenType
    let drms: [DRM]?

    private let isDvr: Bool
    private let isLive: Bool
}
