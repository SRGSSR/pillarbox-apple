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

    static func transition(from previousItem: AVPlayerItem?, to currentItem: AVPlayerItem?) -> Self {
        if let previousItem, previousItem.error != nil {
            return .stop(on: previousItem)
        }
        else if let currentItem, currentItem.error != nil {
            return .stop(on: currentItem)
        }
        else if let currentItem {
            return .advance(to: currentItem)
        }
        else if let previousItem {
            return .finish(with: previousItem)
        }
        else {
            return .advance(to: nil)
        }
    }
}
