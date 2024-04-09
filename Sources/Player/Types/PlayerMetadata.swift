//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerMetadata {
    public struct Data {
        static let empty = Self(items: [], timedGroups: [], chapterGroups: [])

        public let items: [MetadataItem]
        public let timedGroups: [TimedMetadataGroup]
        public let chapterGroups: [TimedMetadataGroup]
    }

    static let empty = Self(content: .empty, resource: .empty)

    public let content: Data
    public let resource: Data

    public var items: [MetadataItem] {
        content.items + resource.items
    }

    public var timedGroups: [TimedMetadataGroup] {
        content.timedGroups + resource.timedGroups
    }

    public var chapterGroups: [TimedMetadataGroup] {
        content.chapterGroups + resource.chapterGroups
    }
}
