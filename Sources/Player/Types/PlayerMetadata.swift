//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerMetadata {
    struct Data {
        static let empty = Self(items: [], timedGroups: [], chapterGroups: [])

        let items: [MetadataItem]
        let timedGroups: [TimedMetadataGroup]
        let chapterGroups: [TimedMetadataGroup]
    }

    static let empty = Self(content: .empty, resource: .empty)

    let content: Data
    let resource: Data

    public var items: [MetadataItem] {
        !content.items.isEmpty ? content.items : resource.items
    }

    public var timedGroups: [TimedMetadataGroup] {
        !content.timedGroups.isEmpty ? content.timedGroups : resource.timedGroups
    }

    public var chapterGroups: [TimedMetadataGroup] {
        !content.chapterGroups.isEmpty ? content.chapterGroups : resource.chapterGroups
    }
}
