//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerMetadata: Equatable {
    static let empty = Self(nowPlayingInfo: .init(), metadataItems: [])

    public let nowPlayingInfo: NowPlayingInfo
    public let metadataItems: [AVMetadataItem]

    public static func == (lhs: Self, rhs: Self) -> Bool {
        // swiftlint:disable:next legacy_objc_type
        NSDictionary(dictionary: lhs.nowPlayingInfo).isEqual(to: rhs.nowPlayingInfo) && lhs.metadataItems == rhs.metadataItems
    }
}
