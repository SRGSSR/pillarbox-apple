//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A transition between items in a playlist.
enum ItemTransition: Equatable {
    /// Advance to the provided item (or the beginning of the playlist if `nil`).
    case advance(to: AVPlayerItem?)
    /// Stop on the provided item.
    case stop(on: AVPlayerItem)
    /// Finish playing all items.
    case finish

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
        else if previousItem != nil {
            return .finish
        }
        else {
            return .advance(to: nil)
        }
    }
}
