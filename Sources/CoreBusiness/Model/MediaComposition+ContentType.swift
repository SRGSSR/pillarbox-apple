//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension MediaComposition {
    /// Content types.
    enum ContentType: String, Decodable {
        /// Episode.
        case episode = "EPISODE"

        /// Extract.
        case extract = "EXTRACT"

        /// Trailer.
        case trailer = "TRAILER"

        /// Clip.
        case clip = "CLIP"

        /// Livestream.
        case livestream = "LIVESTREAM"

        /// Scheduled livestream.
        case scheduledLivestream = "SCHEDULED_LIVESTREAM"
    }
}
