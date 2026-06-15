//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

extension MediaComposition {
    enum StreamingMethod: String, Decodable {
        case dash = "DASH"
        case hds = "HDS"
        case hls = "HLS"
        case m3uPlaylist = "M3UPLAYLIST"
        case progressive = "PROGRESSIVE"
        case rtmp = "RTMP"
        case unknown = "UNKNOWN"

        static let supportedMethods: [Self] = [.hls, .m3uPlaylist, .progressive]
    }
}
