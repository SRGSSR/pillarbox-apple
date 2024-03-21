//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension Player {
    struct Metadata {
        static let empty = Self.init(mediaItemInfo: .init(), metadataItems: [], navigationMarkerGroups: [])

        public let mediaItemInfo: NowPlayingInfo
        public let metadataItems: [AVMetadataItem]
        public let navigationMarkerGroups: [AVTimedMetadataGroup]
    }
}
