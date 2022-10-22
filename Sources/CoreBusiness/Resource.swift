//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Player

struct Resource: Decodable {
    enum CodingKeys: String, CodingKey {
        case url
        case streamingMethod = "streaming"
        case isDvr = "dvr"
        case isLive = "live"
    }

    let url: URL
    let streamingMethod: StreamingMethod

    private let isDvr: Bool
    private let isLive: Bool

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
}
