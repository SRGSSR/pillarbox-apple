//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct ExternalMetadata {
    static let empty = Self(items: [], chapters: [])

    public let items: [AVMetadataItem]
    public let chapters: [AVTimedMetadataGroup]
}
