//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

/// A transition between items in a playlist.
enum ItemTransition: Equatable {
    /// Go to the provided item (or the beginning of the playlist if `nil`).
    case go(to: AVPlayerItem?)
    /// Stop on the provided item.
    case stop(on: AVPlayerItem)
    /// Finish playing all items.
    case finish

    var playerItem: AVPlayerItem? {
        switch self {
        case let .go(to: item):
            return item
        case let .stop(on: item):
            return item
        case .finish:
            return nil
        }
    }

    static func transition(from previousUpdate: ItemUpdate, to currentUpdate: ItemUpdate) -> Self {
        if let previousItem = previousUpdate.item, previousUpdate.error != nil {
            return .stop(on: previousItem)
        }
        else if let currentItem = currentUpdate.item, currentUpdate.error != nil {
            return .stop(on: currentItem)
        }
        else if let currentItem = currentUpdate.item {
            return .go(to: currentItem)
        }
        else if previousUpdate.item != nil {
            return .finish
        }
        else {
            return .go(to: nil)
        }
    }
}
