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
        if let currentItem {
            if let previousItem, previousItem.error != nil {
                return .stop(on: previousItem)
            }
            else if currentItem.error == nil {
                return .advance(to: currentItem)
            }
            else {
                return .stop(on: currentItem)
            }
        }
        else if let previousItem {
            if previousItem.error == nil {
                return .finish(with: previousItem)
            }
            else {
                return .stop(on: previousItem)
            }
        }
        else {
            return .advance(to: nil)
        }
    }
}
