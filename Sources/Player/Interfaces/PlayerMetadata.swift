//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public protocol PlayerMetadata: AnyObject {
    associatedtype Metadata

    init()

    func update(metadata: Metadata)

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo
    func metadataItems() -> [AVMetadataItem]
    func navigationMarkerGroups() -> [AVTimedMetadataGroup]
}

public extension PlayerMetadata {
    static func adapter<M>(mapper: @escaping (M) -> Metadata) -> MetadataAdapter<M> {
        .init(metadataType: Self.self, mapper: mapper)
    }
}

public extension PlayerMetadata where Metadata == Void {
    static func adapter<M>() -> MetadataAdapter<M> {
        .init(metadataType: Self.self) { _ in }
    }
}
