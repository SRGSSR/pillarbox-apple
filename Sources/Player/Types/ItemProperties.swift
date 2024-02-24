//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

struct ItemProperties: Equatable {
    static let empty = Self(
        item: nil,
        state: .unknown,
        duration: .invalid,
        minimumTimeOffsetFromLive: .invalid,
        presentationSize: nil
    )

    let item: AVPlayerItem?
    let state: ItemState

    let duration: CMTime
    let minimumTimeOffsetFromLive: CMTime

    let presentationSize: CGSize?
}
