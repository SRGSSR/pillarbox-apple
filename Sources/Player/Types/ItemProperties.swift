//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct ItemProperties: Equatable {
    static var empty: Self {
        .init(
            state: .unknown,
            duration: .invalid,
            minimumTimeOffsetFromLive: .invalid,
            presentationSize: nil
        )
    }

    let state: ItemState

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?

    var chunkDuration: CMTime {
        CMTimeMultiplyByRatio(minimumTimeOffsetFromLive, multiplier: 1, divisor: 3)
    }
}
