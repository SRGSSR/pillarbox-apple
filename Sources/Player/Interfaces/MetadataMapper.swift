//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public protocol MetadataMapper: AnyObject {
    associatedtype Metadata

    init()

    func update(metadata: Metadata)

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo
    func metadataItems() -> [AVMetadataItem]
    func navigationMarkerGroups() -> [AVTimedMetadataGroup]
}

public extension MetadataMapper {
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> MapperAdapter<M> {
        .init(mapperType: Self.self, mapper: mapper)
    }
}

public extension MetadataMapper where Metadata == Void {
    static func adapter<M>() -> MapperAdapter<M> {
        .init(mapperType: Self.self) { _ in }
    }
}
