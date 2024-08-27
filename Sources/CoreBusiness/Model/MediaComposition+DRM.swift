//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public extension MediaComposition {
    /// A DRM protection description.
    struct DRM: Decodable {
        /// A DRM type.
        public enum `Type`: String, Decodable {
            /// FairPlay.
            case fairPlay = "FAIRPLAY"

            /// PlayReady.
            case playReady = "PLAYREADY"

            /// Widevine.
            case widevine = "WIDEVINE"
        }

        /// The DRM type.
        let type: `Type`

        /// The certificate URL.
        let certificateUrl: URL?
    }
}
