//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct NullFormatter<M>: PlayerMetadataFormatter {
    func items(from metadata: M) -> [AVMetadataItem] {
        []
    }

    func timedGroups(from metadata: M) -> [AVTimedMetadataGroup] {
        []
    }

    func chapterGroups(from metadata: M) -> [AVTimedMetadataGroup] {
        []
    }
}
