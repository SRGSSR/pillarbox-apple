//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public struct MapperAdapter<M> {
    private let metadataMapper: any MetadataMapper
    private let update: (M) -> Void

    public init<T>(mapperType: T.Type, mapper: ((M) -> T.Metadata)?) where T: MetadataMapper {
        let metadataMapper = mapperType.init()
        update = { metadata in
            if let mapper {
                metadataMapper.update(metadata: mapper(metadata))
            }
        }
        self.metadataMapper = metadataMapper
    }

    public static func empty() -> Self {
        EmptyMapper.adapter()
    }

    func update(metadata: M) {
        update(metadata)
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        metadataMapper.mediaItemInfo(with: error)
    }

    func metadataItems() -> [AVMetadataItem] {
        metadataMapper.metadataItems()
    }

    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        metadataMapper.navigationMarkerGroups()
    }
}
