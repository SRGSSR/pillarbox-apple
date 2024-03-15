//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public protocol MetadataExtractor  {
    associatedtype Metadata

    func update(metadata: Metadata)
    func mediaItemInfo(at time: CMTime?) -> [String: Any]
    func metadataItems(at time: CMTime?) -> [AVMetadataItem]
    func navigationMarkerGroups() -> [AVTimedMetadataGroup]
}
