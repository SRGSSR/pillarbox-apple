//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public protocol Mapper {
    associatedtype Metadata

    init(metadata: Metadata)

    func mediaItemInfo(at time: CMTime?, with error: Error?) -> NowPlayingInfo
    func metadataItems(at time: CMTime?, with error: Error?) -> [AVMetadataItem]

    func navigationMarkerGroups() -> [AVTimedMetadataGroup]
}

public extension Mapper {
    static func adapter() -> MapperAdapter<Metadata> {
        .init(mapperType: Self.self)
    }
}
