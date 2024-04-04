//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct ContentMetadata {
    static let empty = Self(items: [], chapters: [])

    public let items: [AVMetadataItem]
    public let chapters: [AVTimedMetadataGroup]
}
