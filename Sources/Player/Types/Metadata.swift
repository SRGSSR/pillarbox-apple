//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension Player {
    struct Metadata: Equatable {
        // FIXME: Make NowPlayingInfo a proper equatable type, then remove
        public static func == (lhs: Player.Metadata, rhs: Player.Metadata) -> Bool {
            NSDictionary(dictionary: lhs.mediaItemInfo).isEqual(to: rhs.mediaItemInfo) && lhs.metadataItems == rhs.metadataItems
        }
        
        static let empty = Self.init(mediaItemInfo: .init(), metadataItems: [])

        public let mediaItemInfo: NowPlayingInfo
        public let metadataItems: [AVMetadataItem]
    }
}
