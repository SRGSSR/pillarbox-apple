//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension MediaComposition {
    /// A streaming method description.
    enum StreamingMethod: String, Decodable {
        /// Progressive streaming.
        case progressive = "PROGRESSIVE"

        /// M3U8 streaming.
        case m3uPlaylist = "M3UPLAYLIST"

        /// HTTP Live Streaming.
        case hls = "HLS"

        /// HDS streaming.
        case hds = "HDS"

        /// Real-Time Messaging Protocol.
        case rtmp = "RTMP"

        /// Streaming served over HTTP.
        case http = "HTTP"

        /// Streaming served over HTTPS.
        case https = "HTTPS"

        /// Dynamic Adaptive Streaming over HTTP.
        case dash = "DASH"

        /// Unknown.
        case unknown = "UNKNOWN"

        /// The supported streaming methods on Apple platforms.
        public static let supportedMethods: [Self] = [.hls, .https, .http, .m3uPlaylist, .progressive]
    }
}
