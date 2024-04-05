//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerMetadata: Equatable {
    static let empty = Self(nowPlayingInfo: .init(), items: [], chapterGroups: [])

    public let nowPlayingInfo: NowPlayingInfo
    public let items: [AVMetadataItem]
    public let chapterGroups: [AVTimedMetadataGroup]

    public static func == (lhs: Self, rhs: Self) -> Bool {
        // swiftlint:disable:next legacy_objc_type
        NSDictionary(dictionary: lhs.nowPlayingInfo).isEqual(to: rhs.nowPlayingInfo) && lhs.items == rhs.items
    }
}
