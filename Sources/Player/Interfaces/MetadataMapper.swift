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
    static func adapter() -> MapperAdapter<Metadata> {
        .init(mapperType: Self.self)
    }
}
