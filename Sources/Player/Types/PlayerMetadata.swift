//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerMetadata: Equatable {
    static let empty = Self(mediaItemInfo: .init(), metadataItems: [])

    public let mediaItemInfo: NowPlayingInfo
    public let metadataItems: [AVMetadataItem]

    // FIXME: Make NowPlayingInfo a proper equatable type, then remove
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // swiftlint:disable:next legacy_objc_type
        NSDictionary(dictionary: lhs.mediaItemInfo).isEqual(to: rhs.mediaItemInfo) && lhs.metadataItems == rhs.metadataItems
    }
}
