//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public struct MapperAdapter<M> {
    private let mapper: any MetadataMapper
    private let update: (M) -> Void

    public init<T>(mapperType: T.Type) where T: MetadataMapper, T.Metadata == M {
        let mapper = mapperType.init()
        update = { metadata in
            mapper.update(metadata: metadata)
        }
        self.mapper = mapper
    }

    public static func empty() -> Self {
        EmptyMapper.adapter()
    }

    func update(metadata: M) {
        update(metadata)
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        mapper.mediaItemInfo(with: error)
    }

    func metadataItems() -> [AVMetadataItem] {
        mapper.metadataItems()
    }

    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        mapper.navigationMarkerGroups()
    }
}
