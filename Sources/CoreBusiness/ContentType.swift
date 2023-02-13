//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

enum ContentType: String, Decodable {
    case episode = "EPISODE"
    case extract = "EXTRACT"
    case trailer = "TRAILER"
    case clip = "CLIP"
    case livestream = "LIVESTREAM"
    case scheduledLivestream = "SCHEDULED_LIVESTREAM"
}
