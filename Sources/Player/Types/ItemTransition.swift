//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// Action to be performed during an item transition.
enum ItemTransition: Equatable {
    /// Advance to the provided item.
    case advance(AVPlayerItem?)
    /// Stop on the provided item.
    case stop(AVPlayerItem)
}
