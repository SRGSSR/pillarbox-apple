//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public extension MediaComposition {
    /// Media types.
    enum MediaType: String, Decodable {
        /// Audio.
        case audio = "AUDIO"

        /// Video.
        case video = "VIDEO"
    }
}
