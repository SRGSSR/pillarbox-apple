//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public enum StreamingMethod: String, Decodable {
    case progressive = "PROGRESSIVE"
    case m3uPlaylist = "M3UPLAYLIST"
    case hls = "HLS"
    case hds = "HDS"
    case rtmp = "RTMP"
    case http = "HTTP"
    case https = "HTTPS"
    case dash = "DASH"
    case unknown = "UNKNOWN"

    static var supportedMethods: [StreamingMethod] {
        [.progressive, .m3uPlaylist, .hls, .http, .https]
    }
}
