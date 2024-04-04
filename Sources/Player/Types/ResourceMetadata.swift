//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct ResourceMetadata {
    static let empty = Self(items: [], timedItems: [], chapters: [])

    let items: [AVMetadataItem]
    let timedItems: [AVMetadataItem]
    let chapters: [AVMetadataGroup]
}
