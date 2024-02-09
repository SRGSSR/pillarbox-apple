//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// Action to be performed during an item transition.
enum ItemTransition: Equatable {
    /// Advance to the provided item (or the beginning of the playlist if `nil`).
    case advance(to: AVPlayerItem?)
    /// Stop on the provided item.
    case stop(on: AVPlayerItem)
    /// Finish playing all items.
    case finish(with: AVPlayerItem)
}
