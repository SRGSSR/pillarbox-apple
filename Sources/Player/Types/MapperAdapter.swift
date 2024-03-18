//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public struct MapperAdapter<M> {
    private let mapper: any Mapper
    private let update: (M) -> Void

    public init<T>(mapperType: T.Type) where T: Mapper, T.Metadata == M {
        let mapper = mapperType.init()
        update = { metadata in
            mapper.update(metadata: metadata)
        }
        self.mapper = mapper
    }

    func update(metadata: M) {
        update(metadata)
    }
}

protocol MapperAdapting {
    func mediaItemInfo(with error: Error?) -> NowPlayingInfo
    func metadataItems() -> [AVMetadataItem]

    func navigationMarkerGroups() -> [AVTimedMetadataGroup]
}

extension MapperAdapter: MapperAdapting {
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
