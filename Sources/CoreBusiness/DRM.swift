//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Describes DRM protection.
public struct DRM: Decodable {
    /// DRM types.
    public enum `Type`: String, Decodable {
        /// FairPlay.
        case fairPlay = "FAIRPLAY"
        /// Playready.
        case playReady = "PLAYREADY"
        /// Widevine.
        case widevine = "WIDEVINE"
    }

    /// The DRM type.
    let type: `Type`

    /// The certificate URL.
    let certificateUrl: URL?

    /// The license URL.
    let licenseUrl: URL
}
