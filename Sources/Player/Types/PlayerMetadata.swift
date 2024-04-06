//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerMetadata: Equatable {
    public struct Data: Equatable {
        static let empty = Self(nowPlayingInfo: .init(), items: [], timedGroups: [], chapterGroups: [])

        public let nowPlayingInfo: NowPlayingInfo

        public let items: [AVMetadataItem]
        public let timedGroups: [AVTimedMetadataGroup]
        public let chapterGroups: [AVTimedMetadataGroup]

        // TODO: Remove when NowPlayingInfo not contained anymore.
        public static func == (lhs: Self, rhs: Self) -> Bool {
            // swiftlint:disable:next legacy_objc_type
            NSDictionary(dictionary: lhs.nowPlayingInfo).isEqual(to: rhs.nowPlayingInfo)
                && lhs.items == rhs.items && lhs.timedGroups == rhs.timedGroups && lhs.chapterGroups == rhs.chapterGroups
        }
    }

    static let empty = Self(content: .empty, resource: .empty)

    public var nowPlayingInfo: NowPlayingInfo {
        content.nowPlayingInfo
    }

    public let content: Data
    public let resource: Data
}
